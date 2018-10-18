#import "UADSWebPlayerSettings.h"

static NSString *unityAdsWebPlayerWebSettingsAllowsInlineMediaPlayback = @"allowsPlayback";
static NSString *unityAdsWebPlayerWebSettingsMediaPlaybackRequiresUserAction = @"playbackRequiresAction";
static NSString *unityAdsWebPlayerWebSettingsMediaTypesRequiringUserAction = @"typesRequiringAction";
static NSString *unityAdsWebPlayerWebSettingsScalesPagesToFit = @"scalesPagesToFit";
static NSString *unityAdsWebPlayerWebSettingsJavaScriptEnabled = @"javaScriptEnabled";
static NSString *unityAdsWebPlayerWebSettingsJavaScriptCanOpenWindowsAutomatically = @"javaScriptCanOpenWindowsAutomatically";
static NSString *unityAdsWebPlayerWebSettingsMediaPlaybackAllowsAirPlay = @"mediaPlaybackAllowsAirPlay";
static NSString *unityAdsWebPlayerWebSettingsSuppressesIncrementalRendering = @"suppressesIncrementalRendering";
static NSString *unityAdsWebPlayerWebSettingsKeyboardDisplayRequiresUserAction = @"keyboardDisplayRequiresUserAction";
static NSString *unityAdsWebPlayerWebSettingsIgnoresViewportScaleLimits = @"ignoresViewportScaleLimits";
static NSString *unityAdsWebPlayerWebSettingsDataDetectorTypes = @"dataDetectorTypes";
static NSString *unityAdsWebPlayerWebSettingsScrollEnabled = @"scrollEnabled";

NSString *NSStringFromWebPlayerWebSetting(UnityAdsWebPlayerWebSettings setting) {
    switch (setting) {
        case kUnityAdsWebPlayerWebSettingsAllowsInlineMediaPlayback:
            return unityAdsWebPlayerWebSettingsAllowsInlineMediaPlayback;
        case kUnityAdsWebPlayerWebSettingsMediaPlaybackRequiresUserAction:
            return unityAdsWebPlayerWebSettingsMediaPlaybackRequiresUserAction;
        case kUnityAdsWebPlayerWebSettingsTypesRequiringAction:
            return unityAdsWebPlayerWebSettingsMediaTypesRequiringUserAction;
        case kUnityAdsWebPlayerWebSettingsScalesPagesToFit:
            return unityAdsWebPlayerWebSettingsScalesPagesToFit;
        case kUnityAdsWebPlayerWebSettingsJavaScriptEnabled:
            return unityAdsWebPlayerWebSettingsJavaScriptEnabled;
        case kUnityAdsWebPlayerWebSettingsJavaScriptCanOpenWindowsAutomatically:
            return unityAdsWebPlayerWebSettingsJavaScriptCanOpenWindowsAutomatically;
        case kUnityAdsWebPlayerWebSettingsMediaPlaybackAllowsAirPlay:
            return unityAdsWebPlayerWebSettingsMediaPlaybackAllowsAirPlay;
        case kUnityAdsWebPlayerWebSettingsSuppressesIncrementalRendering:
            return unityAdsWebPlayerWebSettingsSuppressesIncrementalRendering;
        case kUnityAdsWebPlayerWebSettingsKeyboardDisplayRequiresUserAction:
            return unityAdsWebPlayerWebSettingsKeyboardDisplayRequiresUserAction;
        case kUnityAdsWebPlayerWebSettingsIgnoresViewportScaleLimits:
            return unityAdsWebPlayerWebSettingsIgnoresViewportScaleLimits;
        case kUnityAdsWebPlayerWebSettingsDataDetectorTypes:
            return unityAdsWebPlayerWebSettingsDataDetectorTypes;
        case kUnityAdsWebPlayerWebSettingsScrollEnabled:
            return unityAdsWebPlayerWebSettingsScrollEnabled;
    }
}

