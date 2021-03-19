#import "UADSShowModule.h"
#import "UnityAdsShowDelegate.h"
#import "UADSShowModuleOperation.h"
#import "USRVDevice.h"
#import "UnityServices.h"

static NSString *const kSupportedOrientationsKey = @"supportedOrientations";
static NSString *const kSupportedOrientationsPlistKey = @"supportedOrientationsPlist";
static NSString *const kStatusBarOrientationKey = @"statusBarOrientation";
static NSString *const kStatusBarHiddenKey = @"statusBarHidden";

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
    return [self newWithInvoker: basicInvoker andErrorHandler: [UADSErrorLogger newWithType: kUADSErrorHandlerTypeShowModule]];
}


- (UADSInternalError *)executionErrorForPlacementID:(NSString *)placementID {
    return  self.notSupportedError ?: self.notInitializedError ?: [super executionErrorForPlacementID: placementID];
}

- (NSInteger)operationOperationTimeoutMs {
    return UADSShowModule.configuration.showTimeout / 1000;
}

-(nullable UADSInternalError *)notSupportedError {
    GUARD_OR_NIL(!UnityServices.isSupported)
    return [UADSInternalError newWithErrorCode: kUADSInternalErrorShowModule
                                     andReason: kUnityShowErrorInvalidArgument
                                    andMessage: kUnityAdsNotSupportedMessage];
}

-(nullable UADSInternalError *)notInitializedError {
    GUARD_OR_NIL(!UnityServices.isInitialized)
    return [UADSInternalError newWithErrorCode: kUADSInternalErrorShowModule
                                     andReason: kUnityShowErrorNotInitialized
                                    andMessage: kUnityAdsNotInitializedMessage];
}


- (id<UADSAbstractModuleOperationObject>)createEventWithPlacementID:(NSString *)placementID
                                                        withOptions:(id<UADSDictionaryConvertible>)options
                                                       withDelegate:(id<UADSAbstractModuleDelegate>)delegate
                                                  andViewController:(UIViewController *)viewController {
    UADSShowModuleOperation *operation = [UADSShowModuleOperation new];
    operation.placementID = placementID;
    operation.options = options;
    operation.delegate = delegate;
    operation.time = [USRVDevice getElapsedRealtime]; //ideally this should not be as explicit dependency
    operation.shouldAutorotate = viewController.shouldAutorotate;
    operation.orientationState = self.orientationState;
    operation.ttl = [self operationOperationTimeoutMs];
    return operation;
}


-(void)showInViewController:(UIViewController *)viewController
                placementID:(NSString *)placementID
                withOptions:(UADSShowOptions *)options
            andShowDelegate:(nullable id<UnityAdsShowDelegate>)showDelegate {
    UADShowDelegateWrapper *wrappedDelegate =  [UADShowDelegateWrapper newWithOriginalDelegate:showDelegate];
    [self executeForPlacement: placementID
                  withOptions: options
                  andDelegate: wrappedDelegate
            forViewController: viewController];
}


-(void)sendShowStartEvent:(NSString *)placementID
               listenerID:(NSString *)listenerID {
    UADShowDelegateWrapper* delegate = [self getDelegateForIDAndStopObserving: listenerID];
    [delegate unityAdsShowStart: placementID];
}


-(void)sendShowClickEvent:(NSString *)placementID
               listenerID:(NSString *)listenerID {
    UADShowDelegateWrapper* delegate = [self getDelegateForIDAndStopObserving: listenerID];
    [delegate unityAdsShowClick: placementID];
}

-(void)sendShowCompleteEvent:(NSString *)placementID
                  listenerID:(NSString *)listenerID
                       state:(UnityAdsShowCompletionState)state {
    UADShowDelegateWrapper* delegate = [self getDelegateForIDAndRemove: listenerID];
    [delegate unityAdsShowComplete: placementID
                   withFinishState: state];
}

-(void)sendShowFailedEvent:(NSString *)placementID
                listenerID:(NSString *)listenerID
                   message:(NSString *)message
                     error:(UnityAdsShowError)error {
    UADShowDelegateWrapper* delegate =  [self getDelegateForIDAndRemove: listenerID];
    [delegate unityAdsShowFailed: placementID
                       withError: error
                     withMessage: message];
}


-(UADShowDelegateWrapper * _Nullable )getDelegateForIDAndRemove: (NSString *)listenerID {
   return (UADShowDelegateWrapper *)[super getDelegateForIDAndRemove: listenerID];
}


-(UADShowDelegateWrapper * _Nullable )getDelegateForIDAndStopObserving: (NSString *)listenerID {
    UADSShowModuleOperation *operation = [self getOperationWithID: listenerID];
    [operation stopTTLObserving];
    return (UADShowDelegateWrapper *)operation.delegate;
}

-(NSDictionary *)orientationState {
    return  @{
        kSupportedOrientationsKey : [NSNumber numberWithInt: [USRVClientProperties getSupportedOrientations]],
        kSupportedOrientationsPlistKey : [USRVClientProperties getSupportedOrientationsPlist],
        kStatusBarOrientationKey : [NSNumber numberWithInteger: UIApplication.sharedApplication.statusBarOrientation],
        kStatusBarHiddenKey : [NSNumber numberWithBool: UIApplication.sharedApplication.isStatusBarHidden],
    };
}

@end
