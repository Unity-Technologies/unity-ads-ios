#import <XCTest/XCTest.h>
#import "WebRequestFactoryMock.h"
#import "UADSMetricSenderWithBatch.h"
#import "SDKMetricsSenderMock.h"
#import "XCTestCase+Convenience.h"
#import "NSDate+Mock.h"
#import "UADSPrivacyStorageMock.h"
#import "USRVDevice.h"
#import "UADSServiceProviderContainer.h"
#import "UADSMediationMetaData.h"
#import "USRVStorageManager.h"
#import "NSDictionary+Merge.h"
#import "USRVClientProperties.h"
#import "UnityAds+Testability.h"

@interface UADSMetricSenderTestCase : XCTestCase
@property (nonatomic, strong) UADSServiceProvider *serviceProvider;
@property (nonatomic, strong) UADSPrivacyStorageMock *privacyMock;
@property (nonatomic, strong) id<ISDKMetrics, ISDKPerformanceMetricsSender>sut;
@property (nonatomic, strong) WebRequestFactoryMock *requestFactoryMock;
@end

NSString *const VALID_URL = @"http://valid.url";

@implementation UADSMetricSenderTestCase

- (void)setUp {
    [super setUp];
    [UnityAds resetForTest];
    [self deleteConfigFile];
    [USRVClientProperties setGameId:@"54321"];
    self.privacyMock = [[UADSPrivacyStorageMock alloc] init];
    _serviceProvider = [UADSServiceProvider new];
    _serviceProvider.privacyStorage = _privacyMock;

    _requestFactoryMock = [WebRequestFactoryMock new];
    _serviceProvider.webViewRequestFactory = _requestFactoryMock;
    _serviceProvider.metricsRequestFactory = _requestFactoryMock;

    [self clearMediationMetadata];
    [USRVSdkProperties setTestMode: false];
    self.sut = _serviceProvider.metricSender;
    UADSServiceProviderContainer.sharedInstance.serviceProvider = _serviceProvider;
}

- (void)tearDown {
    [super tearDown];
    [self deleteConfigFile];
    UADSServiceProviderContainer.sharedInstance.serviceProvider = [UADSServiceProvider new];
    [UnityAds resetForTest];
}

- (void)test_sends_proper_performance_metrics_payload {
    [NSDate setMockDate: false];
    [self setupMetricsWithURL: VALID_URL
                   sampleRate: 100];
    NSTimeInterval delay = 1;
    NSTimeInterval expectedDelay = delay * 1000;
    XCTestExpectation *exp = self.defaultExpectation;

    exp.expectedFulfillmentCount = 1;
    UADSMetric *testMetric1 = [UADSMetric newWithName: @"test1"
                                                value: nil
                                                 tags: nil];

    [_sut measureDurationAndSend:^(UADSCompleteMeasureBlock _Nonnull completion) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                           [NSThread sleepForTimeInterval: delay];
                           completion(testMetric1);
                           [exp fulfill];
                       });
    }];

    [self waitForExpectations: @[exp]
                      timeout: delay + 0.5];

    [self waitForTimeInterval: 0.5];
    XCTAssertEqualObjects(self.mockRequest.url, VALID_URL);
    NSData *body = [self.mockRequest.body dataUsingEncoding: NSUTF8StringEncoding];
    NSDictionary *bodyPayload = [NSJSONSerialization JSONObjectWithData: body
                                                                options: NSJSONReadingAllowFragments
                                                                  error: nil];
    NSDictionary *metricPayload = bodyPayload[@"m"][0];

    XCTAssertEqualObjects(metricPayload[@"n"], @"test1");
    XCTAssertEqualWithAccuracy([metricPayload[@"v"] intValue], expectedDelay, 50);
}

- (void)test_batches_events_before_config_and_sends_after_config_set {
    XCTestExpectation *exp = self.defaultExpectation;

    self.requestFactoryMock.exp = exp;

    [self emulateLocalConfigContains: nil
                       andSampleRate: 0];

    [self sendMetricEvent: @"event1"];
    XCTAssertEqual(self.requestFactoryMock.createdRequests.count, 0);
    [self sendMetricEvent: @"event2"];
    XCTAssertEqual(self.requestFactoryMock.createdRequests.count, 0);

    [self setupMetricsWithURL: @"http://valid.url"
                   sampleRate: 100];

    [self waitForExpectations: @[exp]
                      timeout: 0.5];
    
    XCTAssertEqual(self.requestFactoryMock.createdRequests.count, 1);
    NSDictionary *expected = @{
        @"m": @[
            @{ @"n": @"event1" },
            @{ @"n": @"event2" }],
        @"t": [self commonTags] };
    expected = [NSDictionary uads_dictionaryByMerging:expected secondary:[self commonMetricInfo]];
    
    XCTAssertEqualObjects(expected, self.requestBodyDictionary);
    
    [self sendMetricEvent: @"event3"];
    
    exp = self.defaultExpectation;

    self.requestFactoryMock.exp = exp;

    [self waitForExpectations: @[exp]
                      timeout: 0.5];

    XCTAssertEqual(self.requestFactoryMock.createdRequests.count, 2);
    expected = @{
        @"m": @[ @{ @"n": @"event3" }],
        @"t": [self commonTags],
    };
    expected = [NSDictionary uads_dictionaryByMerging:expected secondary:[self commonMetricInfo]];
    XCTAssertEqualObjects(expected, self.requestBodyDictionary);
}

