
#import "UADSDeviceInfoReaderIntegrationTestsCaseBase.h"
#import "UADSFactoryConfigMock.h"
#import "UADSDeviceInfoReaderBuilder.h"
#import "UADSJsonStorageKeyNames.h"
#import "NSDictionary+Filter.h"
#import "UADSCurrentTimestampMock.h"

@implementation UADSDeviceInfoReaderIntegrationTestsCaseBase
- (void)setUp {
    self.tester = [UADSDeviceTestsHelper new];
    self.metricsMock = [SDKMetricsSenderMock new];
    self.privacyStorageMock = [UADSPrivacyStorageMock new];
    [self.tester clearAllStorages];
}

- (NSDictionary *)getDataFromSut {
    UADSDeviceInfoReaderBuilder *builder = [UADSDeviceInfoReaderBuilder new];

    builder.selectorConfig = self.privacyConfig;
    builder.metricsSender = self.metricsMock;
    builder.extendedReader = self.isDeviceInfoReaderExtended;
    builder.privacyReader = self.privacyStorageMock;
    builder.currentTimeStampReader = [UADSCurrentTimestampMock new];
    id<UADSDeviceInfoReader> reader = builder.defaultReader;

    return [reader getDeviceInfoForGameMode: UADSGameModeMix];
}

- (id<UADSPrivacyConfig, UADSClientConfig>)privacyConfig {
    return [UADSFactoryConfigMock new];
}

- (BOOL)isDeviceInfoReaderExtended {
    return true;
}

- (void)validateMetrics: (NSArray<UADSMetric *> *)expectedMetrics {
    XCTAssertEqualObjects(self.metricsMock.sentMetrics, expectedMetrics);
}

- (void)setExpectedPrivacyModeTo: (UADSPrivacyMode)mode
         withUserBehaviouralFlag: (BOOL)flag {
    [self.tester commitPrivacyMode: mode
                  andNonBehavioral: flag];
}

- (NSDictionary *)piiExpectedData {
    return [self.piiFullContentData uads_mapKeys:^id _Nonnull (id _Nonnull key) {
        return [self finalKey: key];
    }];
}

- (NSString *)finalKey: (NSString *)original {
    return [UADSJsonStorageKeyNames attributeKeyForPIIContainer: original];
}

- (NSDictionary *)piiFullContentData {
    return @{
        kVendorIDKey: kVendorIDKey,
        kAdvertisingTrackingIdKey: kAdvertisingTrackingIdKey
    };
}

- (NSArray *)expectedKeysNoPIIIncludeNonBehavioral: (BOOL)include  {
    NSArray *allKeys = [_tester allExpectedKeys];

    if (include) {
        allKeys = [allKeys arrayByAddingObject: UADSJsonStorageKeyNames.userNonBehavioralFlagKey];
    }

    return allKeys;
}

- (NSArray *)expectedKeysNoPII {
    return [_tester allExpectedKeys];
}

- (NSArray *)expectedKeysWithPIIIncludeNonBehavioral: (BOOL)include {
    NSArray *allKeys = self.expectedKeysNoPII;

    allKeys = [allKeys arrayByAddingObjectsFromArray: self.piiExpectedData.allKeys];
    allKeys = [allKeys arrayByAddingObjectsFromArray: [self.tester expectedPrivacyModeKeysWitNonBehavioral: include]];
    return allKeys;
}

- (NSArray *)expectedKeysMinIncludeNonBehavioral: (BOOL)include {
    NSArray *allKeys = self.tester.allExpectedKeysFromMinInfo;

    allKeys = [allKeys arrayByAddingObjectsFromArray: [self.tester expectedPrivacyModeKeysWitNonBehavioral: include]];
    return allKeys;
}

- (void)setPrivacyResponseState: (UADSPrivacyResponseState)state {
    self.privacyStorageMock.expectedState = state;
}

@end
