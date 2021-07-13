#import "UADSLoadModuleDelegateWrapper.h"

@interface UADSLoadModuleDelegateWrapper ()

@property (nonatomic, strong) id<UnityAdsLoadDelegate>decorated;
@property (nonatomic, copy) NSString *uuidString;
@end

@implementation UADSLoadModuleDelegateWrapper

+ (instancetype)newWithAdsDelegate: (id<UnityAdsLoadDelegate>)decorated {
    UADSLoadModuleDelegateWrapper *wrapper = [UADSLoadModuleDelegateWrapper new];

    wrapper.uuidString = [NSUUID new].UUIDString;
    wrapper.decorated = decorated;
    return wrapper;
}

- (void)unityAdsAdFailedToLoad: (NSString *)placementId
                     withError: (UnityAdsLoadError)error
                   withMessage: (NSString *)message {
    dispatch_on_main( ^{
        [self.decorated unityAdsAdFailedToLoad: placementId
                                     withError: error
                                   withMessage: message];
    });
}

- (void)unityAdsAdLoaded: (nonnull NSString *)placementId {
    dispatch_on_main( ^{
        [self.decorated unityAdsAdLoaded: placementId];
    });
}

- (void)didFailWithError: (UADSInternalError *_Nonnull)error
          forPlacementID: (NSString *_Nonnull)placementID {
    [self unityAdsAdFailedToLoad: placementID
                       withError: [self convertIntoPublicError: error]
                     withMessage: error.errorMessage];
}

- (UnityAdsLoadError)convertIntoPublicError: (UADSInternalError *)error {
    if (error.errorCode == kUADSInternalErrorAbstractModule && error.reasonCode == kUADSInternalErrorAbstractModuleTimeout) {
        return kUnityAdsLoadErrorTimeout;
    }

    if (error.errorCode == kUADSInternalErrorWebView && error.reasonCode == kUADSInternalErrorWebViewInternal) {
        return kUnityAdsLoadErrorInternal;
    }

    if (error.errorCode == kUADSInternalErrorWebView && error.reasonCode == kUADSInternalErrorWebViewSDKNotInitialized) {
        return kUnityAdsLoadErrorInitializeFailed;
    }

    if (error.errorCode == kUADSInternalErrorAbstractModule && error.reasonCode == kUADSInternalErrorAbstractModuleEmptyPlacementID) {
        return kUnityAdsLoadErrorInvalidArgument;
    }

    return error.reasonCode;
}

@end
