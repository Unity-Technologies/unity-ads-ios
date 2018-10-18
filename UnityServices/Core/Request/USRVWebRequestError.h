#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityServicesWebRequestError) {
    kUnityServicesWebRequestErrorRequestTimedOut = 5,
    kUnityServicesWebRequestGenericError = 10,
    kUnityServicesWebRequestErrorMappingHeadersFailed
};

NSString *NSStringFromWebRequestError(UnityServicesWebRequestError);
