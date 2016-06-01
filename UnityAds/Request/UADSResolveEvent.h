#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityAdsResolveEvent) {
    kUnityAdsResolveEventComplete,
    kUnityAdsResolveEventFailed
};

NSString *NSStringFromResolveEvent(UnityAdsResolveEvent);