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
#import "UADSPrivacyMetrics.h"
#import "NSArray+SafeOperations.h"
#import "UADSCurrentTimestampMock.h"

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
    return [self.expectedMinimumDataRealStorage uads_newdictionaryByMergingWith: @{
                @"mediation.adapter_version": @"0.3.0",
                @"mediation.name": @"UnityOpenMediation",
                @"mediation.version": @"1.0",
                @"framework.version": @"1.0",
                @"framework.name": @"Unity",
                @"adapter.version": @"1.0",
                @"adapter.name": @"Packman",
                @"configuration.hasInitialized": @NO,
                [self webViewDataKeyFor: @"sessionID"]: @"sessionID",
                [self userDataKeyFor: @"requestToReadyTime"]: @"requestToReadyTime",
                [self userDataKeyFor: @"clickCount"]: @(10),
                [self userDataKeyFor: @"requestCount"]: @(10),
    }];
}

- (NSArray *)allExpectedKeysFromMinInfo {
    return [self.expectedKeysFromDefaultMinInfo arrayByAddingObjectsFromArray: self.expectedMinimumDataRealStorage.allKeys];
}

- (NSDictionary *)expectedMinimumDataRealStorage {
    return @{
        @"gdpr.consent": @NO,
        @"pipl.consent": @YES,
        @"privacy.consent": @YES,
        @"privacy.useroveragelimit": @YES,
        @"unity.privacy.permissions.ads": @YES,
        @"unity.privacy.permissions.external": @YES,
        @"unity.privacy.permissions.gameExp": @NO,
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

- (NSArray *)expectedKeysFromDefaultMinInfo {
    return @[
        kUADSDeviceInfoIDFIKey,
        kUADSDeviceInfoReaderPlatformKey,
        kUADSDeviceInfoLimitAdTrackingKey,
        kUADSDeviceInfoDeviceTrackingAuthStatusKey,
        kUADSDeviceInfoGameIDKey,
        UADSJsonStorageKeyNames.webViewDataGameSessionIdKey,
        kUADSDeviceInfoReaderSDKVersionNameKey,
        kUADSDeviceInfoReaderSDKVersionKey,
        UADSJsonStorageKeyNames.userNonBehavioralFlagKey
    ];
}

- (NSArray *)expectedKeysFromDefaultInfo {
    return [self.expectedKeysFromDefaultMinInfo arrayByAddingObjectsFromArray: @[
                kUADSDeviceInfoReaderBundleIDKey,
                kUADSDeviceInfoReaderBundleVersionKey,
                kUADSDeviceInfoReaderConnectionTypeKey,
                kUADSDeviceInfoReaderNetworkTypeKey,
                kUADSDeviceInfoReaderScreenHeightKey,
                kUADSDeviceInfoReaderScreenWidthKey,
                kUADSDeviceInfoReaderEncryptedKey,
                kUADSDeviceInfoReaderRootedKey,
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
                kUADSDeviceInfoDeviceNetworkOperatorKey,
                kUADSDeviceInfoDeviceNetworkOperatorNameKey,
                kUADSDeviceInfoDeviceScreenScaleKey,
                kUADSDeviceInfoIsSimulatorKey,
                kUADSDeviceInfoLimitTimeZoneKey,
                kUADSDeviceInfoLimitStoresKey,
                kUADSDeviceInfoCPUCountKey,
                kUADSDeviceInfoWebViewAgentKey,
                kUADSDeviceInfoAppStartTimestampKey,
                kUADSDeviceInfoAppInForegroundKey,
                kUADSDeviceInfoCurrentTimestampKey,
                kUADSDeviceInfoTimeZoneOffsetKey,
                kUADSDeviceInfoBuiltSDKVersionKey,
                kUADSDeviceInfoAnalyticSessionIDKey,
                kUADSDeviceInfoAnalyticUserIDKey
    ]];
}

- (NSArray *)allExpectedKeys {
    return [self.expectedKeysFromDefaultInfo arrayByAddingObjectsFromArray: self.expectedMergedDataRealStorage.allKeys];
}

- (void)validateDataContains: (NSDictionary *)data allKeys: (NSArray *)keys {
    NSUInteger counter = data.allKeys.count > keys.count ? data.allKeys.count : keys.count;
    NSArray *inputSorted = data.allKeys.defaultSorted;
    NSArray *expected = keys.defaultSorted;

    for (int i = 0; i < counter; i++) {
        id receivedElement = [inputSorted uads_getItemSafelyAtIndex: i];
        id expectedElement = [expected uads_getItemSafelyAtIndex: i];
        XCTAssertEqualObjects(receivedElement,
                              expectedElement,
                              @"Expect %@ to be equal to %@ at index: %i", receivedElement, expectedElement, i);

        if (![receivedElement isEqual: expectedElement]) {
            break;
        }
    }
}

- (NSArray *)expectedPrivacyModeKey {
    return @[@"privacy.mode"];
}

- (NSArray <UADSMetric *> *)missedDataMetrics {
    return @[
        [UADSTsiMetric newMissingToken],
        [UADSTsiMetric newMissingStateId],
    ];
}

- (UADSMetric *)tsiNoSessionIDMetrics {
    return [UADSTsiMetric newMissingGameSessionId];
}

- (UADSMetric *)infoCollectionLatencyMetrics {
    return [UADSTsiMetric newDeviceInfoCollectionLatency: UADSCurrentTimestampMock.mockedDuration];
}

- (UADSMetric *)privacyRequestLatencyMetrics {
    return [UADSPrivacyMetrics newPrivacyRequestSuccessLatency: self.retryTags];
}

- (UADSMetric *)privacyRequestFailureWithReason: (UADSPrivacyLoaderError)reason {
    NSMutableDictionary *tags = [NSMutableDictionary dictionary];

    tags[@"reason"] = uads_privacyErrorTypeToString(reason);
    [tags addEntriesFromDictionary: self.retryTags];
    return [UADSPrivacyMetrics newPrivacyRequestErrorLatency: tags];
}

- (UADSMetric *)configLatencySuccessMetric {
    return [UADSTsiMetric newTokenResolutionRequestLatency: nil
                                                      tags: self.retryTags];
}

- (UADSMetric *)configLatencyFailureMetricWithReason: (UADSConfigurationLoaderError)reason {
    NSMutableDictionary *tags = [NSMutableDictionary dictionary];

    tags[@"reason"] = uads_configurationErrorTypeToString(reason);
    [tags addEntriesFromDictionary: self.retryTags];
    return [UADSTsiMetric newTokenResolutionRequestFailureLatency: tags];
}

- (UADSMetric *)infoCompressionLatencyMetrics {
    return [UADSTsiMetric newDeviceInfoCompressionLatency: UADSCurrentTimestampMock.mockedDuration];
}

- (NSDictionary *)retryTags {
    return @{
        @"c_retry": @"1",
        @"wv_retry": @"2"
    };
}

@end
