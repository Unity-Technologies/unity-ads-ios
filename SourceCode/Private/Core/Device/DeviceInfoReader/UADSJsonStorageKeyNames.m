#import "UADSJsonStorageKeyNames.h"
#import "UADSDeviceInfoReaderKeys.h"

static NSString *const kWebViewContainerKey = @"unifiedconfig";
NSString *const kWebViewExcludeDeviceInfoFieldsKey = @"exclude";
NSString *const kWebViewDataPIIKey = @"pii";

NSString *const kWebViewNativeBridgeDataKey = @"data";
NSString *const kVendorIDKey = @"vendorIdentifier";
NSString *const kAdvertisingTrackingIdKey = @"advertisingTrackingId";
NSString *const kPrivacyModeKey = @"mode";
NSString *const kSPMPrivacyValueKey = @"value";

NSString *const kMediationContainerName = @"mediation";
NSString *const kPrivacyContainerName = @"privacy";
NSString *const kGDPRContainerName = @"gdpr";
NSString *const kFrameworkContainerName = @"framework";
NSString *const kAdapterContainerName = @"adapter";
NSString *const kUnityContainerName = @"unity";
NSString *const kPIPLContainerName = @"pipl";
NSString *const kConfigurationContainerName = @"configuration";

NSString *const kUADSStorageIDFIKey = @"unityads-idfi";
NSString *const kUADSUserContainerName = @"user";
NSString *const kPrivacySPMKey = @"spm";

NSString *const kUADSStorageAnalyticSessionKey = @"unity.player_sessionid";
NSString *const kUADSStorageAnalyticUserKey = @"unity.cloud_userid";


NSString *const kUADSSdkServiceModeKey = @"sdk.mode.value";

@implementation UADSJsonStorageKeyNames
+ (NSString *)webViewContainerKey {
    return kWebViewContainerKey;
}

+ (NSString *)webViewDataKey {
    return [self.webViewContainerKey stringByAppendingFormat: @".%@", kWebViewNativeBridgeDataKey];
}

+ (NSString *)piiContainerKey {
    return [self.webViewContainerKey stringByAppendingFormat: @".%@", kWebViewDataPIIKey];
}

+ (NSString *)excludeDeviceInfoKey {
    return [self.webViewContainerKey stringByAppendingFormat: @".%@", kWebViewExcludeDeviceInfoFieldsKey];
}

+ (NSString *)attributeKeyForPIIContainer: (NSString *)attribute {
    return [[self piiContainerKey] stringByAppendingFormat: @".%@", attribute];
}

+ (NSString *)webViewDataGameSessionIdKey {
    return [self.webViewDataKey stringByAppendingFormat: @".%@", kUADSDeviceInfoGameSessionIdKey];
}

+ (NSString *)privacyModeKey {
    return [kPrivacyContainerName stringByAppendingFormat: @".%@.value", kPrivacyModeKey];
}

+ (NSString *)privacySPMModeKey {
    return [kPrivacyContainerName stringByAppendingFormat: @".%@.%@", kPrivacySPMKey, kSPMPrivacyValueKey];
}

+ (NSString *)userNonBehavioralValueFlagKey {
    return [self.userNonBehavioralFlagKey stringByAppendingString: @".value"];
}

+ (NSString *)userNonbehavioralValueFlagKey {
    return [kUADSUserContainerName stringByAppendingFormat: @".%@", @"nonbehavioral.value"];
}

+ (NSString *)userNonBehavioralFlagKey  {
    return [kUADSUserContainerName stringByAppendingFormat: @".%@", @"nonBehavioral"];
}

@end
