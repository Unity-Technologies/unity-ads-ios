#import <XCTest/XCTest.h>
#import "USRVSDKMetrics.h"
#import "USRVSdkProperties.h"
#import "USRVDevice.h"
#import "NSDictionary+JSONString.h"
#import "UADSMetricSenderWithBatch.h"
#import "UADSServiceProvider.h"

@interface WebRequestMock : NSObject<USRVWebRequest>
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *requestType;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, strong) NSDictionary<NSString *, NSArray *> *headers;
@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *responseHeaders;
@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) long long expectedContentLength;
@property (nonatomic, assign) long responseCode;
@property (nonatomic, assign) BOOL canceled;
@property (nonatomic, assign) BOOL finished;
@property (nonatomic, strong) NSCondition *blockCondition;
@property (nonatomic, strong) UnityServicesWebRequestProgress progressBlock;
@property (nonatomic, strong) UnityServicesWebRequestStart startBlock;

@property (nonatomic, strong) NSMutableURLRequest *request;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, assign) int connectTimeout;

@property (nonatomic, assign) int makeRequestCount;
@property (nonatomic, strong) XCTestExpectation *exp;
@end

@implementation WebRequestMock

- (void)cancel {
}

- (instancetype)initWithUrl: (NSString *)url requestType: (NSString *)requestType headers: (NSDictionary<NSString *, NSArray<NSString *> *> *)headers connectTimeout: (int)connectTimeout {
    self = [super init];
    return self;
}

- (NSData *)makeRequest {
    self.makeRequestCount += 1;
    [_exp fulfill];
    return [[NSData alloc] init];
}

@end

@interface WebRequstFactoryMock : NSObject<IUSRVWebRequestFactoryStatic, IUSRVWebRequestFactory>
@property (nonatomic, strong) id<USRVWebRequest> mockRequest;
+ (instancetype)shared;
@end

@implementation WebRequstFactoryMock
+ (instancetype)shared {
    static WebRequstFactoryMock *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[WebRequstFactoryMock alloc] init];
    });
    return sharedInstance;
}

+ (id<USRVWebRequest>)create: (NSString *)url requestType: (NSString *)requestType headers: (NSDictionary<NSString *, NSArray<NSString *> *> *)headers connectTimeout: (int)connectTimeout {
    id<USRVWebRequest> mockRequest = [[WebRequstFactoryMock shared] mockRequest];

    mockRequest.url = url;
    mockRequest.requestType = requestType;
    mockRequest.headers = headers;
    mockRequest.connectTimeout = connectTimeout;
    return mockRequest;
}

- (id<USRVWebRequest>)create: (NSString *)url requestType: (NSString *)requestType headers: (NSDictionary<NSString *, NSArray<NSString *> *> *)headers connectTimeout: (int)connectTimeout {
    return [[self class] create: url
                    requestType: requestType
                        headers: headers
                 connectTimeout: connectTimeout];
}

@end

@interface SDKMetricsIntegrationTest : XCTestCase
@property (nonatomic, strong) WebRequestMock *mockRequest;
@property (nonatomic, strong) UADSServiceProvider *serviceProvider;
@property (nonatomic, strong) id<ISDKMetrics>sut;
@end

@implementation SDKMetricsIntegrationTest

- (void)setUp {
    [super setUp];
    [self deleteConfigFile];
    self.mockRequest = [[WebRequestMock alloc] init];
    _serviceProvider = [UADSServiceProvider new];
    _serviceProvider.requestFactory = [WebRequstFactoryMock shared];
    self.sut = _serviceProvider.metricSender;
    [WebRequstFactoryMock shared].mockRequest = self.mockRequest;
}

- (void)tearDown {
    [super tearDown];
    [self deleteConfigFile];
}

