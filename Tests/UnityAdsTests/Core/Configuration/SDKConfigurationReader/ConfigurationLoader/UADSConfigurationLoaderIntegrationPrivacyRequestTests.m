#import <XCTest/XCTest.h>
#import "NSDictionary+JSONString.h"
#import "UADSConfigurationLoaderIntegrationTestsBase.h"
#import "UADSJsonStorageKeyNames.h"

@interface UADSConfigurationLoaderIntegrationPrivacyRequestTests : UADSConfigurationLoaderIntegrationTestsBase

@end

@implementation UADSConfigurationLoaderIntegrationPrivacyRequestTests

- (void)test_default_should_call_privacy_request {
    self.webRequestFactoryMock.expectedRequestData = @[
        self.helper.successPayloadPrivacy.uads_jsonData,
        self.helper.successPayload.uads_jsonData
    ];

    [self.deviceInfoTester commitAllTestData];
    [self.deviceInfoTester commitNonBehavioral:true];
    
    [self callSUTExpectingSuccessWithConfig: [self factoryConfigWithExperiments: @{}]];

    NSArray *expectedKeys = [self.deviceInfoTester allExpectedKeysFromMinInfoWithUserNonBehavioral:true];

    [self validateCreatedRequestAtIndex: 0
                   withExpectedHostHame: self.expectedHostName
                        andBodyDataKeys: [self appendCommonTo: expectedKeys]];


    NSArray *expectedWithPII = [[self.deviceInfoTester allExpectedKeysWithNonBehavioral: false] arrayByAddingObjectsFromArray: self.deviceInfoTester.piiDecisionContentData.allKeys];

    expectedWithPII = [self appendCommonTo: expectedWithPII];

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

    [self.deviceInfoTester commitAllTestData];
    [self.deviceInfoTester commitNonBehavioral:true];

    [self callSUTExpectingSuccessWithConfig: [self factoryConfigWithExperiments: @{}]];
    [self callSUTExpectingSuccessWithConfig: [self factoryConfigWithExperiments: @{}]];

    // privacy request
    NSArray *expectedKeys = [self.deviceInfoTester allExpectedKeysFromMinInfoWithUserNonBehavioral:true];

    [self validateCreatedRequestAtIndex: 0
                   withExpectedHostHame: self.expectedHostName
                        andBodyDataKeys: [self appendCommonTo: expectedKeys]];


    //first config request
    NSArray *expectedWithPII = [[self.deviceInfoTester allExpectedKeysWithNonBehavioral: false] arrayByAddingObjectsFromArray: self.deviceInfoTester.piiDecisionContentData.allKeys];

    expectedWithPII = [self appendCommonTo: expectedWithPII];

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

- (void)test_default_privacy_request_broken_should_not_include_pii {
    self.webRequestFactoryMock.expectedRequestData = @[
        [NSData new],
        self.helper.successPayload.uads_jsonData
    ];

    [self.deviceInfoTester commitAllTestData];
    [self.deviceInfoTester commitNonBehavioral:true];

    [self callSUTExpectingSuccessWithConfig: [self factoryConfigWithExperiments: @{}]];

    NSArray *expectedKeys = [self.deviceInfoTester allExpectedKeysFromMinInfoWithUserNonBehavioral:true];

    [self validateCreatedRequestAtIndex: 0
                   withExpectedHostHame: self.expectedHostName
                        andBodyDataKeys: [self appendCommonTo: expectedKeys]];


    [self validateCreatedRequestAtIndex: 1
                   withExpectedHostHame: self.expectedHostName
                        andBodyDataKeys: [self appendCommonTo: [self.deviceInfoTester allExpectedKeysWithNonBehavioral: false]]];

    [self validateCreateRequestCalledNumberOfTimes: 2];
    [self validateConfigWasSavedToPersistenceNumberOfTimes: 1];
    [self validateMetrics: @[
         [self.deviceInfoTester privacyRequestFailureWithReason: kUADSPrivacyLoaderParsingError],
         self.deviceInfoTester.infoCollectionLatencyMetrics,
         self.deviceInfoTester.infoCompressionLatencyMetrics,
         self.deviceInfoTester.configLatencySuccessMetric
    ]];
}

- (NSArray<NSString *> *)appendCommonTo: (NSArray<NSString *> *)array {
    return [self appendCommonKeys: array];
}

@end
