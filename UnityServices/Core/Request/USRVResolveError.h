#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityServicesResolveError) {
    kUnityServicesResolveErrorTimedOut,
    kUnityServicesResolveErrorUnknownHost,
    kUnityServicesResolveErrorInvalidHost
};

NSString *NSStringFromResolveError(UnityServicesResolveError);
