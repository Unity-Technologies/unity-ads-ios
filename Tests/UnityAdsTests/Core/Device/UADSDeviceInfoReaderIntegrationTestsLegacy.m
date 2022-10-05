#import <XCTest/XCTest.h>
#import "UADSDeviceInfoReaderIntegrationTestsCaseBase.h"
#import "UADSJsonStorageKeyNames.h"

@interface UADSDeviceInfoReaderIntegrationTestsLegacy : UADSDeviceInfoReaderIntegrationTestsCaseBase

@end

@implementation UADSDeviceInfoReaderIntegrationTestsLegacy

- (void)test_contains_default_device_info {
    [self.tester commitUserDefaultsTestData];
    [self.tester validateDataContains: [self getDataFromSut]
                              allKeys: self.tester.expectedKeysFromDefaultInfo];

    [self validateMetrics: @[
         self.tester.infoCollectionLatencyMetrics
    ]];
}

- (void)test_contains_attributes_from_the_storage {
    [self.tester commitAllTestData];
    NSArray *allKeys = [self.tester allExpectedKeys];

    [self.tester validateDataContains: [self getDataFromSut]
                              allKeys: allKeys];
    [self validateMetrics: @[
         self.tester.infoCollectionLatencyMetrics
    ]];
}

- (void)test_contains_attributes_from_PII_passed_by_web_view_when_non_behaviour_false {
    [self.tester commitAllTestData];

    [[self.tester privateStorage] set: [UADSJsonStorageKeyNames piiContainerKey]
                                value : self.piiFullContentData];

    BOOL shouldIncludeNonBehavioral = YES;
    BOOL nonBehaviouralFlag = NO;

    [self setExpectedPrivacyModeTo: kUADSPrivacyModeMixed
           withUserBehaviouralFlag: nonBehaviouralFlag];

    NSArray *allKeys = [self.tester allExpectedKeys];

    allKeys = [allKeys arrayByAddingObjectsFromArray: self.piiExpectedData.allKeys];
    allKeys = [allKeys arrayByAddingObjectsFromArray: [self.tester expectedPrivacyModeKeysWitNonBehavioral: shouldIncludeNonBehavioral]];

    [self.tester validateDataContains: [self getDataFromSut]
                              allKeys: allKeys];
}

- (void)test_does_not_contain_attributes_from_PII_passed_by_web_view_when_non_behaviour_true {
    [self.tester commitAllTestData];

    [[self.tester privateStorage] set: [UADSJsonStorageKeyNames piiContainerKey]
                                value : self.piiFullContentData];

    BOOL shouldIncludeNonBehavioral = YES;
    BOOL nonBehaviouralFlag = YES;

    [self setExpectedPrivacyModeTo: kUADSPrivacyModeMixed
           withUserBehaviouralFlag: nonBehaviouralFlag];

    NSArray *allKeys = [self.tester allExpectedKeys];

    allKeys = [allKeys arrayByAddingObjectsFromArray: [self.tester expectedPrivacyModeKeysWitNonBehavioral: shouldIncludeNonBehavioral]];

    [self.tester validateDataContains: [self getDataFromSut]
                              allKeys: allKeys];
}

@end
