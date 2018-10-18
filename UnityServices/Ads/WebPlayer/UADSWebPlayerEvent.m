#import "UADSWebPlayerEvent.h"

static NSString *unityAdsWebPlayerPageStarted = @"PAGE_STARTED";
static NSString *unityAdsWebPlayerPageFinished = @"PAGE_FINISHED";
static NSString *unityAdsWebPlayerError = @"ERROR";
static NSString *unityAdsWebPlayerEvent = @"WEBPLAYER_EVENT";
static NSString *unityAdsWebPlayerShouldOverrideURLLoading = @"SHOULD_OVERRIDE_URL_LOADING";
static NSString *unityAdsWebPlayerCreateWebView = @"CREATE_WEBVIEW";

NSString *NSStringFromWebPlayerEvent(UnityAdsWebPlayerEvent event) {
    switch (event) {
        case kUnityAdsWebPlayerPageStarted:
            return unityAdsWebPlayerPageStarted;
        case kUnityAdsWebPlayerPageFinished:
            return unityAdsWebPlayerPageFinished;
        case kUnityAdsWebPlayerError:
            return unityAdsWebPlayerError;
        case kUnityAdsWebPlayerEvent:
            return unityAdsWebPlayerEvent;
        case kUnityAdsWebPlayerShouldOverrideURLLoading:
            return unityAdsWebPlayerShouldOverrideURLLoading;
        case kUnityAdsWebPlayerCreateWebView:
            return unityAdsWebPlayerCreateWebView;
    }
}

