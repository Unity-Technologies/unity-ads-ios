#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityAdsWebRequestError) {
    kUnityAdsWebRequestErrorRequestTimedOut = 5,
    kUnityAdsWebRequestGenericError = 10,
    kUnityAdsWebRequestErrorMappingHeadersFailed
};

NSString *NSStringFromWebRequestError(UnityAdsWebRequestError);
