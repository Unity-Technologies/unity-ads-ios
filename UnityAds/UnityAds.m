#import "UnityAds.h"
#import "UADSEnvironmentProperties.h"
#import "UADSClientProperties.h"
#import "UADSSdkProperties.h"
#import "UADSConfiguration.h"
#import "UADSInitialize.h"
#import "UADSViewController.h"
#import "UADSWebViewApp.h"
#import "UADSPlacement.h"

#import "UADSWebViewMethodInvokeQueue.h"
#import "UADSWebViewShowOperation.h"

NSString* const kUnityAdsErrorDomain = @"com.unity3d.ads.UnityAds.Error";



static BOOL _debugMode = NO;
static BOOL _initializing = NO;

@implementation UnityAds

#pragma mark Public Selectors

+ (void)initialize:(NSString *)gameId
          delegate:(id<UnityAdsDelegate>)delegate {
    [self initialize:gameId delegate:delegate testMode:false];
}

+ (void)initialize:(NSString *)gameId
          delegate:(id<UnityAdsDelegate>)delegate
          testMode:(BOOL)testMode {
    
    BOOL didError = NO;
    UnityAdsError unityAdsError = 0;
    
    // Already initialized or currently initializing, error and bail
    if ([UADSSdkProperties isInitialized] || _initializing) {
        if ([UADSClientProperties getGameId] && ![[UADSClientProperties getGameId] isEqualToString:gameId]) {
            UADSLogWarning(@"You are trying to re-initialize with different gameId!");
        }

        didError = YES;
        unityAdsError = kUnityAdsErrorInitSanityCheckFail;
    }
    // Bad game id or nil delegate
    if (!gameId || [gameId length] == 0) {
        UADSLogError(@"Unity ads init: invalid argument, halting init");
        didError = YES;
        unityAdsError = kUnityAdsErrorInvalidArgument;
    }
    
    if (didError) {
        if (delegate != nil && [delegate respondsToSelector:@selector(unityAdsDidError:withMessage:)]) {
            [delegate unityAdsDidError:unityAdsError withMessage:@""];
        }
        
        return;
    }
    
    [UADSSdkProperties setInitializationTime:[[NSDate date] timeIntervalSince1970] * 1000];
    
    _initializing = YES;
    @synchronized (self) {
        if(testMode) {
            UADSLogInfo(@"Initializing Unity Ads %@ (%d) with game id %@ in test mode", [UADSSdkProperties getVersionName], [UADSSdkProperties getVersionCode], gameId);
        } else {
            UADSLogInfo(@"Initializing Unity Ads %@ (%d) with game id %@ in production mode", [UADSSdkProperties getVersionName], [UADSSdkProperties getVersionCode], gameId);
        }

        if ([UADSEnvironmentProperties isEnvironmentOk]) {
            // TODO: Log environment OK
        }
        else {
            // TODO: Log environment not OK and send init sanity check fail to delegate
            _initializing = NO;
        }
        
        [UnityAds setDebugMode:_debugMode];
        
        [UADSClientProperties setGameId:gameId];
        [UADSClientProperties setDelegate:delegate];
        [UADSSdkProperties setTestMode:testMode];
        UADSConfiguration *configuration = [[UADSConfiguration alloc] init];
        
        NSArray *classList = @[
                               @"UADSApiSdk",
                               @"UADSApiStorage",
                               @"UADSApiDeviceInfo",
                               @"UADSApiPlacement",
                               @"UADSApiCache",
                               @"UADSApiUrl",
                               @"UADSApiListener",
                               @"UADSApiAdUnit",
                               @"UADSApiVideoPlayer",
                               @"UADSApiRequest",
                               @"UADSApiAppSheet",
                               @"UADSApiUrlScheme",
                               @"UADSApiNotification",
                               @"UADSApiConnectivity",
                               @"UADSApiWebPlayer",
                               @"UADSApiPreferences",
                               @"UADSApiSensorInfo",
                               @"UADSApiPurchasing"
                               ];
        
        [configuration setWebAppApiClassList:classList];
        [UADSInitialize initialize:configuration];
    }

    _initializing = NO;
}

