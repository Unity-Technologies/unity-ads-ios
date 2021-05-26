#import "UADSApiShow.h"
#import "UADSShowModule.h"
#import "UADSLoadModule.h"
#import "UnityAdsShowError.h"
#import "USRVWebViewCallback.h"
#import "UnityAdsShowCompletionState.h"

 UnityAdsShowError UnityAdsShowErrorFromNSString (NSString* error) {
     NSDictionary <NSString*,NSNumber*> *errorDict = @{
         @"NOT_INITIALIZED": @(kUnityShowErrorNotInitialized),
         @"NOT_READY": @(kUnityShowErrorNotReady),
         @"VIDEO_PLAYER_ERROR": @(kUnityShowErrorVideoPlayerError),
         @"INVALID_ARGUMENT": @(kUnityShowErrorInvalidArgument),
         @"NO_CONNECTION": @(kUnityShowErrorAlreadyShowing),
         @"ALREADY_SHOWING": @(kUnityShowErrorAlreadyShowing),
         @"INTERNAL_ERROR": @(kUnityShowErrorInternalError)
     };

     return errorDict[error].integerValue;
 }

 UnityAdsShowCompletionState UnityAdsShowCompletionStateFromNSString (NSString* state) {
     NSDictionary <NSString*,NSNumber*> *stateDict = @{
         @"SKIPPED": @(kUnityShowCompletionStateSkipped),
         @"COMPLETED": @(kUnityShowCompletionStateCompleted)
     };

     return stateDict[state].integerValue;
 }


 @implementation UADSApiShow

+(UADSShowModule *)showModule {
    return UADSShowModule.sharedInstance;
}

 +(void)WebViewExposed_sendShowFailedEvent:(NSString*)placementId
                                listenerId:(NSString*)listenerId
                                     error:(NSString *)error
                                   message:(NSString *)message
                                  callback:(USRVWebViewCallback *)callback {
     UnityAdsShowError showError = UnityAdsShowErrorFromNSString(error);
     
     [self.showModule sendShowFailedEvent: placementId
                               listenerID: listenerId
                                  message: message
                                    error: showError];

     [callback invoke:nil];
 }

 +(void)WebViewExposed_sendShowStartEvent:(NSString*)placementId
                               listenerId:(NSString*)listenerId
                                 callback:(USRVWebViewCallback *)callback {
     
     [self.showModule sendShowStartEvent: placementId
                              listenerID: listenerId];
     [callback invoke:nil];
 }

 +(void)WebViewExposed_sendShowClickEvent:(NSString*)placementId
                               listenerId:(NSString*)listenerId
                                 callback:(USRVWebViewCallback *)callback {
     [self.showModule sendShowClickEvent: placementId
                              listenerID: listenerId];
     [callback invoke:nil];
 }



+(void)WebViewExposed_sendShowConsentEvent:(NSString*)placementId
                                listenerId:(NSString*)listenerId
                                  callback:(USRVWebViewCallback *)callback {
    [self.showModule sendShowConsentEvent: placementId
                               listenerID: listenerId];
    [callback invoke:nil];
}


 +(void)WebViewExposed_sendShowCompleteEvent:(NSString*)placementId
                                  listenerId:(NSString*)listenerId
                                       state:(NSString *)state
                                    callback:(USRVWebViewCallback *)callback {
     UnityAdsShowCompletionState completeState = UnityAdsShowCompletionStateFromNSString(state);
     [self.showModule sendShowCompleteEvent: placementId
                                 listenerID: listenerId
                                      state: completeState];
     [callback invoke:nil];
 }

 @end
