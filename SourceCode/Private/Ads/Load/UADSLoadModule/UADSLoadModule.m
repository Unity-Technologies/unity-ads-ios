#import "UADSLoadModule.h"
#import "UADSAbstractModule.h"
#import "USRVDevice.h"
#import "WebViewInvokerQueueDecorator.h"
#import "UADSLoadModuleOperationObject.h"

@implementation UADSLoadModule

typedef id<UADSWebViewInvoker> Invoker;


+ (instancetype)sharedInstance {
    UADS_SHARED_INSTANCE(onceToken, ^{
        return [self newSharedModule];
    });
}

+ (UADSEventHandlerType)moduleType {
    return kUADSEventHandlerTypeLoadModule;
}

+ (instancetype)createDefaultModule {
    int timeout = self.configuration.webViewTimeout / 1000;
    Invoker basicInvoker = [UADSWebViewInvokerImp newWithWaitingTime: timeout];
    USRVInitializationNotificationCenter *center = [USRVInitializationNotificationCenter sharedInstance];

    Invoker bufferDecorator = [WebViewInvokerQueueDecorator newWithDecorated: basicInvoker
                                                       andNotificationCenter    : center];

    return [self newWithInvoker: bufferDecorator
                andEventHandler: [UADSEventHandlerBase newDefaultWithType: self.moduleType]
                   timerFactory: [UADSTimerFactoryBase new]];
}

- (id<UADSAbstractModuleOperationObject>)createEventWithPlacementID: (NSString *)placementID
                                                        withOptions: (id<UADSDictionaryConvertible>)options
                                                              timer: (id<UADSRepeatableTimer>)timer
                                                       withDelegate: (id<UADSAbstractModuleDelegate>)delegate {
    UADSLoadModuleOperationObject *operation = [UADSLoadModuleOperationObject new];

    operation.placementID = placementID;
    operation.options = options;
    operation.delegate = delegate;
    operation.ttl = [self operationOperationTimeoutMs];
    operation.time = [USRVDevice getElapsedRealtime];     // ideally this should not be as explicit dependency
    operation.timer = timer;
    return operation;
}

- (NSInteger)operationOperationTimeoutMs {
    // should come from an object like Configuration/Timeouts Reader.
    return UADSLoadModule.configuration.loadTimeout / 1000;
}

- (void)loadForPlacementID: (NSString *)placementID
                   options: (UADSLoadOptions *)options
              loadDelegate: (nullable id<UnityAdsLoadDelegate>)loadDelegate {
    UADSLoadModuleDelegateWrapper *wrappedDelegate = [UADSLoadModuleDelegateWrapper newWithAdsDelegate: loadDelegate];

    [self executeForPlacement: placementID
                  withOptions: options
                  andDelegate: wrappedDelegate];
}

- (void)sendAdLoadedForPlacementID: (NSString *)placementID
                     andListenerID: (NSString *)listenerID {
    [self handleSuccess: listenerID];
    UADSLoadModuleDelegateWrapper *delegate = [self getDelegateForIDAndRemove: listenerID];

    [delegate unityAdsAdLoaded: placementID];
}

- (void)sendAdFailedToLoadForPlacementID: (NSString *)placementID
                              listenerID: (NSString *)listenerID
                                 message: (NSString *)message
                                   error: (UnityAdsLoadError)error {
    UADSInternalError *internalError = [UADSInternalError newWithErrorCode: kUADSInternalErrorLoadModule
                                                                 andReason: error
                                                                andMessage: message];

    [self catchError: internalError
               forId: listenerID];
    UADSLoadModuleDelegateWrapper *delegate = [self getDelegateForIDAndRemove: listenerID];

    [delegate didFailWithError: internalError
                forPlacementID: placementID];
}

- (UADSLoadModuleDelegateWrapper *)getDelegateForIDAndRemove: (NSString *)listenerID {
    return (UADSLoadModuleDelegateWrapper *)[super getDelegateForIDAndRemove: listenerID];
}

@end
