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
    NSArray *allKeys = [self.tester.expectedKeysFromDefaultInfo arrayByAddingObjectsFromArray:  @[UADSJsonStorageKeyNames.userNonBehavioralFlagKey]];

    [self.tester validateDataContains: [self getDataFromSut]
                              allKeys: allKeys];

    [self validateMetrics: @[
         self.tester.infoCollectionLatencyMetrics
    ]];
}

- (void)test_contains_attributes_from_the_storage {
    [self.tester commitAllTestData];

    [self.tester validateDataContains: [self getDataFromSut]
                              allKeys: [self expectedKeysNoPIIIncludeNonBehavioral: YES]];
    [self validateMetrics: @[
         self.tester.infoCollectionLatencyMetrics
    ]];
}

- (void)test_tracking_is_disabled_doesnt_contain_pii_attributes {
    [self.tester commitAllTestData];

    [self setPrivacyResponseState: kUADSPrivacyResponseDenied];
    NSArray *allKeys = [self expectedKeysNoPIIIncludeNonBehavioral: YES];

    [self.tester validateDataContains: [self getDataFromSut]
                              allKeys: allKeys];
    [self validateMetrics: @[
         self.tester.infoCollectionLatencyMetrics
    ]];
}

- (void)test_tracking_is_enabled_contains_pii_attributes {
    [self.tester commitAllTestData];
    [self setPrivacyResponseState: kUADSPrivacyResponseAllowed];

    [self setExpectedPrivacyModeTo: kUADSPrivacyModeMixed
           withUserBehaviouralFlag: NO];

    NSArray *allKeys = [self expectedKeysWithPIIIncludeNonBehavioral: YES];

    [self.tester validateDataContains: [self getDataFromSut]
                              allKeys: allKeys];

    [self validateMetrics: @[
         self.tester.infoCollectionLatencyMetrics
    ]];
}

- (id<UADSPrivacyConfig>)privacyConfig {
    UADSFactoryConfigMock *config =  [UADSFactoryConfigMock new];

    config.isPrivacyRequestEnabled = true;
    return config;
}

- (BOOL)isDeviceInfoReaderExtended {
    return true;
}

@end
