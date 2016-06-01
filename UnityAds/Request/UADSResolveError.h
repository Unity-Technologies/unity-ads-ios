#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityAdsResolveError) {
    kUnityAdsResolveErrorTimedOut,
    kUnityAdsResolveErrorUnknownHost,
    kUnityAdsResolveErrorUnexpectedException
};

NSString *NSStringFromResolveError(UnityAdsResolveError);