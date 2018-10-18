#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityServicesWebRequestEvent) {
    kUnityServicesWebRequestEventComplete,
    kUnityServicesWebRequestEventFailed
};

NSString *NSStringFromWebRequestEvent(UnityServicesWebRequestEvent);
