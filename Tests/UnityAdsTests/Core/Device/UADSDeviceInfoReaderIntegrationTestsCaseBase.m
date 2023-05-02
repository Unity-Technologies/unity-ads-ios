
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

    builder.clientConfig = [UADSFactoryConfigMock new];
    builder.metricsSender = self.metricsMock;
    builder.extendedReader = self.isDeviceInfoReaderExtended;
    builder.privacyReader = self.privacyStorageMock;
    builder.currentTimeStampReader = [UADSCurrentTimestampMock new];
    builder.gameSessionIdReader = [UADSGameSessionIdReaderBase new];
    builder.sharedSessionIdReader = [UADSSharedSessionIdReaderBase new];
    id<UADSDeviceInfoReader> reader = builder.defaultReader;

    return [reader getDeviceInfoForGameMode: UADSGameModeMix];
}

- (BOOL)isDeviceInfoReaderExtended {
    return true;
}

- (void)validateMetrics: (NSArray<UADSMetric *> *)expectedMetrics {
    XCTAssertEqualObjects(self.metricsMock.sentMetrics, expectedMetrics);
}

- (void)setExpectedUserBehaviouralFlag: (BOOL)flag {
    [self.tester commitNonBehavioral: flag];
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

- (NSArray *)allExpectedKeysWithNonBehavioral: (BOOL)withUserNonBehavioral  {
    return  [_tester allExpectedKeysWithNonBehavioral: withUserNonBehavioral];
}
- (NSArray *)allExpectedKeys {
    return [_tester allExpectedKeys];
}

- (NSArray *)expectedKeysWithPIIWithNonBehavioral: (BOOL)withUserNonBehavioral {
    NSArray *allKeys = [self allExpectedKeysWithNonBehavioral: withUserNonBehavioral];
    allKeys = [allKeys arrayByAddingObjectsFromArray: self.piiExpectedData.allKeys];
    return allKeys;
}

- (NSArray *)expectedMinKeys {
    return [self.tester allExpectedKeysFromMinInfoWithUserNonBehavioral:true];
}

- (NSArray *)expectedMinKeysWithoutNonBehavioral {
    return [self.tester allExpectedKeysFromMinInfoWithUserNonBehavioral:false];
}

- (void)setPrivacyResponseState: (UADSPrivacyResponseState)state {
    self.privacyStorageMock.expectedState = state;
}

- (void)setShouldSendNonBehavioural: (BOOL)flag {
    self.privacyStorageMock.shouldSendUserNonBehavioral = flag;
}



@end
