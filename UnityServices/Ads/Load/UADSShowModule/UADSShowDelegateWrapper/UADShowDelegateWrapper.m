#import "UADShowDelegateWrapper.h"

@interface UADShowDelegateWrapper()

@property ( nonatomic, strong) id<UnityAdsShowDelegate> originalDelegate;
@property (nonatomic, copy) NSString* uuidString;

@end

@implementation UADShowDelegateWrapper

+ (instancetype)newWithOriginalDelegate:(nullable id<UnityAdsShowDelegate>)delegate {
    UADShowDelegateWrapper *obj = [[UADShowDelegateWrapper alloc] init];
    obj.originalDelegate = delegate;
    obj.uuidString = [[NSUUID UUID] UUIDString];
    return obj;
}

- (void)didFailWithError:(UADSInternalError * _Nonnull)error
          forPlacementID:(NSString * _Nonnull)placementID {
    NSInteger publicErrorCode = error.errorCode;
    
    if (error.errorCode == kUADSInternalErrorWebView || kUADSInternalErrorShowModule) {
        publicErrorCode = kUnityShowErrorInternalError;
    }
    if (error.errorCode == kUADSInternalErrorAbstractModule && error.reasonCode == kUADSInternalErrorAbstractModuleTimeout) {
        publicErrorCode = kUnityShowErrorInternalError;
    }
    
    if (error.errorCode == kUADSInternalErrorAbstractModule  && error.reasonCode == kUADSInternalErrorAbstractModuleEmptyPlacementID) {
        publicErrorCode = kUnityShowErrorInvalidArgument;
    }
    
    [self unityAdsShowFailed: placementID
                   withError: publicErrorCode
                 withMessage: error.errorMessage];
}


- (void)unityAdsShowClick:(nonnull NSString *)placementId {
    dispatch_on_main(^{
        [self.originalDelegate unityAdsShowClick: placementId];
    });
    
}

- (void)unityAdsShowComplete:(nonnull NSString *)placementId
             withFinishState:(UnityAdsShowCompletionState)state {
    dispatch_on_main(^{
        [self.originalDelegate unityAdsShowComplete: placementId
                                    withFinishState: state];
    });
 
}

- (void)unityAdsShowFailed:(nonnull NSString *)placementId
                 withError:(UnityAdsShowError)error
               withMessage:(nonnull NSString *)message {
    dispatch_on_main(^{
        [self.originalDelegate unityAdsShowFailed: placementId
                                        withError: error
                                      withMessage: message];
    });
    
}

-(void)unityAdsDidShowConsent:(NSString *)placementId {
    // for now this is an empty API until we decide if we want to send the event to the public API
}

- (void)unityAdsShowStart:(nonnull NSString *)placementId {
    dispatch_on_main(^{
        [self.originalDelegate unityAdsShowStart: placementId];
    });
   
}

@end
