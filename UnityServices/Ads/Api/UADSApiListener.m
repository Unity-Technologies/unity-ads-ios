#import "UADSApiListener.h"
#import "USRVWebViewCallback.h"
#import "USRVClientProperties.h"
#import "NSString+UnityAdsError.h"
#import "UnityAdsExtended.h"
#import "UADSPlacement.h"
#import "UADSProperties.h"

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

+ (void)WebViewExposed_sendReadyEvent:(NSString *)placementId callback:(USRVWebViewCallback *)callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UADSProperties getDelegate]) {
            if ([[UADSProperties getDelegate] respondsToSelector:@selector(unityAdsReady:)]) {
                [[UADSProperties getDelegate] unityAdsReady:placementId];
            }
        }
    });

    [callback invoke:nil];
}

+ (void)WebViewExposed_sendStartEvent:(NSString *)placementId callback:(USRVWebViewCallback *)callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UADSProperties getDelegate]) {
            if ([[UADSProperties getDelegate] respondsToSelector:@selector(unityAdsDidStart:)]) {
                [[UADSProperties getDelegate] unityAdsDidStart:placementId];
            }
        }
    });

    [callback invoke:nil];
}

+ (void)WebViewExposed_sendFinishEvent:(NSString *)placementId result:(NSString *)result callback:(USRVWebViewCallback *)callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UADSProperties getDelegate]) {
            if ([[UADSProperties getDelegate] respondsToSelector:@selector(unityAdsDidFinish:withFinishState:)]) {
                UnityAdsFinishState state = UnityAdsFinishStateFromNSString(result);
                if ((int)state != -10000) {
                    [[UADSProperties getDelegate] unityAdsDidFinish:placementId withFinishState:state];
                }
            }
        }
    });

    [callback invoke:nil];
}

+ (void)WebViewExposed_sendClickEvent:(NSString *)placementId callback:(USRVWebViewCallback *)callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UADSProperties getDelegate] && [[UADSProperties getDelegate] conformsToProtocol:@protocol(UnityAdsExtendedDelegate)]) {
            if ([(id<UnityAdsExtendedDelegate>)[UADSProperties getDelegate] respondsToSelector:@selector(unityAdsDidClick:)]) {
                [(id<UnityAdsExtendedDelegate>)[UADSProperties getDelegate] unityAdsDidClick:placementId];
            }
        }
    });

    [callback invoke:nil];
}

+ (void)WebViewExposed_sendPlacementStateChangedEvent:(NSString *)placementId oldState:(NSString *)oldState newState:(NSString *)newState callback:(USRVWebViewCallback *)callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UADSProperties getDelegate] && [[UADSProperties getDelegate] conformsToProtocol:@protocol(UnityAdsExtendedDelegate)]) {
            if ([(id<UnityAdsExtendedDelegate>)[UADSProperties getDelegate] respondsToSelector:@selector(unityAdsPlacementStateChanged:oldState:newState:)]) {
                UnityAdsPlacementState oldStateInteger = [UADSPlacement formatStringToPlacementState:oldState];
                UnityAdsPlacementState newStateInteger = [UADSPlacement formatStringToPlacementState:newState];
                [(id<UnityAdsExtendedDelegate>)[UADSProperties getDelegate] unityAdsPlacementStateChanged:placementId oldState:oldStateInteger newState:newStateInteger];
            }
        }
    });
    
    [callback invoke:nil];
}

+ (void)WebViewExposed_sendErrorEvent:(NSString *)errorString message:(NSString *)message callback:(USRVWebViewCallback *)callback {
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([UADSProperties getDelegate]) {
            if ([[UADSProperties getDelegate] respondsToSelector:@selector(unityAdsDidError:withMessage:)]) {
                [[UADSProperties getDelegate] unityAdsDidError:[errorString unityAdsErrorFromString] withMessage:message];
            }
        }
    });

    [callback invoke:nil];
}

@end
