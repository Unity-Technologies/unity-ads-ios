#import "UADSDeviceTestsHelper.h"
#import "UADSMetaData.h"
#import "UADSMediationMetaData.h"
#import "USRVStorageManager.h"
#import "UADSJsonStorageKeyNames.h"
#import "USRVPreferences.h"
#import "UADSDeviceInfoReaderKeys.h"
#import "NSArray+Sort.h"
#import "NSDictionary+Merge.h"
#import "UADSTsiMetric.h"
#import <XCTest/XCTest.h>

@implementation UADSDeviceTestsHelper

- (void)commitPIPLSMetaData {
    UADSMetaData *piplConsentMetaData = [UADSMetaData new];

    [piplConsentMetaData set: @"pipl.consent"
                       value : @YES];
    [piplConsentMetaData commit];
}

- (void)commitPrivacyMetaData {
    // If the user opts in to targeted advertising:
    UADSMetaData *privacyConsentMetaData = [UADSMetaData new];

    [privacyConsentMetaData set: @"privacy.consent"
                          value : @YES];
    [privacyConsentMetaData commit];

    UADSMetaData *ageGateMetaData = [[UADSMetaData alloc] init];

    [ageGateMetaData set: @"privacy.useroveragelimit"
                   value : @YES];
    [ageGateMetaData commit];
}

- (void)commitGDPRMetaData {
    // If the user opts out of targeted advertising:
    UADSMetaData *gdprConsentMetaData = [UADSMetaData new];

    [gdprConsentMetaData set: @"gdpr.consent"
                       value : @NO];
    [gdprConsentMetaData commit];
}

- (void)commitMediationMetaData {
    UADSMediationMetaData *mediationMetaData = [[UADSMediationMetaData alloc] init];

    [mediationMetaData setName: @"UnityOpenMediation"];
    [mediationMetaData setVersion: @"1.0"];
    [mediationMetaData set: @"adapter_version"
                     value : @"0.3.0"];
    [mediationMetaData commit];
}

- (void)commitDataThatShouldBeFiltered {
    UADSMetaData *dataToFilter = [UADSMetaData new];

    [dataToFilter set: @"somethingToBeFiltered.value"
                value : @NO];
    [dataToFilter commit];
}

- (void)commitFrameworkData {
    UADSMetaData *framework = [[UADSMetaData alloc] initWithCategory: @"framework"];

    [framework set: @"name"
             value : @"Unity"];
    [framework set: @"version"
             value : @"1.0"];
    [framework commit];
}

- (void)commitAdapterData {
    UADSMetaData *framework = [[UADSMetaData alloc] initWithCategory: @"adapter"];

    [framework set: @"name"
             value : @"Packman"];
    [framework set: @"version"
             value : @"1.0"];
    [framework commit];
}

- (void)commitWebViewPrivacyData {
    UADSMetaData *webViewInitiated = [UADSMetaData new];

    [webViewInitiated set: @"unity.privacy.permissions.ads"
                    value : @YES];
    [webViewInitiated set: @"unity.privacy.permissions.external"
                    value : @YES];

    [webViewInitiated set: @"unity.privacy.permissions.gameExp"
                    value : @NO];
    [webViewInitiated commit];
}

- (void)commitWebViewExchangeData {
    NSString *sessionIDKey = [self webViewDataKeyFor: @"sessionID"];

    [self.privateStorage set: sessionIDKey
                       value : @"sessionID"];

    NSString *gameSessionIDKey = [self webViewDataKeyFor: @"gameSessionId"];

    [self.privateStorage set: gameSessionIDKey
                       value : @"gameSessionId"];
}

- (void)commitConfigurationData {
    UADSMetaData *configurationData = [UADSMetaData new];

    [configurationData set: @"configuration.hasInitialized"
                     value : @NO];

    [configurationData commit];
}

- (void)commitUserData {
    [self.privateStorage set: [self userDataKeyFor: @"requestToReadyTime"]
                       value : @"requestToReadyTime"];
    [self.privateStorage set: [self userDataKeyFor: @"clickCount"]
                       value : @(10)];
    [self.privateStorage set: [self userDataKeyFor: @"requestCount"]
                       value : @(10)];
    [self.privateStorage set: [self userDataKeyFor: @"nonBehavioral"]
                       value : @(true)];
}

- (void)commitPrivacyMode: (UADSPrivacyMode)mode
         andNonBehavioral: (BOOL)flag {
    UADSMetaData *privacyData = [UADSMetaData new];

    [privacyData set: @"privacy.mode"
               value : uads_privacyModeString(mode)];

    [privacyData set: @"user.nonBehavioral"
               value : @(flag)];
    [privacyData commit];
}

- (void)setSMPPrivacyMode: (UADSPrivacyMode)mode {
    [self.privateStorage set: UADSJsonStorageKeyNames.privacySPMModeKey
                       value : uads_privacyModeString(mode)];
}

- (NSString *)piiKey {
    return [UADSJsonStorageKeyNames piiContainerKey];
}

