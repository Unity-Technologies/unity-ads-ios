#import "UADSApiListener.h"
#import "USRVWebViewCallback.h"
#import "USRVClientProperties.h"
#import "NSString+UnityAdsError.h"
#import "UnityAdsExtendedDelegate.h"
#import "UADSPlacement.h"
#import "UADSProperties.h"
#import "UnityAdsDelegateUtil.h"

UnityAdsFinishState UnityAdsFinishStateFromNSString(NSString *state) {
    if (state) {
        if ([state isEqualToString: @"COMPLETED"]) {
            return kUnityAdsFinishStateCompleted;
        } else if ([state isEqualToString: @"SKIPPED"]) {
            return kUnityAdsFinishStateSkipped;
        } else if ([state isEqualToString: @"ERROR"]) {
            return kUnityAdsFinishStateError;
        }
    }

    return -10000;
}

@implementation UADSApiListener

+ (void)WebViewExposed_sendReadyEvent: (NSString *)placementId callback: (USRVWebViewCallback *)callback {
    [UnityAdsDelegateUtil unityAdsReady: placementId];
    [callback invoke: nil];
}

+ (void)WebViewExposed_sendStartEvent: (NSString *)placementId callback: (USRVWebViewCallback *)callback {
    [UnityAdsDelegateUtil unityAdsDidStart: placementId];

    [callback invoke: nil];
}

+ (void)WebViewExposed_sendFinishEvent: (NSString *)placementId result: (NSString *)result callback: (USRVWebViewCallback *)callback {
    UnityAdsFinishState state = UnityAdsFinishStateFromNSString(result);

    [UnityAdsDelegateUtil unityAdsDidFinish: placementId
                            withFinishState: state];

    [callback invoke: nil];
}

+ (void)WebViewExposed_sendClickEvent: (NSString *)placementId callback: (USRVWebViewCallback *)callback {
    [UnityAdsDelegateUtil unityAdsDoClick: placementId];

    [callback invoke: nil];
}

+ (void)WebViewExposed_sendPlacementStateChangedEvent: (NSString *)placementId oldState: (NSString *)oldState newState: (NSString *)newState callback: (USRVWebViewCallback *)callback {
    UnityAdsPlacementState oldStateEnum = [UADSPlacement formatStringToPlacementState: oldState];
    UnityAdsPlacementState newStateEnum = [UADSPlacement formatStringToPlacementState: newState];

    [UnityAdsDelegateUtil unityAdsPlacementStateChange: placementId
                                              oldState: oldStateEnum
                                              newState: newStateEnum];

    [callback invoke: nil];
}

+ (void)WebViewExposed_sendErrorEvent: (NSString *)errorString message: (NSString *)message callback: (USRVWebViewCallback *)callback {
    [UnityAdsDelegateUtil unityAdsDidError: [errorString unityAdsErrorFromString]
                               withMessage: message];

    [callback invoke: nil];
}

@end
