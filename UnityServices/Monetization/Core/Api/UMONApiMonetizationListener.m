#import "UMONApiMonetizationListener.h"
#import "USRVWebViewCallback.h"
#import "UnityMonetizationDelegate.h"
#import "UMONClientProperties.h"
#import "UMONPlacementContents.h"
#import "UMONPlacementContentDelegateError.h"

@implementation UMONApiMonetizationListener

+(void)WebViewExposed_isMonetizationEnabled:(USRVWebViewCallback*)callback {
    [callback invoke:@([UMONClientProperties monetizationEnabled]), nil];
}

+(void)WebViewExposed_sendPlacementContentReady:(NSString *)placementId withCallBack:(USRVWebViewCallback *)callback {
    id <UnityMonetizationDelegate> delegate = [UMONClientProperties getDelegate];
    if (delegate) {
        @try {
            UMONPlacementContent *placementContent = [UMONPlacementContents getPlacementContent:placementId];
            [delegate placementContentReady:placementId placementContent:placementContent];
            [callback invoke:nil];
        } @catch (NSException *e) {
            [callback error:NSStringFromPlacementContentDelegateError(kPlacementDelegateErrorDelegateDidError) arg1:e];
        }
    } else {
        [callback error:NSStringFromPlacementContentDelegateError(kPlacementDelegateErrorDelegateNull) arg1:nil];
    }
}

+(void)WebViewExposed_sendPlacementContentStateChanged:(NSString *)placementId withPreviousState:(NSString *)previousState withNewState:(NSString *)newState withCallBack:(USRVWebViewCallback *)callback {
    id <UnityMonetizationDelegate> delegate = [UMONClientProperties getDelegate];
    if (delegate) {
        @try {
            UMONPlacementContent *placementContent = [UMONPlacementContents getPlacementContent:placementId];
            [delegate placementContentStateDidChange:placementId
                                    placementContent:placementContent
                                       previousState:PlacementContentStateFromNSString(previousState)
                                            newState:PlacementContentStateFromNSString(newState)];
            [callback invoke:nil];
        } @catch (NSException *e) {
            [callback error:NSStringFromPlacementContentDelegateError(kPlacementDelegateErrorDelegateDidError) arg1:e];
        }
    } else {
        [callback error:NSStringFromPlacementContentDelegateError(kPlacementDelegateErrorDelegateNull) arg1:nil];
    }
}

@end
