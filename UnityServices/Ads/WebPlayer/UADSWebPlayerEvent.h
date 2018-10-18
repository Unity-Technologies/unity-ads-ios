#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityAdsWebPlayerEvent) {
    kUnityAdsWebPlayerPageStarted,
    kUnityAdsWebPlayerPageFinished,
    kUnityAdsWebPlayerError,
    kUnityAdsWebPlayerEvent,
    kUnityAdsWebPlayerShouldOverrideURLLoading,
    kUnityAdsWebPlayerCreateWebView
};

NSString *NSStringFromWebPlayerEvent(UnityAdsWebPlayerEvent);