- (void)test_does_not_send_nil_and_empty_events {
    [self setupMetricsWithURL: VALID_URL
                   sampleRate: 100];

    [self sendMetricEvent: @""];
    [self sendMetricEvent: nil];
    XCTAssertEqual(self.requestFactoryMock.createdRequests.count, 0);
}

- (void)test_empty_url_from_configuration_does_not_send_event {
    XCTestExpectation *exp = self.defaultExpectation;

    exp.inverted = true;
    self.requestFactoryMock.exp = exp;

    [self setupMetricsWithURL: @""
                   sampleRate: 100];

    [self sendMetricEvent: @"test_event"];
    [self waitForExpectations: @[exp]
                      timeout: 0.5];
    XCTAssertEqual(self.requestFactoryMock.createdRequests.count, 0);
}

- (void)test_valid_url_from_configuration_sends_event {
    XCTestExpectation *exp = self.defaultExpectation;

    self.requestFactoryMock.exp = exp;
    [self setupMetricsWithURL: VALID_URL
                   sampleRate: 100];

    [self sendMetricEvent: @"test_event"];

    [self waitForExpectations: @[exp]
                      timeout: 0.5];
    XCTAssertEqual(self.requestFactoryMock.createdRequests.count, 1);
    NSDictionary *expected = @{
        @"m": @[
            @{
                @"n": @"test_event",
        }],
        @"t": [self commonTags]
    };
    expected = [NSDictionary uads_dictionaryByMerging:expected secondary:[self commonMetricInfo]];

    XCTAssertEqualObjects(expected, self.requestBodyDictionary);
}

- (void)test_sends_event_with_tags {
    [USRVSdkProperties setTestMode: true];
    [_privacyMock setExpectedState: kUADSPrivacyResponseDenied];

    XCTestExpectation *exp = self.defaultExpectation;

    self.requestFactoryMock.exp = exp;
    [self setupMetricsWithURL: VALID_URL
                   sampleRate: 100];

    [self sendMetricEvent: @"test_event"
                 withTags: @{ @"tag1": @"1", @"tag2": @"2" }];

    [self waitForExpectations: @[exp]
                      timeout: 0.5];

    XCTAssertEqual(self.requestFactoryMock.createdRequests.count, 1);
    NSDictionary *expected = @{
        @"m": @[
            @{
                @"n": @"test_event",
                @"t": @{
                    @"tag1": @"1",
                    @"tag2": @"2"
                }
        }],
        @"t": [self commonTagsWithTestMode: true
                              privacyState: kUADSPrivacyResponseDenied]
    };
    expected = [NSDictionary uads_dictionaryByMerging:expected secondary:[self commonMetricInfo]];

    XCTAssertEqualObjects(expected, self.requestBodyDictionary);
}

- (void)test_sends_event_with_value {
    [USRVSdkProperties setTestMode: true];
    [_privacyMock setExpectedState: kUADSPrivacyResponseAllowed];
    XCTestExpectation *exp = self.defaultExpectation;

    self.requestFactoryMock.exp = exp;
    [self setupMetricsWithURL: VALID_URL
                   sampleRate: 100];

    [self sendMetricEvent: @"test_event"
                    value: @(1)
                 withTags: nil];

    [self waitForExpectations: @[exp]
                      timeout: 0.5];
    XCTAssertEqual(self.requestFactoryMock.createdRequests.count, 1);
    NSDictionary *expected = @{
        @"m": @[
            @{
                @"n": @"test_event",
                @"v": @(1)
        }],
        @"t": [self commonTagsWithTestMode: true
                              privacyState: kUADSPrivacyResponseAllowed]
    };
    expected = [NSDictionary uads_dictionaryByMerging:expected secondary:[self commonMetricInfo]];

    XCTAssertEqualObjects(expected, self.requestBodyDictionary);
}

- (void)test_calling_metric_sender_from_multiple_threads_doesnt_cause_crash {
    [self asyncExecuteTimes: 1000
                      block:^(XCTestExpectation *expectation, int index) {
                          self.requestFactoryMock.exp = expectation;
                          [self setupMetricsWithURL: VALID_URL
                                         sampleRate: 100];

                          [self.serviceProvider.metricSender sendEvent: @"test"];
                      }];
}

