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
#import "ConfigurationMetricTagsReaderMock.h"
#import "UADSTsiMetric.h"
#import "XCTestCase+Convenience.h"

@interface UADSDeviceInfoReaderIntegrationTestsCase : XCTestCase
@property (nonatomic, strong) UADSDeviceTestsHelper *tester;
@property (nonatomic, strong) SDKMetricsSenderMock *metricsMock;
@property (nonatomic, strong) ConfigurationMetricTagsReaderMock *tagsReaderMock;
@end

@implementation UADSDeviceInfoReaderIntegrationTestsCase

- (void)setUp {
    self.tester = [UADSDeviceTestsHelper new];
    self.metricsMock = [SDKMetricsSenderMock new];
    self.tagsReaderMock = [ConfigurationMetricTagsReaderMock newWithExpectedTags: _tester.expectedTags];
    [_tester clearAllStorages];
}

- (void)test_contains_default_device_info {
    [_tester commitUserDefaultsTestData];
    [_tester validateDataContains: [self getDataFromSut]
                          allKeys: _tester.expectedKeysFromDefaultInfo];

    [self validateMetrics: @[
         _tester.infoCollectionLatencyMetrics,
         _tester.tsiNoSessionIDMetrics
    ]];
}

- (void)test_contains_attributes_from_the_storage {
    [_tester commitAllTestData];
    NSArray *allKeys = [_tester allExpectedKeys];

    [_tester validateDataContains: [self getDataFromSut]
                          allKeys: allKeys];
    [self validateMetrics: @[
         _tester.infoCollectionLatencyMetrics
    ]];
}

- (void)test_contains_attributes_from_PII_passed_by_web_view_when_non_behaviour_false {
    [_tester commitAllTestData];

    [[_tester privateStorage] set: [UADSJsonStorageKeyNames piiContainerKey]
                            value : self.piiFullContentData];

    BOOL shouldIncludeNonBehavioral = YES;
    BOOL nonBehaviouralFlag = NO;

    [self setExpectedPrivacyModeTo: kUADSPrivacyModeMixed
           withUserBehaviouralFlag: nonBehaviouralFlag];

    NSArray *allKeys = [_tester allExpectedKeys];

    allKeys = [allKeys arrayByAddingObjectsFromArray: self.piiExpectedData.allKeys];
    allKeys = [allKeys arrayByAddingObjectsFromArray: [_tester expectedPrivacyModeKeysWitNonBehavioral: shouldIncludeNonBehavioral]];

    [_tester validateDataContains: [self getDataFromSut]
                          allKeys: allKeys];
}

- (void)test_does_not_contain_attributes_from_PII_passed_by_web_view_when_non_behaviour_true {
    [_tester commitAllTestData];

    [[_tester privateStorage] set: [UADSJsonStorageKeyNames piiContainerKey]
                            value : self.piiFullContentData];

    BOOL shouldIncludeNonBehavioral = YES;
    BOOL nonBehaviouralFlag = YES;

    [self setExpectedPrivacyModeTo: kUADSPrivacyModeMixed
           withUserBehaviouralFlag: nonBehaviouralFlag];

    NSArray *allKeys = [_tester allExpectedKeys];

    allKeys = [allKeys arrayByAddingObjectsFromArray: [_tester expectedPrivacyModeKeysWitNonBehavioral: shouldIncludeNonBehavioral]];

    [_tester validateDataContains: [self getDataFromSut]
                          allKeys: allKeys];
}

- (NSDictionary *)piiFullContentData {
    return @{
        kVendorIDKey: kVendorIDKey,
        kAdvertisingTrackingIdKey: kAdvertisingTrackingIdKey
    };
}

- (NSDictionary *)piiExpectedData {
    return [self.piiFullContentData uads_mapKeys:^id _Nonnull (id _Nonnull key) {
        return [self finalKey: key];
    }];
}

- (NSString *)finalKey: (NSString *)original {
    return [UADSJsonStorageKeyNames attributeKeyForPIIContainer: original];
}

- (NSArray *)expectedKeysFromPIIInfo {
    return @[
        kVendorIDKey,
        kAdvertisingTrackingIdKey
    ];
}

- (void)validateMetrics: (NSArray<UADSMetric *> *)expectedMetrics {
    XCTAssertEqualObjects(_metricsMock.sentMetrics, expectedMetrics);
}

- (NSDictionary *)getDataFromSut {
    UADSFactoryConfigMock *config = [UADSFactoryConfigMock new];
    id<UADSDeviceInfoReader> reader = [[UADSDeviceInfoReaderBuilder new] defaultReaderWithConfig: config
                                                                                   metricsSender: self.metricsMock
                                                                                metricTagsReader: self.tagsReaderMock];

    return [reader getDeviceInfoForGameMode: UADSGameModeMix];
}

- (void)setExpectedPrivacyModeTo: (UADSPrivacyMode)mode
         withUserBehaviouralFlag: (BOOL)flag {
    [_tester commitPrivacyMode: mode
              andNonBehavioral: flag];
}

@end
