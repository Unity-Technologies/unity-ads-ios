#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityServicesResolveEvent) {
    kUnityServicesResolveEventComplete,
    kUnityServicesResolveEventFailed
};

NSString *USRVNSStringFromResolveEvent(UnityServicesResolveEvent);
