#import <XCTest/XCTest.h>
#import "UADSConfigurationLoaderBuilder.h"
#import "WebRequestFactoryMock.h"
#import "XCTestCase+Convenience.h"
#import "NSDictionary+JSONString.h"
#import "NSArray + Map.h"
#import "NSArray+Sort.h"
#import "UADSConfigurationPersistenceMock.h"
#import "UADSBaseURLBuilder.h"
#import "SDKMetricsSenderMock.h"
#import "ConfigurationMetricTagsReaderMock.h"
#import "UADSDeviceTestsHelper.h"
#import "UADSLoaderIntegrationTestsHelper.h"
#import "UADSDeviceTestsHelper.h"

@interface UADSConfigurationLoaderIntegrationTests : XCTestCase
@property (strong, nonatomic) WebRequestFactoryMock *webRequestFactoryMock;
@property (strong, nonatomic) UADSConfigurationPersistenceMock *saverMock;
@property (strong, nonatomic) SDKMetricsSenderMock *metricsSenderMock;
@property (strong, nonatomic) ConfigurationMetricTagsReaderMock *tagsReaderMock;
@property (strong, nonatomic) UADSLoaderIntegrationTestsHelper *helper;
@property (strong, nonatomic) UADSDeviceTestsHelper *deviceInfoTester;
@end

@implementation UADSConfigurationLoaderIntegrationTests

- (void)setUp {
    _webRequestFactoryMock = [WebRequestFactoryMock new];
    _saverMock = [UADSConfigurationPersistenceMock new];
    _metricsSenderMock = [SDKMetricsSenderMock new];
    _tagsReaderMock = [ConfigurationMetricTagsReaderMock new];
    _helper = [UADSLoaderIntegrationTestsHelper new];
    _deviceInfoTester = [UADSDeviceTestsHelper new];

    [_deviceInfoTester clearAllStorages];
}

- (void)test_empty_config_triggers_legacy_flow {
    _webRequestFactoryMock.expectedRequestData = @[_helper.successPayload.jsonData];

    [self callSUTExpectingSuccessWithConfig: [self factoryConfigWithExperiments: @{}]];

    [self validateCreatedRequestAtIndex: 0
                   withExpectedHostHame: self.expectedHostName
                     andExpectedQueries: _helper.legacyFlowQueries];

    [self validateCreateRequestCalledNumberOfTimes: 1];
    [self validateConfigWasSavedToPersistenceNumberOfTimes: 1];
    [self validateMetrics: @[]];
}

- (void)test_empty_config_triggers_legacy_flow_missing_data_in_response_metrics {
    _webRequestFactoryMock.expectedRequestData = @[_helper.successPayloadMissedData.jsonData];

    [self callSUTExpectingSuccessWithConfig:  [self factoryConfigWithExperiments: @{}]];

    [self validateCreatedRequestAtIndex: 0
                   withExpectedHostHame: self.expectedHostName
                     andExpectedQueries: _helper.legacyFlowQueries];

    [self validateCreateRequestCalledNumberOfTimes: 1];
    [self validateConfigWasSavedToPersistenceNumberOfTimes: 1];
    [self validateMetrics: _deviceInfoTester.missedDataMetrics];
}

- (void)test_config_with_tsi_on_triggers_new_flow_no_session_id_metrics {
    _webRequestFactoryMock.expectedRequestData = @[_helper.successPayload.jsonData];

    [self callSUTExpectingSuccessWithConfig:  [self factoryConfigWithExperiments: @{ @"tsi": @"true" }]];

    [self validateCreatedRequestAtIndex: 0
                   withExpectedHostHame: self.expectedHostName
                     andExpectedQueries: _helper.tsiFlowQueries];

    [self validateCreateRequestCalledNumberOfTimes: 1];
    [self validateConfigWasSavedToPersistenceNumberOfTimes: 1];
    [self validateMetrics: @[
         _deviceInfoTester.infoCollectionLatencyMetrics,
         _deviceInfoTester.tsiNoSessionIDMetrics,
         _deviceInfoTester.infoCompressionLatencyMetrics
    ]];
}

- (void)test_config_with_tsi_on_triggers_new_flow_no_metrics_when_all_data_set {
    [_deviceInfoTester commitAllTestData];

    _webRequestFactoryMock.expectedRequestData = @[_helper.successPayload.jsonData];


    [self callSUTExpectingSuccessWithConfig:  [self factoryConfigWithExperiments: @{ @"tsi": @"true" }]];

    [self validateCreatedRequestAtIndex: 0
                   withExpectedHostHame: self.expectedHostName
                     andExpectedQueries: _helper.tsiFlowQueries];
    [self validateCreatedRequestAtIndex: 0
             withExpectedCompressedKeys: [_deviceInfoTester allExpectedKeys]];

    [self validateCreateRequestCalledNumberOfTimes: 1];
    [self validateConfigWasSavedToPersistenceNumberOfTimes: 1];
    [self validateMetrics: @[
         _deviceInfoTester.infoCollectionLatencyMetrics,
         _deviceInfoTester.infoCompressionLatencyMetrics
    ]];
}