- (void)test_sends_multiple_events {
    XCTestExpectation *exp = self.defaultExpectation;

    self.requestFactoryMock.exp = exp;
    [self setupMetricsWithURL: VALID_URL
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
    XCTAssertEqual(self.requestFactoryMock.createdRequests.count, 1);
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
    expected = [NSDictionary uads_dictionaryByMerging:expected secondary:[self commonMetricInfo]];

    XCTAssertEqualObjects(expected, self.requestBodyDictionary);
    XCTAssertEqualObjects(VALID_URL, self.mockRequest.url);
}

- (void)test_has_mediation_info_when_commited {
    [self commitMediationMetadata];
    XCTestExpectation *exp = self.defaultExpectation;

    self.requestFactoryMock.exp = exp;
    [self setupMetricsWithURL: VALID_URL
                   sampleRate: 100];

    [self sendMetricEvent: @"test_event"
                    value: @(1)
                 withTags: nil];

    [self waitForExpectations: @[exp]
                      timeout: 0.5];
    XCTAssertEqual(self.requestFactoryMock.createdRequests.count, 1);

    NSMutableDictionary *commonTags = [NSMutableDictionary dictionaryWithDictionary: self.commonTags];

    [commonTags addEntriesFromDictionary: self.mediationMetadata];

    NSDictionary *expected = @{
        @"m": @[
            @{
                @"n": @"test_event",
                @"v": @(1)
        }],
        @"t": commonTags
    };
    expected = [NSDictionary uads_dictionaryByMerging:expected secondary:[self commonMetricInfo]];

    XCTAssertEqualObjects(expected, self.requestBodyDictionary);
}

- (NSDictionary *)requestBodyDictionary {
    NSData *data = [self.mockRequest.body dataUsingEncoding: NSUTF8StringEncoding];

    return [NSJSONSerialization JSONObjectWithData: data
                                           options: 0
                                             error: nil];
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
    config.enableNativeMetrics = rate == 100;

    config.experiments = [UADSConfigurationExperiments newWithJSON: self.experiments];

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
    return [self commonTagsWithTestMode: false
                           privacyState: kUADSPrivacyResponseUnknown];
}

- (NSDictionary *)commonTagsWithTestMode: (BOOL)testMode privacyState: (UADSPrivacyResponseState)state {
    NSMutableDictionary *tags = [NSMutableDictionary dictionaryWithDictionary: [self deviceTagsWithTestMode: testMode]];

    [tags addEntriesFromDictionary: self.experiments];
    [tags addEntriesFromDictionary: [self privateTagsWithState: state]];
    return tags;
}

- (NSDictionary *)deviceTagsWithTestMode: (BOOL)testMode {
    return @{
        @"sdk": [NSString stringWithFormat: @"%@", [USRVSdkProperties getVersionName]],
        @"iso": [NSString stringWithFormat: @"%@", [USRVDevice getNetworkCountryISOWithLocaleFallback]],
        @"system": [NSString stringWithFormat: @"%@", [USRVDevice getOsVersion]],
        @"plt": @"ios",
        @"tm": [@(testMode) stringValue],
        @"prvc": @"unknown"
    };
}

- (NSDictionary *)commonMetricInfo {
    return @{
        @"msr": @"100",
        @"deviceMake": @"Apple",
        @"deviceModel": USRVDevice.getModel,
        @"gameId": USRVClientProperties.getGameId,
        @"shSid": [_serviceProvider sharedSessionId]
    };
}

- (NSDictionary *)privateTagsWithState: (UADSPrivacyResponseState)state {
    return @{
        @"prvc": uads_privacyResponseStateToString(state)
    };
}

- (NSDictionary *)experiments {
    return @{
        @"ff": @"true"
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

- (void)commitMediationMetadata {
    UADSMediationMetaData *mediationMetaData = [[UADSMediationMetaData alloc] init];

    [mediationMetaData setName: @"test_mediation"];
    [mediationMetaData setVersion: @"1.0.0"];
    [mediationMetaData set: @"adapter_version"
                     value : @"1.9.1"];
    [mediationMetaData commit];
}

- (NSDictionary *)mediationMetadata {
    return @{
        @"m_name": @"test_mediation",
        @"m_ver": @"1.0.0",
        @"m_ad_ver": @"1.9.1"
    };
}

- (void)clearMediationMetadata {
    [[USRVStorageManager getStorage: kUnityServicesStorageTypePublic] clearStorage];
    [[USRVStorageManager getStorage: kUnityServicesStorageTypePublic] initData];
}

- (WebRequestMock *)mockRequest {
    return self.requestFactoryMock.createdRequests.lastObject;
}

@end