+ (void)show:(UIViewController *)viewController {
    [UnityAds show:viewController placementId:[UADSPlacement getDefaultPlacement]];
}

+ (void)show:(UIViewController *)viewController placementId:(NSString *)placementId {
    if ([UnityAds isReady:placementId]) {
        UADSLogInfo(@"Unity Ads opening new ad unit for placement %@", placementId);

        [UADSClientProperties setCurrentViewController:viewController];
        
        UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];

        NSDictionary *parametersDictionary = @{@"shouldAutorotate" : [NSNumber numberWithBool:viewController.shouldAutorotate],
                                               @"supportedOrientations" : [NSNumber numberWithInt:[UADSClientProperties getSupportedOrientations]],
                                               @"supportedOrientationsPlist" : [UADSClientProperties getSupportedOrientationsPlist],
                                               @"statusBarOrientation" : [NSNumber numberWithInteger:statusBarOrientation],
                                               @"statusBarHidden" : [NSNumber numberWithBool: [UIApplication sharedApplication].isStatusBarHidden]};

        
        UADSWebViewShowOperation *operation = [[UADSWebViewShowOperation alloc] initWithPlacementId:placementId
                                                                     parametersDictionary:parametersDictionary];
        
        [UADSWebViewMethodInvokeQueue addOperation:operation];
    } else {
        if (!placementId) {
            NSException *exception = [NSException exceptionWithName:@"IllegalArgumentException" reason:@"PlacementID is nil" userInfo:nil];
            @throw exception;
        } else if (![self isSupported]) {
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
    return [UADSClientProperties getDelegate];
}

+ (void)setDelegate:(id<UnityAdsDelegate>)delegate {
    [UADSClientProperties setDelegate:delegate];
}

+ (BOOL)getDebugMode {
    return _debugMode;
}

+ (void)setDebugMode:(BOOL)enableDebugMode {
    _debugMode = enableDebugMode;
    
    if(_debugMode) {
        [UADSDeviceLog setLogLevel:kUnityAdsLogLevelDebug];
    } else {
        [UADSDeviceLog setLogLevel:kUnityAdsLogLevelInfo];
    }
}

+ (BOOL)isSupported {
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        return true;
    }
    return false;
}

+ (BOOL)isReady {
    return [UnityAds isSupported] && [UnityAds isInitialized] && [UADSPlacement isReady];
}

+ (BOOL)isReady:(NSString *)placementId {
    return [UnityAds isSupported] && [UnityAds isInitialized] && [UADSPlacement isReady:placementId];
}

+ (UnityAdsPlacementState)getPlacementState {
    return [UADSPlacement getPlacementState];
}

+ (UnityAdsPlacementState)getPlacementState:(NSString *)placementId {
    return [UADSPlacement getPlacementState:placementId];
}

+ (NSString *)getVersion {
    return [UADSSdkProperties getVersionName];
}

+ (BOOL)isInitialized {
    return [UADSSdkProperties isInitialized];
}

+ (void)handleShowError:(NSString *)placementId unityAdsError:(UnityAdsError)unityAdsError message:(NSString *)message {
    NSString *errorMessage = [NSString stringWithFormat:@"Unity Ads show failed: %@", message];
    UADSLogError(@"%@", errorMessage);
    if ([self getDelegate] && [[self getDelegate]respondsToSelector:@selector(unityAdsDidError:withMessage:)]) {
        [[self getDelegate] unityAdsDidError:unityAdsError withMessage:errorMessage];
    }
    if ([self getDelegate] && [[self getDelegate]respondsToSelector:@selector(unityAdsDidFinish:withFinishState:)]) {
        [[self getDelegate] unityAdsDidFinish:placementId withFinishState:kUnityAdsFinishStateError];
    }
}

@end

