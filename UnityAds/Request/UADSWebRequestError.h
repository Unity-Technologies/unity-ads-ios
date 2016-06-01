#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityAdsWebRequestError) {
    kUnityAdsWebRequestErrorRequestTimedOut = 5,
    kUnityAdsWebRequestGenericError = 10
};

NSString *NSStringFromWebRequestError(UnityAdsWebRequestError);