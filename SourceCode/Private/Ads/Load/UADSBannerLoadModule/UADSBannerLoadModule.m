#import "UADSBannerLoadModule.h"
#import "WebViewInvokerQueueDecorator.h"
#import "UADSBannerLoadModuleDelegateWrapper.h"
#import "UADSBannerLoadModuleOperationObject.h"
#import "USRVDevice.h"
#import "UADSBannerLoadOptions.h"

@implementation UADSBannerLoadModule

typedef id<UADSWebViewInvoker> Invoker;

+ (instancetype)sharedInstance {
    UADS_SHARED_INSTANCE(onceToken, ^{
        return [self newSharedModule];
    });
}

+ (UADSEventHandlerType)moduleType {
    return kUADSEventHandlerTypeBannerLoadModule;
}

- (id<UADSAbstractModuleOperationObject>)createEventWithPlacementID: (NSString *)placementID
                                                        withOptions: (id<UADSDictionaryConvertible>)options
                                                              timer: (id<UADSRepeatableTimer>)timer
                                                       withDelegate: (id<UADSAbstractModuleDelegate>)delegate {
    UADSBannerLoadModuleOperationObject *operation = [UADSBannerLoadModuleOperationObject new];

    operation.placementID = placementID;
    operation.options = options;
    operation.delegate = delegate;
    operation.ttl = -1;
    operation.time = [USRVDevice getElapsedRealtime];    
    operation.timer = timer;
    return operation;
}

- (NSString *)loadForPlacementID: (NSString *)placementID
                      bannerView: (nonnull UADSBannerView *)bannerView
                         options: (UADSLoadOptions *)options
                    loadDelegate: (nullable id<UADSBannerViewDelegate>)loadDelegate {
    UADSBannerLoadModuleDelegateWrapper *wrappedDelegate = [UADSBannerLoadModuleDelegateWrapper newWithAdsDelegate: loadDelegate bannerView: bannerView];
    UADSBannerLoadOptions *loadOptions = [UADSBannerLoadOptions newBannerLoadOptionsWith:options size:bannerView.size];
    return [self executeForPlacement: placementID
                         withOptions: loadOptions
                         andDelegate: wrappedDelegate];
}

- (void)sendAdLoadedForPlacementID:(NSString *)placementID andListenerID:(NSString *)listenerID {
    [self handleSuccess: listenerID];
    UADSBannerLoadModuleDelegateWrapper *delegate = [self getDelegateForID: listenerID];

    [delegate bannerViewDidLoad: nil];
}

- (void)sendClickEventForListenerID:  (NSString *_Nonnull)listenerID {
    UADSBannerLoadModuleDelegateWrapper *delegate = [self getDelegateForID: listenerID];

    [delegate bannerViewDidClick:nil];
}

- (void)sendLeaveApplicationEventForListenerID:  (NSString *_Nonnull)listenerID {
    UADSBannerLoadModuleDelegateWrapper *delegate = [self getDelegateForID: listenerID];

    [delegate bannerViewDidLeaveApplication:nil];
}

- (void)sendAdFailedToLoadForPlacementID:(NSString *)placementID listenerID:(NSString *)listenerID message:(NSString *)message error:(UnityAdsLoadError)error {
    UADSInternalError *internalError = [UADSInternalError newWithErrorCode: kUADSInternalErrorLoadModule
                                                                 andReason: error
                                                                andMessage: message];

    [self catchError: internalError
               forId: listenerID];
    UADSBannerLoadModuleDelegateWrapper *delegate = [self getDelegateForIDAndRemove: listenerID];

    [delegate didFailWithError: internalError forPlacementID: @""];
}

- (UADSBannerLoadModuleDelegateWrapper *)getDelegateForIDAndRemove: (NSString *)listenerID {
    return (UADSBannerLoadModuleDelegateWrapper *)[super getDelegateForIDAndRemove: listenerID];
}

- (UADSBannerView *)bannerViewWithID:(NSString *)bannerID {
    UADSBannerLoadModuleDelegateWrapper *delegate = [self getDelegateForID: bannerID];
    return delegate.bannerView;
    
}

- (UADSBannerLoadModuleDelegateWrapper *)getDelegateForID: (NSString*)listenerID {
    return (UADSBannerLoadModuleDelegateWrapper*)[super getOperationWithID: listenerID].delegate;
}

@end
