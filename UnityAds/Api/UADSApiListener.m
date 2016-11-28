#import "UADSApiListener.h"
#import "UADSWebViewCallback.h"
#import "UADSClientProperties.h"
#import "NSString+UnityAdsError.h"
#import "UnityAdsExtended.h"

UnityAdsFinishState UnityAdsFinishStateFromNSString (NSString* state) {
    if (state) {
        if ([state isEqualToString:@"COMPLETED"]) {
            return kUnityAdsFinishStateCompleted;
        }
        else if ([state isEqualToString:@"SKIPPED"]) {
            return kUnityAdsFinishStateSkipped;
        }
        else if ([state isEqualToString:@"ERROR"]) {
            return kUnityAdsFinishStateError;
        }
    }
    
    return -10000;
}

@implementation UADSApiListener

+ (void)WebViewExposed_sendReadyEvent:(NSString *)placementId callback:(UADSWebViewCallback *)callback {
    if ([UADSClientProperties getDelegate]) {
        if ([[UADSClientProperties getDelegate] respondsToSelector:@selector(unityAdsReady:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UADSClientProperties getDelegate] unityAdsReady:placementId];
            });
            [callback invoke:nil];
        }
        else {
            [callback error:NSStringFromListenerError(kUnityAdsCouldNotFindSelector) arg1:nil];
        }
    }
    else {
        [callback error:NSStringFromListenerError(kUnityAdsDelegateNull) arg1:nil];
    }
}

+ (void)WebViewExposed_sendStartEvent:(NSString *)placementId callback:(UADSWebViewCallback *)callback {
    if ([UADSClientProperties getDelegate]) {
        if ([[UADSClientProperties getDelegate] respondsToSelector:@selector(unityAdsDidStart:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UADSClientProperties getDelegate] unityAdsDidStart:placementId];
            });
            [callback invoke:nil];
        }
        else {
            [callback error:NSStringFromListenerError(kUnityAdsCouldNotFindSelector) arg1:nil];
        }
    }
    else {
        [callback error:NSStringFromListenerError(kUnityAdsDelegateNull) arg1:nil];
    }
}

+ (void)WebViewExposed_sendFinishEvent:(NSString *)placementId result:(NSString *)result callback:(UADSWebViewCallback *)callback {
    if ([UADSClientProperties getDelegate]) {
        if ([[UADSClientProperties getDelegate] respondsToSelector:@selector(unityAdsDidFinish:withFinishState:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UnityAdsFinishState state = UnityAdsFinishStateFromNSString(result);
                if ((int)state != -10000) {
                    [[UADSClientProperties getDelegate] unityAdsDidFinish:placementId withFinishState:state];
                }
            });
            [callback invoke:nil];
        }
        else {
            [callback error:NSStringFromListenerError(kUnityAdsCouldNotFindSelector) arg1:nil];
        }
    }
    else {
        [callback error:NSStringFromListenerError(kUnityAdsDelegateNull) arg1:nil];
    }
}

+ (void)WebViewExposed_sendClickEvent:(NSString *)placementId callback:(UADSWebViewCallback *)callback {
    if ([UADSClientProperties getDelegate] && [[UADSClientProperties getDelegate] conformsToProtocol:@protocol(UnityAdsExtendedDelegate)]) {
        if ([(id<UnityAdsExtendedDelegate>)[UADSClientProperties getDelegate] respondsToSelector:@selector(unityAdsDidClick:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                    [(id<UnityAdsExtendedDelegate>)[UADSClientProperties getDelegate] unityAdsDidClick:placementId];
            });
            [callback invoke:nil];
        }
        else {
            [callback error:NSStringFromListenerError(kUnityAdsCouldNotFindSelector) arg1:nil];
        }
    }
    else {
        [callback error:NSStringFromListenerError(kUnityAdsDelegateNull) arg1:nil];
    }
}

+ (void)WebViewExposed_sendErrorEvent:(NSString *)errorString message:(NSString *)message callback:(UADSWebViewCallback *)callback {
    if ([UADSClientProperties getDelegate]) {
        if ([[UADSClientProperties getDelegate] respondsToSelector:@selector(unityAdsDidError:withMessage:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[UADSClientProperties getDelegate] unityAdsDidError:[errorString unityAdsErrorFromString] withMessage:message];
            });
            [callback invoke:nil];
        }
        else {
            [callback error:NSStringFromListenerError(kUnityAdsCouldNotFindSelector) arg1:nil];
        }
    }
    else {
        [callback error:NSStringFromListenerError(kUnityAdsDelegateNull) arg1:nil];
    }
}

@end
