#import "UADSApiListener.h"
#import "UADSWebViewCallback.h"
#import "UADSClientProperties.h"
#import "NSString+UnityAdsError.h"
#import "UnityAdsExtended.h"
#import "UADSPlacement.h"

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
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UADSClientProperties getDelegate]) {
            if ([[UADSClientProperties getDelegate] respondsToSelector:@selector(unityAdsReady:)]) {
                [[UADSClientProperties getDelegate] unityAdsReady:placementId];
            }
        }
    });

    [callback invoke:nil];
}

+ (void)WebViewExposed_sendStartEvent:(NSString *)placementId callback:(UADSWebViewCallback *)callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UADSClientProperties getDelegate]) {
            if ([[UADSClientProperties getDelegate] respondsToSelector:@selector(unityAdsDidStart:)]) {
                [[UADSClientProperties getDelegate] unityAdsDidStart:placementId];
            }
        }
    });

    [callback invoke:nil];
}

+ (void)WebViewExposed_sendFinishEvent:(NSString *)placementId result:(NSString *)result callback:(UADSWebViewCallback *)callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UADSClientProperties getDelegate]) {
            if ([[UADSClientProperties getDelegate] respondsToSelector:@selector(unityAdsDidFinish:withFinishState:)]) {
                UnityAdsFinishState state = UnityAdsFinishStateFromNSString(result);
                if ((int)state != -10000) {
                    [[UADSClientProperties getDelegate] unityAdsDidFinish:placementId withFinishState:state];
                }
            }
        }
    });

    [callback invoke:nil];
}

+ (void)WebViewExposed_sendClickEvent:(NSString *)placementId callback:(UADSWebViewCallback *)callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UADSClientProperties getDelegate] && [[UADSClientProperties getDelegate] conformsToProtocol:@protocol(UnityAdsExtendedDelegate)]) {
            if ([(id<UnityAdsExtendedDelegate>)[UADSClientProperties getDelegate] respondsToSelector:@selector(unityAdsDidClick:)]) {
                [(id<UnityAdsExtendedDelegate>)[UADSClientProperties getDelegate] unityAdsDidClick:placementId];
            }
        }
    });

    [callback invoke:nil];
}

+ (void)WebViewExposed_sendPlacementStateChangedEvent:(NSString *)placementId oldState:(NSString *)oldState newState:(NSString *)newState callback:(UADSWebViewCallback *)callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UADSClientProperties getDelegate] && [[UADSClientProperties getDelegate] conformsToProtocol:@protocol(UnityAdsExtendedDelegate)]) {
            if ([(id<UnityAdsExtendedDelegate>)[UADSClientProperties getDelegate] respondsToSelector:@selector(unityAdsPlacementStateChanged:oldState:newState:)]) {
                UnityAdsPlacementState oldStateInteger = [UADSPlacement formatStringToPlacementState:oldState];
                UnityAdsPlacementState newStateInteger = [UADSPlacement formatStringToPlacementState:newState];
                [(id<UnityAdsExtendedDelegate>)[UADSClientProperties getDelegate] unityAdsPlacementStateChanged:placementId oldState:oldStateInteger newState:newStateInteger];
            }
        }
    });
    
    [callback invoke:nil];
}

+ (void)WebViewExposed_sendErrorEvent:(NSString *)errorString message:(NSString *)message callback:(UADSWebViewCallback *)callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UADSClientProperties getDelegate]) {
            if ([[UADSClientProperties getDelegate] respondsToSelector:@selector(unityAdsDidError:withMessage:)]) {
                [[UADSClientProperties getDelegate] unityAdsDidError:[errorString unityAdsErrorFromString] withMessage:message];
            }
        }
    });

    [callback invoke:nil];
}

@end
