#import "UADSShowModule.h"
#import "UnityAdsShowDelegate.h"
#import "UADSShowModuleOperation.h"
#import "USRVDevice.h"
#import "UnityServices.h"
#import "UADSShowModuleOptions.h"

@implementation UADSShowModule

typedef id<UADSWebViewInvoker> Invoker;

+ (instancetype)sharedInstance {
    UADS_SHARED_INSTANCE(onceToken, ^{
        return [self newSharedModule];
    });
}

+ (instancetype)createDefaultModule {
    int timeout = [self.configuration webViewTimeout] / 1000;
    Invoker basicInvoker = [UADSWebViewInvokerImp newWithWaitingTime: timeout];

    return [self newWithInvoker: basicInvoker
                andErrorHandler: [UADSInternalErrorLogger newWithType: kUADSErrorHandlerTypeShowModule]];
}

- (UADSInternalError *)executionErrorForPlacementID: (NSString *)placementID {
    return self.notSupportedError ? : self.notInitializedError ? : [super executionErrorForPlacementID: placementID];
}

- (NSInteger)operationOperationTimeoutMs {
    return UADSShowModule.configuration.showTimeout / 1000;
}

- (nullable UADSInternalError *)notSupportedError {
    GUARD_OR_NIL(!UnityServices.isSupported)
    return [UADSInternalError newWithErrorCode: kUADSInternalErrorShowModule
                                     andReason: kUnityShowErrorInvalidArgument
                                    andMessage: kUnityAdsNotSupportedMessage];
}

- (nullable UADSInternalError *)notInitializedError {
    GUARD_OR_NIL(!UnityServices.isInitialized)
    return [UADSInternalError newWithErrorCode: kUADSInternalErrorShowModule
                                     andReason: kUnityShowErrorNotInitialized
                                    andMessage: kUnityAdsNotInitializedMessage];
}

- (id<UADSAbstractModuleOperationObject>)createEventWithPlacementID: (NSString *)placementID
                                                        withOptions: (id<UADSDictionaryConvertible>)options
                                                       withDelegate: (id<UADSAbstractModuleDelegate>)delegate {
    UADSShowModuleOperation *operation = [UADSShowModuleOperation new];

    operation.placementID = placementID;
    operation.delegate = delegate;
    operation.options = options;
    operation.time = [USRVDevice getElapsedRealtime];     //ideally this should not be as explicit dependency
    operation.ttl = [self operationOperationTimeoutMs];
    return operation;
}

- (void)showAdForPlacementID: (NSString *)placementID
                 withOptions: (id<UADSDictionaryConvertible>)options
             andShowDelegate: (nullable id<UnityAdsShowDelegate>)showDelegate {
    UADShowDelegateWrapper *wrappedDelegate =  [UADShowDelegateWrapper newWithOriginalDelegate: showDelegate];

    [self executeForPlacement: placementID
                  withOptions: options
                  andDelegate: wrappedDelegate
    ];
}

- (void)sendShowStartEvent: (NSString *)placementID
                listenerID: (NSString *)listenerID {
    UADShowDelegateWrapper *delegate = [self getDelegateForIDAndStopObserving: listenerID];

    [delegate unityAdsShowStart: placementID];
}

- (void)sendShowClickEvent: (NSString *)placementID
                listenerID: (NSString *)listenerID {
    UADShowDelegateWrapper *delegate = [self getDelegateForIDAndStopObserving: listenerID];

    [delegate unityAdsShowClick: placementID];
}

- (void)sendShowConsentEvent: (NSString *)placementID
                  listenerID: (NSString *)listenerID {
    UADShowDelegateWrapper *delegate = [self getDelegateForIDAndStopObserving: listenerID];

    [delegate unityAdsDidShowConsent: placementID];
}

- (void)sendShowCompleteEvent: (NSString *)placementID
                   listenerID: (NSString *)listenerID
                        state: (UnityAdsShowCompletionState)state {
    UADShowDelegateWrapper *delegate = [self getDelegateForIDAndRemove: listenerID];

    [delegate unityAdsShowComplete: placementID
                   withFinishState: state];
}

- (void)sendShowFailedEvent: (NSString *)placementID
                 listenerID: (NSString *)listenerID
                    message: (NSString *)message
                      error: (UnityAdsShowError)error {
    UADShowDelegateWrapper *delegate =  [self getDelegateForIDAndRemove: listenerID];

    [delegate unityAdsShowFailed: placementID
                       withError: error
                     withMessage: message];
}

- (UADShowDelegateWrapper *_Nullable)getDelegateForIDAndRemove: (NSString *)listenerID {
    return (UADShowDelegateWrapper *)[super getDelegateForIDAndRemove: listenerID];
}

- (UADShowDelegateWrapper *_Nullable)getDelegateForIDAndStopObserving: (NSString *)listenerID {
    UADSShowModuleOperation *operation = [self getOperationWithID: listenerID];

    [operation stopTTLObserving];
    return (UADShowDelegateWrapper *)operation.delegate;
}

@end
