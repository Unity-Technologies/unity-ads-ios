#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityAdsWebPlayerWebSettings) {
    kUnityAdsWebPlayerWebSettingsAllowsInlineMediaPlayback,
    kUnityAdsWebPlayerWebSettingsMediaPlaybackRequiresUserAction,
    kUnityAdsWebPlayerWebSettingsTypesRequiringAction,
    kUnityAdsWebPlayerWebSettingsScalesPagesToFit,
    kUnityAdsWebPlayerWebSettingsJavaScriptEnabled,
    kUnityAdsWebPlayerWebSettingsJavaScriptCanOpenWindowsAutomatically,
    kUnityAdsWebPlayerWebSettingsMediaPlaybackAllowsAirPlay,
    kUnityAdsWebPlayerWebSettingsSuppressesIncrementalRendering,
    kUnityAdsWebPlayerWebSettingsKeyboardDisplayRequiresUserAction,
    kUnityAdsWebPlayerWebSettingsIgnoresViewportScaleLimits,
    kUnityAdsWebPlayerWebSettingsDataDetectorTypes,
    kUnityAdsWebPlayerWebSettingsScrollEnabled
};

NSString *NSStringFromWebPlayerWebSetting(UnityAdsWebPlayerWebSettings);
