#import "UnityAds.h"
#import "USRVEnvironmentProperties.h"
#import "USRVClientProperties.h"
#import "USRVSdkProperties.h"
#import "USRVInitialize.h"
#import "UADSPlacement.h"
#import "UADSProperties.h"

#import "USRVWebViewMethodInvokeQueue.h"
#import "UADSWebViewShowOperation.h"

@implementation UnityAds

#pragma mark Public Selectors

+ (void)initialize:(NSString *)gameId
          delegate:(id<UnityAdsDelegate>)delegate {
    [self initialize:gameId delegate:delegate testMode:false];
}

+ (void)initialize:(NSString *)gameId
          delegate:(id<UnityAdsDelegate>)delegate
          testMode:(BOOL)testMode {
    
    [UADSProperties setDelegate:delegate];
    [UnityServices initialize:gameId delegate:[[UnityServicesListener alloc] init] testMode:testMode];
}

+ (void)show:(UIViewController *)viewController {
    if([UADSPlacement getDefaultPlacement]) {
        [UnityAds show:viewController placementId:[UADSPlacement getDefaultPlacement]];
    } else {
        [self handleShowError:@"" unityAdsError:kUnityAdsErrorNotInitialized message:@"Unity Ads default placement is not initialized"];
    }
}

+ (void)show:(UIViewController *)viewController placementId:(NSString *)placementId {
    if ([UnityAds isReady:placementId]) {
        USRVLogInfo(@"Unity Ads opening new ad unit for placement %@", placementId);

        [USRVClientProperties setCurrentViewController:viewController];
        
        UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];

        NSDictionary *parametersDictionary = @{@"shouldAutorotate" : [NSNumber numberWithBool:viewController.shouldAutorotate],
                                               @"supportedOrientations" : [NSNumber numberWithInt:[USRVClientProperties getSupportedOrientations]],
                                               @"supportedOrientationsPlist" : [USRVClientProperties getSupportedOrientationsPlist],
                                               @"statusBarOrientation" : [NSNumber numberWithInteger:statusBarOrientation],
                                               @"statusBarHidden" : [NSNumber numberWithBool: [UIApplication sharedApplication].isStatusBarHidden]};

        
        UADSWebViewShowOperation *operation = [[UADSWebViewShowOperation alloc] initWithPlacementId:placementId
                                                                     parametersDictionary:parametersDictionary];
        
        [USRVWebViewMethodInvokeQueue addOperation:operation];
    } else {
        if (![self isSupported]) {
            [self handleShowError:placementId unityAdsError:kUnityAdsErrorNotInitialized message:@"Unity Ads is not supported for this device"];
        } else if (![self isInitialized]) {
            [self handleShowError:placementId unityAdsError:kUnityAdsErrorNotInitialized message:@"Unity Ads is not initialized"];
        } else {
            NSString *message = [NSString stringWithFormat:@"Placement \"%@""\" is not ready", placementId];
            [self handleShowError:placementId unityAdsError:kUnityAdsErrorShowError message:message];
        }
    }
}

+ (id<UnityAdsDelegate>)getDelegate {
    return [UADSProperties getDelegate];
}

+ (void)setDelegate:(id<UnityAdsDelegate>)delegate {
    [UADSProperties setDelegate:delegate];
}

+ (BOOL)getDebugMode {
    return [UnityServices getDebugMode];
}

+ (void)setDebugMode:(BOOL)enableDebugMode {
    [UnityServices setDebugMode:enableDebugMode];
}

+ (BOOL)isSupported {
    return [UnityServices isSupported];
}

+ (BOOL)isReady {
    return [UnityServices isSupported] && [UnityServices isInitialized] && [UADSPlacement isReady];
}

+ (BOOL)isReady:(NSString *)placementId {
    return [UnityServices isSupported] && [UnityServices isInitialized] && [UADSPlacement isReady:placementId];
}

+ (UnityAdsPlacementState)getPlacementState {
    return [UADSPlacement getPlacementState];
}

+ (UnityAdsPlacementState)getPlacementState:(NSString *)placementId {
    return [UADSPlacement getPlacementState:placementId];
}

+ (NSString *)getVersion {
    return [UnityServices getVersion];
}

+ (BOOL)isInitialized {
    return [USRVSdkProperties isInitialized];
}

+ (void)handleShowError:(NSString *)placementId unityAdsError:(UnityAdsError)unityAdsError message:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *errorMessage = [NSString stringWithFormat:@"Unity Ads show failed: %@", message];
        USRVLogError(@"%@", errorMessage);
        if ([self getDelegate] && [[self getDelegate]respondsToSelector:@selector(unityAdsDidError:withMessage:)]) {
            [[self getDelegate] unityAdsDidError:unityAdsError withMessage:errorMessage];
        }

        if ([self getDelegate] && [[self getDelegate]respondsToSelector:@selector(unityAdsDidFinish:withFinishState:)]) {
            if (placementId) {
                [[self getDelegate] unityAdsDidFinish:placementId withFinishState:kUnityAdsFinishStateError];
            } else {
                [[self getDelegate] unityAdsDidFinish:@"" withFinishState:kUnityAdsFinishStateError];
            }
        }
    });
}

@end

@implementation UnityServicesListener
- (void)unityServicesDidError:(UnityServicesError)error withMessage:(NSString *)message {
    UnityAdsError unityAdsError = 0;
    
    if (error == kUnityServicesErrorInvalidArgument) {
        unityAdsError = kUnityAdsErrorInvalidArgument;
    }
    else if (error == kUnityServicesErrorInitSanityCheckFail) {
        unityAdsError = kUnityAdsErrorInitSanityCheckFail;
    }
    
    id<UnityAdsDelegate> delegate = [UADSProperties getDelegate];

    if (delegate != nil && [delegate respondsToSelector:@selector(unityAdsDidError:withMessage:)]) {
        [delegate unityAdsDidError:unityAdsError withMessage:message];
    }
}
@end