- (void)test_batches_events_before_config_and_sends_after_config_set {
    XCTestExpectation *exp = self.defaultExpectation;

    _mockRequest.exp = exp;

    [self emulateLocalConfigContains: nil
                       andSampleRate: 0];

    [self sendMetricEvent: @"event1"];
    XCTAssertEqual(_mockRequest.makeRequestCount, 0);
    [self sendMetricEvent: @"event2"];
    XCTAssertEqual(_mockRequest.makeRequestCount, 0);

    [self setupMetricsWithURL: @"http://valid.url"
                   sampleRate: 100];

    [self waitForExpectations: @[exp]
                      timeout: 0.5];

    XCTAssertEqual(_mockRequest.makeRequestCount, 1);
    NSDictionary *expected = @{
        @"m": @[
            @{ @"n": @"event1" },
            @{ @"n": @"event2" }],
        @"t": [self commonTags]
    };
    NSString *expectedString = [expected jsonEncodedString];

    XCTAssertEqualObjects(expectedString, _mockRequest.body);

    [self sendMetricEvent: @"event3"];

    exp = self.defaultExpectation;

    _mockRequest.exp = exp;

    [self waitForExpectations: @[exp]
                      timeout: 0.5];

    XCTAssertEqual(_mockRequest.makeRequestCount, 2);
    expected = @{
        @"m": @[ @{ @"n": @"event3" }],
        @"t": [self commonTags]
    };
    expectedString = [expected jsonEncodedString];
    XCTAssertEqualObjects(expectedString, _mockRequest.body);
}

- (void)test_does_not_send_nil_and_empty_events {
    [self setupMetricsWithURL: @"http://valid.url"
                   sampleRate: 100];

    [self sendMetricEvent: @""];
    [self sendMetricEvent: nil];
    XCTAssertEqual(_mockRequest.makeRequestCount, 0);
    XCTAssertNil(_mockRequest.body);
}

- (void)test_empty_url_from_configuration_does_not_send_event {
    XCTestExpectation *exp = self.defaultExpectation;

    exp.inverted = true;
    _mockRequest.exp = exp;

    [self setupMetricsWithURL: @""
                   sampleRate: 100];

    [self sendMetricEvent: @"test_event"];
    [self waitForExpectations: @[exp]
                      timeout: 0.5];
    XCTAssertEqual(_mockRequest.makeRequestCount, 0);
    XCTAssertNil(_mockRequest.body);
}

- (void)test_valid_url_from_configuration_sends_event {
    XCTestExpectation *exp = self.defaultExpectation;

    _mockRequest.exp = exp;
    [self setupMetricsWithURL: @"http://valid.url"
                   sampleRate: 100];

    [self sendMetricEvent: @"test_event"];

    [self waitForExpectations: @[exp]
                      timeout: 0.5];
    XCTAssertEqual(_mockRequest.makeRequestCount, 1);
    NSDictionary *expected = @{
        @"m": @[
            @{
                @"n": @"test_event",
        }],
        @"t": [self commonTags]
    };
    NSString *expectedString = [expected jsonEncodedString];

    XCTAssertEqualObjects(expectedString, _mockRequest.body);
}

- (void)test_sends_event_with_tags {
    XCTestExpectation *exp = self.defaultExpectation;

    _mockRequest.exp = exp;
    [self setupMetricsWithURL: @"http://valid.url"
                   sampleRate: 100];

    [self sendMetricEvent: @"test_event"
                 withTags: @{ @"tag1": @"1", @"tag2": @"2" }];

    [self waitForExpectations: @[exp]
                      timeout: 0.5];

    XCTAssertEqual(_mockRequest.makeRequestCount, 1);
    NSDictionary *expected = @{
        @"m": @[
            @{
                @"n": @"test_event",
                @"t": @{
                    @"tag1": @"1",
                    @"tag2": @"2"
                }
        }],
        @"t": [self commonTags]
    };
    NSString *expectedString = [expected jsonEncodedString];

    XCTAssertEqualObjects(expectedString, _mockRequest.body);
}

- (void)test_sends_event_with_value {
    XCTestExpectation *exp = self.defaultExpectation;

    _mockRequest.exp = exp;
    [self setupMetricsWithURL: @"http://valid.url"
                   sampleRate: 100];

    [self sendMetricEvent: @"test_event"
                    value: @(1)
                 withTags: nil];

    [self waitForExpectations: @[exp]
                      timeout: 0.5];
    XCTAssertEqual(_mockRequest.makeRequestCount, 1);
    NSDictionary *expected = @{
        @"m": @[
            @{
                @"n": @"test_event",
                @"v": @(1)
        }],
        @"t": [self commonTags]
    };
    NSString *expectedString = [expected jsonEncodedString];

    XCTAssertEqualObjects(expectedString, _mockRequest.body);
}

- (void)test_calling_metric_sender_from_multiple_threads_doesnt_cause_crash {
    [self asyncExecuteTimes: 1000
                      block:^(XCTestExpectation *expectation, int index) {
                          [self setupMetricsWithURL: @"http://valid.url"
                                         sampleRate: 100];
                          [self.serviceProvider.metricSender sendEvent: @"test"];
                      }];
}

