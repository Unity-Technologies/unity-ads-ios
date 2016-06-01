#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityAdsWebRequestEvent) {
    kUnityAdsWebRequestEventComplete,
    kUnityAdsWebRequestEventFailed
};

NSString *NSStringFromWebRequestEvent(UnityAdsWebRequestEvent);