- (void)commitAllTestData {
    [self commitGDPRMetaData];
    [self commitPrivacyMetaData];
    [self commitPIPLSMetaData];
    [self commitMediationMetaData];
    [self commitDataThatShouldBeFiltered];
    [self commitFrameworkData];
    [self commitAdapterData];
    [self commitWebViewPrivacyData];
    [self commitConfigurationData];
    [self commitWebViewExchangeData];
    [self commitUserData];
    [self commitUserDefaultsTestData];
}

- (void)commitUserDefaultsTestData {
    [self setIDFI];
    [self setAnalyticSessionID];
    [self setAnalyticUserID];
}

- (USRVStorage *)privateStorage {
    return [USRVStorageManager getStorage: kUnityServicesStorageTypePrivate];
}

- (USRVStorage *)publicStorage {
    return [USRVStorageManager getStorage: kUnityServicesStorageTypePublic];
}

- (void)clearAllStorages {
    [@[self.privateStorage, self.publicStorage] enumerateObjectsUsingBlock:^(USRVStorage *_Nonnull storage, NSUInteger idx, BOOL *_Nonnull stop) {
        [storage clearData];
        [storage clearStorage];
        [storage initStorage];
    }];

    [self resetUserDefaults];
}

- (NSDictionary *)expectedMergedDataRealStorage {
    return @{
        @"gdpr.consent": @NO,
        @"pipl.consent": @YES,
        @"privacy.consent": @YES,
        @"privacy.useroveragelimit": @YES,
        @"mediation.adapter_version": @"0.3.0",
        @"mediation.name": @"UnityOpenMediation",
        @"mediation.version": @"1.0",
        @"framework.version": @"1.0",
        @"framework.name": @"Unity",
        @"adapter.version": @"1.0",
        @"adapter.name": @"Packman",
        @"unity.privacy.permissions.ads": @YES,
        @"unity.privacy.permissions.external": @YES,
        @"unity.privacy.permissions.gameExp": @NO,
        @"configuration.hasInitialized": @NO,
        [self webViewDataKeyFor: @"sessionID"]: @"sessionID",
        [self webViewDataKeyFor: @"gameSessionId"]: @"gameSessionId",
        [self userDataKeyFor: @"requestToReadyTime"]: @"requestToReadyTime",
        [self userDataKeyFor: @"clickCount"]: @(10),
        [self userDataKeyFor: @"requestCount"]: @(10),
    };
}

- (NSString *)webViewDataKeyFor: (NSString *)child {
    return [[UADSJsonStorageKeyNames webViewDataKey] stringByAppendingFormat: @".%@", child];
}

- (NSString *)userDataKeyFor: (NSString *)child {
    return [kUADSUserContainerName stringByAppendingFormat: @".%@", child];
}

- (NSString *)idfiMockValue {
    return @"idfi-value";
}

- (NSString *)analyticSessionMockValue {
    return @"analytic-session-value";
}

- (NSString *)analyticUserMockValue {
    return @"analytic-user-value";
}

- (void)setIDFI {
    [USRVPreferences setString: self.idfiMockValue
                        forKey: kUADSStorageIDFIKey];
}

- (void)setAnalyticSessionID {
    [USRVPreferences setString: self.analyticSessionMockValue
                        forKey: kUADSStorageAnalyticSessionKey];
}

- (void)setAnalyticUserID {
    [USRVPreferences setString: self.analyticUserMockValue
                        forKey: kUADSStorageAnalyticUserKey];
}

- (void)resetUserDefaults {
    [USRVPreferences removeKey: kUADSStorageAnalyticSessionKey];
    [USRVPreferences removeKey: kUADSStorageAnalyticUserKey];
    [USRVPreferences removeKey: kUADSStorageIDFIKey];
    [NSUserDefaults resetStandardUserDefaults];
}

- (NSDictionary *)piiDecisionContentData {
    return @{
        [UADSJsonStorageKeyNames attributeKeyForPIIContainer: kVendorIDKey]: kVendorIDKey,
        [UADSJsonStorageKeyNames attributeKeyForPIIContainer: kAdvertisingTrackingIdKey]: kAdvertisingTrackingIdKey
    };
}

- (NSDictionary *)piiDecisionContentDataWithUserBehavioral: (BOOL)flag {
    return [self.piiDecisionContentData uads_newdictionaryByMergingWith: @{
                [UADSJsonStorageKeyNames userNonBehavioralFlagKey]: @(flag)
    }];
}

- (void)setPIIDataToStorage {
    [self saveExpectedContentToJSONStorage: self.fullStorageMockData];
}

- (NSDictionary *)fullStorageMockData {
    return @{
        self.piiKey: @{
            kVendorIDKey: kVendorIDKey,
            kAdvertisingTrackingIdKey: kAdvertisingTrackingIdKey
        }
    };
}

- (void)saveExpectedContentToJSONStorage: (NSDictionary *)content {
    for (NSString *key in content.allKeys) {
        [self.privateStorage set: key
                           value : content[key]];
    }
}

