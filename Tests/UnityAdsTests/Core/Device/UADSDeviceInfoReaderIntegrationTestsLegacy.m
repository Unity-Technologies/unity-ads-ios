#import <XCTest/XCTest.h>
#import "UADSDeviceInfoReaderIntegrationTestsCaseBase.h"
#import "UADSJsonStorageKeyNames.h"

@interface UADSDeviceInfoReaderIntegrationTestsLegacy : UADSDeviceInfoReaderIntegrationTestsCaseBase

@end

@implementation UADSDeviceInfoReaderIntegrationTestsLegacy

- (void)test_contains_default_device_info {
    [self.tester commitUserDefaultsTestData];
    [self.tester commitNonBehavioral:true];
    
    [self.tester validateDataContains: [self getDataFromSut]
                              allKeys: [self.tester expectedKeysFromDefaultInfoWithUserNonBehavioral: false]];

    [self validateMetrics: @[
         self.tester.infoCollectionLatencyMetrics
    ]];
}

- (void)test_contains_attributes_from_the_storage {
    [self.tester commitAllTestData];
    [self.tester commitNonBehavioral:true];
    
    NSArray *allKeys = [self.tester allExpectedKeysWithNonBehavioral: false];

    [self.tester validateDataContains: [self getDataFromSut]
                              allKeys: allKeys];
    [self validateMetrics: @[
         self.tester.infoCollectionLatencyMetrics
    ]];
}

- (void)test_does_not_contain_attributes_from_PII_passed_by_web_view_when_non_behaviour_true {
    [self.tester commitAllTestData];

    [[self.tester privateStorage] set: [UADSJsonStorageKeyNames piiContainerKey]
                                value : self.piiFullContentData];

    [self setExpectedUserBehaviouralFlag: YES];

    [self.tester validateDataContains: [self getDataFromSut]
                              allKeys: [self.tester allExpectedKeysWithNonBehavioral: false]];
}

@end