- (void)test_config_with_tsi_on_triggers_new_flow_with_default_data_and_no_session_metric {
    [_deviceInfoTester commitUserDefaultsTestData];

    _webRequestFactoryMock.expectedRequestData = @[_helper.successPayload.jsonData];

    [self callSUTExpectingSuccessWithConfig:  [self factoryConfigWithExperiments: @{ @"tsi": @"true" }]];

    [self validateCreatedRequestAtIndex: 0
                   withExpectedHostHame: self.expectedHostName
                     andExpectedQueries: _helper.tsiFlowQueries];
    [self validateCreatedRequestAtIndex: 0
             withExpectedCompressedKeys: [_deviceInfoTester expectedKeysFromDefaultInfo]];

    [self validateCreateRequestCalledNumberOfTimes: 1];
    [self validateConfigWasSavedToPersistenceNumberOfTimes: 1];
    [self validateMetrics: @[
         _deviceInfoTester.infoCollectionLatencyMetrics,
         _deviceInfoTester.tsiNoSessionIDMetrics,
         _deviceInfoTester.infoCompressionLatencyMetrics
    ]];
}

- (void)test_failed_config_tsi_on_triggers_fallback_using_legacy_call_emergency_off_metrics {
    _webRequestFactoryMock.expectedRequestData = @[[NSData new], _helper.successPayload.jsonData];

    [self callSUTExpectingSuccessWithConfig:  [self factoryConfigWithExperiments: @{ @"tsi": @"true" }]];

    [self validateCreatedRequestAtIndex: 0
                   withExpectedHostHame: self.expectedHostName
                     andExpectedQueries: _helper.tsiFlowQueries];

    [self validateCreatedRequestAtIndex: 1
                   withExpectedHostHame: self.expectedHostName
                     andExpectedQueries: _helper.legacyFlowQueries];

    [self validateCreateRequestCalledNumberOfTimes: 2];
    [self validateConfigWasSavedToPersistenceNumberOfTimes: 1];
    [self validateMetrics: @[
         _deviceInfoTester.infoCollectionLatencyMetrics,
         _deviceInfoTester.tsiNoSessionIDMetrics,
         _deviceInfoTester.infoCompressionLatencyMetrics,
         _deviceInfoTester.emergencyOffMetrics

    ]];
}

- (NSString *)expectedHostName {
    return [kDefaultConfigVersion stringByAppendingFormat: @".%@", kDefaultConfigHostNameBase];
}

- (void)callSUTExpectingFailWithConfig: (UADSConfigurationLoaderBuilderConfig)config {
    id<UADSConfigurationLoader> sut = [self sutForConfig: config];
    XCTestExpectation *exp = self.defaultExpectation;
    id success = ^(id obj) {
        XCTFail(@"Should not succeed");
        [exp fulfill];
    };

    id error = ^(id<UADSError> error) {
        [exp fulfill];
    };

    [sut loadConfigurationWithSuccess: success
                   andErrorCompletion: error];

    [self waitForExpectations: @[exp]
                      timeout: 1];
}

- (void)callSUTExpectingSuccessWithConfig: (UADSConfigurationLoaderBuilderConfig)config {
    id<UADSConfigurationLoader> sut = [self sutForConfig: config];
    XCTestExpectation *exp = self.defaultExpectation;
    id success = ^(id obj) {
        [exp fulfill];
    };

    id error = ^(id<UADSError> error) {
        XCTFail(@"Should not fail");
        [exp fulfill];
    };

    [sut loadConfigurationWithSuccess: success
                   andErrorCompletion: error];

    [self waitForExpectations: @[exp]
                      timeout: 1];
}

- (UADSConfigurationLoaderBuilder *)sutBuilderForConfig: (UADSConfigurationLoaderBuilderConfig)config {
    UADSConfigurationLoaderBuilder *builder = [UADSConfigurationLoaderBuilder newWithConfig: config
                                                                       andWebRequestFactory      : _webRequestFactoryMock];

    builder.configurationSaver = _saverMock;
    builder.metricsSender = _metricsSenderMock;
    builder.tagsReader = _tagsReaderMock;
    _tagsReaderMock.expectedTags = _deviceInfoTester.expectedTags;
    return builder;
}

- (void)validateMetrics: (NSArray<UADSMetric *> *)expectedMetrics {
    XCTAssertEqualObjects(_metricsSenderMock.sentMetrics, expectedMetrics);
}

- (id<UADSConfigurationLoader>)sutForConfig: (UADSConfigurationLoaderBuilderConfig)config {
    return [self sutBuilderForConfig: config].loader;
}

- (void)validateCreatedRequestAtIndex: (NSInteger)index
                 withExpectedHostHame: (NSString *)hostName
                   andExpectedQueries: (NSDictionary *)queryAttributes {
    WebRequestMock *request = _webRequestFactoryMock.createdRequests[index];

    [_helper validateURLofRequest: request.url
             withExpectedHostHame: hostName
               andExpectedQueries: queryAttributes];
}

- (void)validateCreatedRequestAtIndex: (NSInteger)index
           withExpectedCompressedKeys: (NSArray *)keys {
    WebRequestMock *request = _webRequestFactoryMock.createdRequests[index];

    [_helper  validateURLOfRequest: request.url
        withExpectedCompressedKeys: keys];
}

- (void)validateCreateRequestCalledNumberOfTimes: (NSInteger)count {
    XCTAssertEqual(_webRequestFactoryMock.createdRequests.count, count);
}

- (void)validateConfigWasSavedToPersistenceNumberOfTimes: (NSInteger)count {
    XCTAssertEqual(_saverMock.receivedConfig.count, count);
}

- (UADSConfigurationRequestFactoryConfigBase *)factoryConfigWithExperiments: (NSDictionary *)experiments {
    return [UADSConfigurationRequestFactoryConfigBase defaultWithExperiments: [UADSConfigurationExperiments newWithJSON: experiments]];
}

@end
