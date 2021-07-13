#import "UADSApiLoad.h"
#import "UnityAdsLoadError.h"
#import "USRVWebViewCallback.h"
#import "UADSLoadModule.h"



@implementation UADSApiLoad
UnityAdsLoadError UnityAdsLoadErrorFromNSString(NSString *error) {
    NSDictionary <NSString *, NSNumber *> *errorDict = @{
        @"INITIALIZE_FAILED": @(kUnityAdsLoadErrorInitializeFailed),
        @"INTERNAL_ERROR": @(kUnityAdsLoadErrorInternal),
        @"INVALID_ARGUMENT": @(kUnityAdsLoadErrorInvalidArgument),
        @"NO_FILL": @(kUnityAdsLoadErrorNoFill),
        @"TIMEOUT": @(kUnityAdsLoadErrorTimeout),
    };

    return errorDict[error].integerValue;
}

+ (void)WebViewExposed_sendAdLoaded: (NSString *)placementId
                         listenerId: (NSString *)listenerId
                           callback: (USRVWebViewCallback *)callback {
    [UADSLoadModule.sharedInstance sendAdLoadedForPlacementID: placementId
                                                andListenerID: listenerId];
    [callback invoke: nil];
}

+ (void)WebViewExposed_sendAdFailedToLoad: (NSString *)placementId
                               listenerId: (NSString *)listenerId
                                    error: (NSString *)error
                                  message: (NSString *)message
                                 callback: (USRVWebViewCallback *)callback {
    [UADSLoadModule.sharedInstance sendAdFailedToLoadForPlacementID: placementId
                                                         listenerID: listenerId
                                                            message: message
                                                              error: UnityAdsLoadErrorFromNSString(error)];
    [callback invoke: nil];
}

@end
