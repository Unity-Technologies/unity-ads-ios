#import <XCTest/XCTest.h>
#import "NSDictionary+JSONString.h"
#import "UADSConfigurationLoaderIntegrationTestsBase.h"
#import "UADSJsonStorageKeyNames.h"

@interface UADSConfigurationLoaderIntegrationPrivacyRequestTests : UADSConfigurationLoaderIntegrationTestsBase

@end

@implementation UADSConfigurationLoaderIntegrationPrivacyRequestTests

- (void)test_tsi_on_prr_on_should_call_privacy_request {
    self.webRequestFactoryMock.expectedRequestData = @[
        self.helper.successPayloadPrivacy.uads_jsonData,
        self.helper.successPayload.uads_jsonData
    ];

    NSDictionary *experimentsFlags = @{
        @"tsi": @"true",
        @"tsi_prr": @"true"
    };

    [self.deviceInfoTester commitAllTestData];

    [self callSUTExpectingSuccessWithConfig: [self factoryConfigWithExperiments: experimentsFlags]];

    NSArray *expectedKeys = self.deviceInfoTester.allExpectedKeysFromMinInfo;

    [self validateCreatedRequestAtIndex: 0
                   withExpectedHostHame: self.expectedHostName
                        andBodyDataKeys: [self appendUserNonBehaviouralAndCommonTo: expectedKeys]];


    NSArray *expectedWithPII = [[self.deviceInfoTester allExpectedKeys] arrayByAddingObjectsFromArray: self.deviceInfoTester.piiDecisionContentData.allKeys];

    expectedWithPII = [self appendUserNonBehaviouralAndCommonTo: expectedWithPII];

    [self validateCreatedRequestAtIndex: 1
                   withExpectedHostHame: self.expectedHostName
                        andBodyDataKeys: expectedWithPII];



    [self validateCreateRequestCalledNumberOfTimes: 2];
    [self validateConfigWasSavedToPersistenceNumberOfTimes: 1];
    [self validateMetrics: @[
         self.deviceInfoTester.privacyRequestLatencyMetrics,
         self.deviceInfoTester.infoCollectionLatencyMetrics,
         self.deviceInfoTester.infoCompressionLatencyMetrics,
         self.deviceInfoTester.configLatencySuccessMetric
    ]];
}

- (void)test_if_privacy_succeeds_loader_calls_it_once_per_session {
    self.webRequestFactoryMock.expectedRequestData = @[
        self.helper.successPayloadPrivacy.uads_jsonData,
        self.helper.successPayload.uads_jsonData,
        self.helper.successPayload.uads_jsonData
    ];

    NSDictionary *experimentsFlags = @{
        @"tsi": @"true",
        @"tsi_prr": @"true"
    };

    [self.deviceInfoTester commitAllTestData];

    [self callSUTExpectingSuccessWithConfig: [self factoryConfigWithExperiments: experimentsFlags]];
    [self callSUTExpectingSuccessWithConfig: [self factoryConfigWithExperiments: experimentsFlags]];

    // privacy request
    NSArray *expectedKeys = self.deviceInfoTester.allExpectedKeysFromMinInfo;

    [self validateCreatedRequestAtIndex: 0
                   withExpectedHostHame: self.expectedHostName
                        andBodyDataKeys: [self appendUserNonBehaviouralAndCommonTo: expectedKeys]];


    //first config request
    NSArray *expectedWithPII = [[self.deviceInfoTester allExpectedKeys] arrayByAddingObjectsFromArray: self.deviceInfoTester.piiDecisionContentData.allKeys];

    expectedWithPII = [self appendUserNonBehaviouralAndCommonTo: expectedWithPII];

    [self validateCreatedRequestAtIndex: 1
                   withExpectedHostHame: self.expectedHostName
                        andBodyDataKeys: expectedWithPII];


    //second config request
    [self validateCreatedRequestAtIndex: 2
                   withExpectedHostHame: self.expectedHostName
                        andBodyDataKeys: expectedWithPII];

    [self validateCreateRequestCalledNumberOfTimes: 3];
    [self validateConfigWasSavedToPersistenceNumberOfTimes: 2];
    [self validateMetrics: @[
         self.deviceInfoTester.privacyRequestLatencyMetrics,
         self.deviceInfoTester.infoCollectionLatencyMetrics,
         self.deviceInfoTester.infoCompressionLatencyMetrics,
         self.deviceInfoTester.configLatencySuccessMetric,
         self.deviceInfoTester.infoCollectionLatencyMetrics,
         self.deviceInfoTester.infoCompressionLatencyMetrics,
         self.deviceInfoTester.configLatencySuccessMetric
    ]];
}

- (void)test_tsi_on_prr_on_privacy_request_broken_should_not_include_pii {
    self.webRequestFactoryMock.expectedRequestData = @[
        [NSData new],
        self.helper.successPayload.uads_jsonData
    ];

    NSDictionary *experimentsFlags = @{
        @"tsi": @"true",
        @"tsi_prr": @"true"
    };

    [self.deviceInfoTester commitAllTestData];

    [self callSUTExpectingSuccessWithConfig: [self factoryConfigWithExperiments: experimentsFlags]];

    NSArray *expectedKeys = self.deviceInfoTester.allExpectedKeysFromMinInfo;

    [self validateCreatedRequestAtIndex: 0
                   withExpectedHostHame: self.expectedHostName
                        andBodyDataKeys: [self appendUserNonBehaviouralAndCommonTo: expectedKeys]];


    [self validateCreatedRequestAtIndex: 1
                   withExpectedHostHame: self.expectedHostName
                        andBodyDataKeys: [self appendUserNonBehaviouralAndCommonTo: self.deviceInfoTester.allExpectedKeys]];

    [self validateCreateRequestCalledNumberOfTimes: 2];
    [self validateConfigWasSavedToPersistenceNumberOfTimes: 1];
    [self validateMetrics: @[
         [self.deviceInfoTester privacyRequestFailureWithReason: kUADSPrivacyLoaderParsingError],
         self.deviceInfoTester.infoCollectionLatencyMetrics,
         self.deviceInfoTester.infoCompressionLatencyMetrics,
         self.deviceInfoTester.configLatencySuccessMetric
    ]];
}

- (NSArray<NSString *> *)appendUserNonBehaviouralAndCommonTo: (NSArray<NSString *> *)array {
    return [self appendCommonKeys: [array arrayByAddingObject: UADSJsonStorageKeyNames.userNonBehavioralFlagKey]];
}

@end
