#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityAdsResolveError) {
    kUnityAdsResolveErrorTimedOut,
    kUnityAdsResolveErrorUnknownHost,
    kUnityAdsResolveErrorInvalidHost
};

NSString *NSStringFromResolveError(UnityAdsResolveError);