- (void)test_sends_multiple_events {
    XCTestExpectation *exp = self.defaultExpectation;

    _mockRequest.exp = exp;
    [self setupMetricsWithURL: @"http://valid.url"
                   sampleRate: 100];

    UADSMetric *event1 = [UADSMetric newWithName: @"e1"
                                           value: nil
                                            tags: nil];
    UADSMetric *event2 = [UADSMetric newWithName: @"e2"
                                           value: @(2)
                                            tags: nil];
    UADSMetric *event3 = [UADSMetric newWithName: @"e3"
                                           value: @(3)
                                            tags: @{ @"tag": @"1" }];

    [self sendMetricEvents: @[event1, event2, event3]];

    [self waitForExpectations: @[exp]
                      timeout: 0.5];
    XCTAssertEqual(_mockRequest.makeRequestCount, 1);
    NSDictionary *expected = @{
        @"m": @[
            @{
                @"n": @"e1",
            },
            @{
                @"n": @"e2",
                @"v": @(2)
            },
            @{
                @"n": @"e3",
                @"v": @(3),
                @"t": @{ @"tag": @"1" }
            }
        ],
        @"t": [self commonTags]
    };
    NSString *expectedString = [expected jsonEncodedString];

    XCTAssertEqualObjects(expectedString, _mockRequest.body);
    XCTAssertEqualObjects(@"http://valid.url", _mockRequest.url);
}

- (void)setupMetricsWithURL: (NSString *)url sampleRate: (int)rate {
    USRVConfiguration *config = [self configWithURL: url
                                         sampleRate: rate];

    [_serviceProvider.configurationStorage saveConfiguration: config];
}

- (USRVConfiguration *)configWithURL: (NSString *)url sampleRate: (int)rate {
    USRVConfiguration *config = [[USRVConfiguration alloc] init];

    config.metricSamplingRate = rate;
    config.metricsUrl = url;
    config.webViewUrl = @"web_URL";
    return config;
}

- (void)sendMetricEvent: (NSString *)event {
    [self.sut sendEvent: event];
}

- (void)sendMetricEvent: (NSString *)event withTags: (NSDictionary<NSString *, NSString *> *)tags {
    [self.sut sendEventWithTags: event
                           tags: tags];
}

- (void)sendMetricEvent: (NSString *)event value: (NSNumber *)value withTags: (NSDictionary<NSString *, NSString *> *)tags {
    [self.sut sendEvent: event
                  value: value
                   tags: tags];
}

- (void)sendMetricEvents: (NSArray<UADSMetric *> *)events {
    [self.sut sendMetrics: events];
}

- (NSDictionary *)commonTags {
    return @{
        @"sdk": [NSString stringWithFormat: @"%@", [USRVSdkProperties getVersionName]],
        @"iso": [NSString stringWithFormat: @"%@", [USRVDevice getNetworkCountryISOWithLocaleFallback]],
        @"system": [NSString stringWithFormat: @"%@", [USRVDevice getOsVersion]],
        @"plt": @"ios"
    };
}

- (void)emulateLocalConfigContains: (NSString *)metricsURL
                     andSampleRate: (int)rate {
    USRVConfiguration *config = [self configWithURL: metricsURL
                                         sampleRate: rate];

    [self saveLocalConfigToFile: config];
}

- (void)deleteConfigFile {
    NSString *fileName = [USRVSdkProperties getLocalConfigFilepath];

    [[NSFileManager defaultManager] removeItemAtPath: fileName
                                               error: nil];
}

- (void)saveLocalConfigToFile: (USRVConfiguration *)config {
    [self deleteConfigFile];
    [config saveToDisk];
}

- (XCTestExpectation *)defaultExpectation {
    return [self expectationWithDescription: @"MetricsTests"];
}

- (void)asyncExecuteTimes: (int)count block: (void (^)(XCTestExpectation *expectation, int index))block {
    XCTestExpectation *expectation = [self defaultExpectation];

    expectation.expectedFulfillmentCount = count;
    _mockRequest.exp = expectation;

    for (int i = 0; i < count; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block(expectation, i);
        });
    }

    [self waitForExpectations: @[expectation]
                      timeout: 30];
}

@end
