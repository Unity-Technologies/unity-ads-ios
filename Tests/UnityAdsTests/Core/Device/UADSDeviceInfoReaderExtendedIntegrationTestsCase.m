#import <XCTest/XCTest.h>
#import "UADSDeviceInfoReaderBuilder.h"
#import "USRVStorageManager.h"
#import "UADSDeviceInfoReaderKeys.h"
#import "NSArray+Sort.h"
#import "UADSJsonStorageKeyNames.h"
#import "UADSDeviceTestsHelper.h"
#import "UADSFactoryConfigMock.h"
#import "NSDictionary+Filter.h"
#import "SDKMetricsSenderMock.h"
#import "UADSTsiMetric.h"
#import "XCTestCase+Convenience.h"
#import "UADSPrivacyStorageMock.h"
#import "UADSDeviceInfoReaderIntegrationTestsCaseBase.h"

@interface UADSDeviceInfoReaderExtendedIntegrationTestsCase : UADSDeviceInfoReaderIntegrationTestsCaseBase

@end

@implementation UADSDeviceInfoReaderExtendedIntegrationTestsCase

- (void)test_contains_default_device_info {
    [self.tester commitUserDefaultsTestData];
    [self setExpectedUserBehaviouralFlag: NO];
    
    NSArray *allKeys = [self.tester expectedKeysFromDefaultInfoWithUserNonBehavioral: false];

    [self.tester validateDataContains: [self getDataFromSut]
                              allKeys: allKeys];

    [self validateMetrics: @[
         self.tester.infoCollectionLatencyMetrics
    ]];
}

- (void)test_contains_attributes_from_the_storage {
    [self.tester commitAllTestData];
    [self setExpectedUserBehaviouralFlag: NO];

    [self.tester validateDataContains: [self getDataFromSut]
                              allKeys: [self allExpectedKeysWithNonBehavioral: false]];
    [self validateMetrics: @[
         self.tester.infoCollectionLatencyMetrics
    ]];
}

- (void)test_tracking_is_disabled_doesnt_contain_pii_attributes_no_nonbehavioural {
    [self.tester commitAllTestData];
    [self setExpectedUserBehaviouralFlag: NO];

    [self setPrivacyResponseState: kUADSPrivacyResponseDenied];
    NSArray *allKeys =  [self allExpectedKeysWithNonBehavioral: false];

    [self.tester validateDataContains: [self getDataFromSut]
                              allKeys: allKeys];
    [self validateMetrics: @[
         self.tester.infoCollectionLatencyMetrics
    ]];
}


- (void)test_tracking_is_disabled_doesnt_contain_pii_attributes_with_nonbehavioural {
    [self.tester commitAllTestData];
    [self setExpectedUserBehaviouralFlag: NO];
    [self setShouldSendNonBehavioural: true];
    [self setPrivacyResponseState: kUADSPrivacyResponseDenied];
    NSArray *allKeys =  [self allExpectedKeysWithNonBehavioral: true];

    [self.tester validateDataContains: [self getDataFromSut]
                              allKeys: allKeys];
    [self validateMetrics: @[
         self.tester.infoCollectionLatencyMetrics
    ]];
}

- (void)test_tracking_is_enabled_contains_pii_attributes_no_nonbehavioral {
    [self.tester commitAllTestData];
    [self setPrivacyResponseState: kUADSPrivacyResponseAllowed];

    [self setExpectedUserBehaviouralFlag: NO];

    NSArray *allKeys = [self expectedKeysWithPIIWithNonBehavioral: false];

    [self.tester validateDataContains: [self getDataFromSut]
                              allKeys: allKeys];

    [self validateMetrics: @[
         self.tester.infoCollectionLatencyMetrics
    ]];
}

- (void)test_tracking_is_enabled_contains_pii_attributes_with_nonbehavioral {
    [self.tester commitAllTestData];
    [self setPrivacyResponseState: kUADSPrivacyResponseAllowed];
    [self setShouldSendNonBehavioural: true];
    [self setExpectedUserBehaviouralFlag: NO];

    NSArray *allKeys = [self expectedKeysWithPIIWithNonBehavioral: true];

    [self.tester validateDataContains: [self getDataFromSut]
                              allKeys: allKeys];

    [self validateMetrics: @[
         self.tester.infoCollectionLatencyMetrics
    ]];
}

- (BOOL)isDeviceInfoReaderExtended {
    return true;
}

@end
