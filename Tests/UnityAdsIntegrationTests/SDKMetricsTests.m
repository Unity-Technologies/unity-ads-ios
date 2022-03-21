#import <XCTest/XCTest.h>
#import "USRVSDKMetrics.h"
#import "USRVSdkProperties.h"
#import "USRVDevice.h"
#import "NSDictionary+JSONString.h"
#import "UADSMetricSenderWithBatch.h"

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
    return [[NSData alloc] init];
}

@end

@interface WebRequstFactoryMock : NSObject<IUSRVWebRequestFactoryStatic>
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

@end

@interface SDKMetricsTest : XCTestCase
@property (nonatomic, strong) WebRequestMock *mockRequest;
@end

@implementation SDKMetricsTest

- (void)setUp {
    [super setUp];
    [USRVSDKMetrics reset];
    self.mockRequest = [[WebRequestMock alloc] init];
    [WebRequstFactoryMock shared].mockRequest = self.mockRequest;
}

- (void)tearDown {
    [super tearDown];
}

- (void)test_instance_use_null_instance_before_config {
    NSObject<ISDKMetrics> *instance = [USRVSDKMetrics getInstance];

    XCTAssertNotNil(instance, @"SDKMetrics Instance should never be nil");
    XCTAssertTrue([instance isKindOfClass: [UADSMetricSenderWithBatch class]]);
    XCTAssertTrue([[(UADSMetricSenderWithBatch *)instance original] isKindOfClass: [UADSMetricsNullInstance class]]);
}

- (void)test_instance_use_null_instance_if_rate_0 {
    USRVConfiguration *config = [self configWithURL: @"valid_url"
                                         sampleRate: 0];

    [USRVSDKMetrics setConfiguration: config];
    NSObject<ISDKMetrics> *instance = [USRVSDKMetrics getInstance];

    XCTAssertTrue([instance isKindOfClass: [UADSMetricSenderWithBatch class]]);
    XCTAssertTrue([[(UADSMetricSenderWithBatch *)instance original] isKindOfClass: [UADSMetricsNullInstance class]]);
}

- (void)test_instance_use_sender_instance_if_rate_100 {
    USRVConfiguration *config = [self configWithURL: @"valid_url"
                                         sampleRate: 100];

    [USRVSDKMetrics setConfiguration: config];
    NSObject<ISDKMetrics> *instance = [USRVSDKMetrics getInstance];

    XCTAssertTrue([instance isKindOfClass: [UADSMetricSenderWithBatch class]]);
    XCTAssertTrue([[(UADSMetricSenderWithBatch *)instance original] isKindOfClass: [UADSMetricSender class]]);
}

- (void)test_batches_events_before_config_and_sends_after_config_set {
    [self setupMetricsWithURL: nil
                   sampleRate: 0];

    [self sendMetricEvent: @"event1"];
    XCTAssertEqual(_mockRequest.makeRequestCount, 0);
    [self sendMetricEvent: @"event2"];
    XCTAssertEqual(_mockRequest.makeRequestCount, 0);

    [self setupMetricsWithURL: @"http://valid.url"
                   sampleRate: 100];
    [NSThread sleepForTimeInterval: 0.5];

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

- (void)test_nil_configuration {
    [USRVSDKMetrics setConfiguration: nil];
}

- (void)test_empty_url_from_configuration_does_not_send_event {
    [self setupMetricsWithURL: @""
                   sampleRate: 100];

    [self sendMetricEvent: @"test_event"];
    XCTAssertEqual(_mockRequest.makeRequestCount, 0);
    XCTAssertNil(_mockRequest.body);
}

- (void)test_valid_url_from_configuration_sends_event {
    [self setupMetricsWithURL: @"http://valid.url"
                   sampleRate: 100];

    [self sendMetricEvent: @"test_event"];

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
    [self setupMetricsWithURL: @"http://valid.url"
                   sampleRate: 100];

    [self sendMetricEvent: @"test_event"
                 withTags: @{ @"tag1": @"1", @"tag2": @"2" }];

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
    [self setupMetricsWithURL: @"http://valid.url"
                   sampleRate: 100];

    [self sendMetricEvent: @"test_event"
                    value: @(1)
                 withTags: nil];

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

- (void)test_sends_multiple_events {
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

    [USRVSDKMetrics setConfiguration: config
                      requestFactory: [WebRequstFactoryMock shared]];
}

- (USRVConfiguration *)configWithURL: (NSString *)url sampleRate: (int)rate {
    USRVConfiguration *config = [[USRVConfiguration alloc] init];

    config.metricSamplingRate = rate;
    config.metricsUrl = url;
    return config;
}

- (void)sendMetricEvent: (NSString *)event {
    [[USRVSDKMetrics getInstance] sendEvent: event];
    [NSThread sleepForTimeInterval: 0.5];
}

- (void)sendMetricEvent: (NSString *)event withTags: (NSDictionary<NSString *, NSString *> *)tags {
    [[USRVSDKMetrics getInstance] sendEventWithTags: event
                                               tags: tags];
    [NSThread sleepForTimeInterval: 0.5];
}

- (void)sendMetricEvent: (NSString *)event value: (NSNumber *)value withTags: (NSDictionary<NSString *, NSString *> *)tags {
    [[USRVSDKMetrics getInstance] sendEvent: event
                                      value: value
                                       tags: tags];
    [NSThread sleepForTimeInterval: 0.5];
}

- (void)sendMetricEvents: (NSArray<UADSMetric *> *)events {
    [[USRVSDKMetrics getInstance] sendMetrics: events];
    [NSThread sleepForTimeInterval: 0.5];
}

- (NSDictionary *)commonTags {
    return @{
        @"sdk": [NSString stringWithFormat: @"%@", [USRVSdkProperties getVersionName]],
        @"iso": [NSString stringWithFormat: @"%@", [USRVDevice getNetworkCountryISOWithLocaleFallback]],
        @"system": [NSString stringWithFormat: @"%@", [USRVDevice getOsVersion]],
        @"plt": @"ios"
    };
}

@end