- (NSArray *)expectedKeysFromDefaultInfo {
    return @[
        kUADSDeviceInfoReaderBundleIDKey,
        kUADSDeviceInfoReaderBundleVersionKey,
        kUADSDeviceInfoReaderConnectionTypeKey,
        kUADSDeviceInfoReaderNetworkTypeKey,
        kUADSDeviceInfoReaderScreenHeightKey,
        kUADSDeviceInfoReaderScreenWidthKey,
        kUADSDeviceInfoReaderEncryptedKey,
        kUADSDeviceInfoReaderPlatformKey,
        kUADSDeviceInfoReaderRootedKey,
        kUADSDeviceInfoReaderSDKVersionKey,
        kUADSDeviceInfoReaderOSVersionKey,
        kUADSDeviceInfoReaderDeviceModelKey,
        kUADSDeviceInfoReaderLanguageKey,
        kUADSDeviceInfoReaderIsTestModeKey,
        kUADSDeviceInfoReaderFreeMemoryKey,
        kUADSDeviceInfoReaderBatteryStatusKey,
        kUADSDeviceInfoReaderBatteryLevelKey,
        kUADSDeviceInfoReaderScreenBrightnessKey,
        kUADSDeviceInfoReaderVolumeKey,
        kUADSDeviceInfoDeviceFreeSpaceKey,
        kUADSDeviceInfoDeviceTotalSpaceKey,
        kUADSDeviceInfoDeviceTotalMemoryKey,
        kUADSDeviceInfoDeviceDeviceNameKey,
        kUADSDeviceInfoDeviceLocaleListKey,
        kUADSDeviceInfoDeviceCurrentUiThemeKey,
        kUADSDeviceInfoDeviceAdNetworkPlistKey,
        kUADSDeviceInfoDeviceIsWiredHeadsetOnKey,
        kUADSDeviceInfoDeviceSystemBootTimeKey,
        kUADSDeviceInfoDeviceTrackingAuthStatusKey,
        kUADSDeviceInfoDeviceNetworkOperatorKey,
        kUADSDeviceInfoDeviceNetworkOperatorNameKey,
        kUADSDeviceInfoDeviceScreenScaleKey,
        kUADSDeviceInfoIsSimulatorKey,
        kUADSDeviceInfoLimitAdTrackingKey,
        kUADSDeviceInfoLimitTimeZoneKey,
        kUADSDeviceInfoLimitStoresKey,
        kUADSDeviceInfoCPUCountKey,
        kUADSDeviceInfoWebViewAgentKey,
        kUADSDeviceInfoIDFIKey,
        kUADSDeviceInfoAppStartTimestampKey,
        kUADSDeviceInfoAppInForegroundKey,
        kUADSDeviceInfoCurrentTimestampKey,
        kUADSDeviceInfoTimeZoneOffsetKey,
        kUADSDeviceInfoBuiltSDKVersionKey,
        kUADSDeviceInfoAnalyticSessionIDKey,
        kUADSDeviceInfoAnalyticUserIDKey
    ];
}

- (NSArray *)allExpectedKeys {
    return [self.expectedKeysFromDefaultInfo arrayByAddingObjectsFromArray: self.expectedMergedDataRealStorage.allKeys];
}

- (void)validateDataContains: (NSDictionary *)data allKeys: (NSArray *)keys {
    NSUInteger counter = data.allKeys.count > keys.count ? data.allKeys.count : keys.count;
    NSArray *inputSorted = data.allKeys.defaultSorted;
    NSArray *expected = keys.defaultSorted;

    for (int i = 0; i < counter; i++) {
        XCTAssertEqualObjects(inputSorted[i], expected[i], @"Expect %@ to be equal to %@ at index: %i", inputSorted[i], expected[i], i);

        if (![inputSorted[i] isEqual: expected[i]]) {
            break;
        }
    }
}

- (NSArray *)expectedPrivacyModeKeysWitNonBehavioral: (BOOL)include {
    NSArray *keys = @[@"privacy.mode"];

    if (include) {
        keys = [keys arrayByAddingObject: UADSJsonStorageKeyNames.userNonBehavioralFlagKey];
    }

    return keys;
}

- (NSArray <UADSMetric *> *)missedDataMetrics {
    return @[
        [UADSTsiMetric newMissingTokenWithTags: self.expectedTags],
        [UADSTsiMetric newMissingStateIdWithTags: self.expectedTags],
    ];
}

- (UADSMetric *)tsiNoSessionIDMetrics {
    return [UADSTsiMetric newMissingGameSessionIdWithTags: self.expectedTags];
}

- (UADSMetric *)emergencyOffMetrics {
    return [UADSTsiMetric newEmergencySwitchOffWithTags: self.expectedTags];
}

- (UADSMetric *)infoCollectionLatencyMetrics {
    return [UADSTsiMetric newDeviceInfoCollectionLatency: @(0)
                                                withTags: self.expectedTags];
}

- (UADSMetric *)infoCompressionLatencyMetrics {
    return [UADSTsiMetric newDeviceInfoCompressionLatency: @(0)
                                                 withTags: self.expectedTags];
}

- (NSDictionary *)expectedTags {
    return @{
        @"tag1": @"value1"
    };
}

@end
