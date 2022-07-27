#import <XCTest/XCTest.h>
#import "UADSConfigurationLoaderBuilder.h"
#import "WebRequestFactoryMock.h"
#import "XCTestCase+Convenience.h"
#import "NSDictionary+JSONString.h"
#import "NSArray+Map.h"
#import "NSArray+Sort.h"
#import "UADSConfigurationPersistenceMock.h"
#import "UADSBaseURLBuilder.h"
#import "SDKMetricsSenderMock.h"
#import "UADSDeviceTestsHelper.h"
#import "UADSLoaderIntegrationTestsHelper.h"
#import "UADSDeviceTestsHelper.h"
#import "UADSConfigurationLoaderIntegrationTestsBase.h"


@interface UADSConfigurationLoaderIntegrationNoPrivacyRequestTests : UADSConfigurationLoaderIntegrationTestsBase

@end

@implementation UADSConfigurationLoaderIntegrationNoPrivacyRequestTests

- (void)test_config_with_tsi_on_triggers_new_flow_no_session_id_metrics {
    self.webRequestFactoryMock.expectedRequestData = @[self.helper.successPayload.uads_jsonData];

    [self callSUTExpectingSuccessWithConfig:  [self factoryConfigWithExperiments: @{ @"tsi": @"true" }]];

    [self validateCreatedRequestAtIndex: 0
                   withExpectedHostHame: self.expectedHostName
                     andExpectedQueries: nil];

    [self validateCreateRequestCalledNumberOfTimes: 1];
    [self validateConfigWasSavedToPersistenceNumberOfTimes: 1];
    [self validateMetrics: @[
         self.deviceInfoTester.infoCollectionLatencyMetrics,
         self.deviceInfoTester.tsiNoSessionIDMetrics,
         self.deviceInfoTester.infoCompressionLatencyMetrics,
         self.deviceInfoTester.configLatencySuccessMetric
    ]];
}

- (void)test_config_with_tsi_on_triggers_new_flow_no_metrics_when_all_data_set {
    [self.deviceInfoTester commitAllTestData];
    self.webRequestFactoryMock.expectedRequestData = @[self.helper.successPayload.uads_jsonData];

    [self callSUTExpectingSuccessWithConfig:  [self factoryConfigWithExperiments: @{ @"tsi": @"true" }]];


    NSArray *expectedKeys = [self appendCommonKeys: self.deviceInfoTester.allExpectedKeys];

    [self validateCreatedRequestAtIndex: 0
                   withExpectedHostHame: self.expectedHostName
                        andBodyDataKeys: expectedKeys];

    [self validateCreateRequestCalledNumberOfTimes: 1];
    [self validateConfigWasSavedToPersistenceNumberOfTimes: 1];
    [self validateMetrics: @[
         self.deviceInfoTester.infoCollectionLatencyMetrics,
         self.deviceInfoTester.infoCompressionLatencyMetrics,
         self.deviceInfoTester.configLatencySuccessMetric,
    ]];
}

- (void)test_config_with_tsi_on_triggers_new_flow_with_default_data_and_no_session_metric {
    [self.deviceInfoTester commitUserDefaultsTestData];

    self.webRequestFactoryMock.expectedRequestData = @[self.helper.successPayload.uads_jsonData];

    [self callSUTExpectingSuccessWithConfig:  [self factoryConfigWithExperiments: @{ @"tsi": @"true" }]];

    NSArray *expectedKeys = [self appendCommonKeys: self.deviceInfoTester.expectedKeysFromDefaultInfo];

    [self validateCreatedRequestAtIndex: 0
                   withExpectedHostHame: self.expectedHostName
                        andBodyDataKeys: expectedKeys];

    [self validateCreateRequestCalledNumberOfTimes: 1];
    [self validateConfigWasSavedToPersistenceNumberOfTimes: 1];
    [self validateMetrics: @[
         self.deviceInfoTester.infoCollectionLatencyMetrics,
         self.deviceInfoTester.tsiNoSessionIDMetrics,
         self.deviceInfoTester.infoCompressionLatencyMetrics,
         self.deviceInfoTester.configLatencySuccessMetric
    ]];
}

- (void)test_failed_config_tsi_on_triggers_fallback_using_legacy_call_emergency_off_metrics {
    [self.deviceInfoTester commitUserDefaultsTestData];
    self.webRequestFactoryMock.expectedRequestData = @[
        [NSData new],
        self.helper.successPayload.uads_jsonData
    ];

    [self callSUTExpectingSuccessWithConfig:  [self factoryConfigWithExperiments: @{ @"tsi": @"true" }]];

    NSArray *expectedKeys = [self appendCommonKeys: self.deviceInfoTester.expectedKeysFromDefaultInfo];

    [self validateCreatedRequestAtIndex: 0
                   withExpectedHostHame: self.expectedHostName
                        andBodyDataKeys: expectedKeys];

    [self validateCreatedRequestAtIndex: 1
                   withExpectedHostHame: self.expectedHostName
                     andExpectedQueries: self.helper.legacyFlowQueries];

    [self validateCreateRequestCalledNumberOfTimes: 2];
    [self validateConfigWasSavedToPersistenceNumberOfTimes: 1];
    [self validateMetrics: @[
         self.deviceInfoTester.infoCollectionLatencyMetrics,
         self.deviceInfoTester.tsiNoSessionIDMetrics,
         self.deviceInfoTester.infoCompressionLatencyMetrics,
         [self.deviceInfoTester configLatencyFailureMetricWithReason: kUADSConfigurationLoaderParsingError],
         self.deviceInfoTester.emergencyOffMetrics

    ]];
}

- (BOOL)includePrivacyRequestFlow {
    return false;
}

@end
