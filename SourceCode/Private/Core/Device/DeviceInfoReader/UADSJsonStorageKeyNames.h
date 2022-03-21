#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
extern NSString *const kVendorIDKey;
extern NSString *const kAdvertisingTrackingIdKey;
extern NSString *const kMediationContainerName;
extern NSString *const kPrivacyContainerName;
extern NSString *const kGDPRContainerName;
extern NSString *const kFrameworkContainerName;
extern NSString *const kAdapterContainerName;
extern NSString *const kUnityContainerName;
extern NSString *const kPIPLContainerName;
extern NSString *const kConfigurationContainerName;
extern NSString *const kWebViewNativeBridgeDataKey;
extern NSString *const kWebViewDataPIIKey;
extern NSString *const kWebViewExcludeDeviceInfoFieldsKey;
extern NSString *const kUADSUserContainerName;
extern NSString *const kUADSStorageIDFIKey;
extern NSString *const kUADSStorageAnalyticSessionKey;
extern NSString *const kUADSStorageAnalyticUserKey;

@interface UADSJsonStorageKeyNames : NSObject
+ (NSString *)webViewContainerKey;
+ (NSString *)webViewDataKey;
+ (NSString *)piiContainerKey;
+ (NSString *)excludeDeviceInfoKey;
+ (NSString *)attributeKeyForPIIContainer: (NSString *)attribute;
+ (NSString *)webViewDataGameSessionIdKey;
+ (NSString *)privacyModeKey;
+ (NSString *)userNonBehavioralValueFlagKey;
+ (NSString *)userNonbehavioralValueFlagKey;
+ (NSString *)userNonBehavioralFlagKey;
+ (NSString *)privacySPMModeKey;
@end

NS_ASSUME_NONNULL_END
