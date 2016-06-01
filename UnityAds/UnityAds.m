#import "UnityAds.h"
#import "UADSURLProtocol.h"
#import "UADSEnvironmentProperties.h"
#import "UADSClientProperties.h"
#import "UADSSdkProperties.h"
#import "UADSConfiguration.h"
#import "UADSInitialize.h"
#import "UADSViewController.h"
#import "UADSWebViewApp.h"
#import "UADSApiPlacement.h"

#import "UADSWebViewMethodInvokeQueue.h"
#import "UADSWebViewShowOperation.h"

NSString* const kUnityAdsErrorDomain = @"com.unity3d.ads.UnityAds.Error";



static BOOL _debugMode = YES;
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
        didError = YES;
        unityAdsError = kUnityAdsErrorInitSanityCheckFail;
    }
    // Bad game id or nil delegate
    if ([gameId length] == 0 || delegate == nil) {
        didError = YES;
        unityAdsError = kUnityAdsErrorInvalidArgument;
    }
    
    if (didError) {
        if (delegate != nil && [delegate respondsToSelector:@selector(unityAdsDidError:withMessage:)]) {
            [delegate unityAdsDidError:unityAdsError withMessage:@""];
        }
    }
    
    _initializing = YES;
    @synchronized (self) {
        UADSLog(@"Testmode: %@", testMode ? @"TEST" : @"PRODUCTION");
        
        if ([UADSEnvironmentProperties isEnvironmentOk]) {
            // TODO: Log environment OK
        }
        else {
            // TODO: Log environment not OK and send init sanity check fail to delegate
            _initializing = NO;
        }
        
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
                               @"UADSApiConnectivity"
                               ];
        
        [configuration setWebAppApiClassList:classList];
        [UADSInitialize initialize:configuration];
    }

    _initializing = NO;
}

+ (void)show:(UIViewController *)viewController {
    [UnityAds show:viewController placementId:[UADSApiPlacement getDefaultPlacement]];
}

+ (void)show:(UIViewController *)viewController placementId:(NSString *)placementId {
    if ([UnityAds isReady:placementId]) {
        [UADSClientProperties setCurrentViewController:viewController];
        
        int supportedOrientations = [[UIApplication sharedApplication]supportedInterfaceOrientationsForWindow:[[UIApplication sharedApplication]keyWindow]];

        NSDictionary *parametersDictioanry = @{@"shouldAutorotate" : [NSNumber numberWithBool:viewController.shouldAutorotate],
                                               @"supportedOrientations" : [NSNumber numberWithInt:supportedOrientations], };

        
        UADSWebViewShowOperation *operation = [[UADSWebViewShowOperation alloc] initWithPlacementId:placementId
                                                                     parametersDictionary:parametersDictioanry];
        
        [UADSWebViewMethodInvokeQueue addOperation:operation];
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
    UADSLog(@"%@", _debugMode ? @"debug enabled" : @"debug disabled" );
}

+ (BOOL)isSupported {
    if (NSFoundationVersionNumber >= NSFoundationVersionNumber_iOS_7_0) {
        return true;
    }
    return false;
}

+ (BOOL)isReady {
    return [UnityAds isSupported] && [UnityAds isInitialized] && [UADSApiPlacement isReady];
}

+ (BOOL)isReady:(NSString *)placementId {
    return [UnityAds isSupported] && [UnityAds isInitialized] && [UADSApiPlacement isReady:placementId];
}

+ (UnityAdsPlacementState)getPlacementState {
    return [UADSApiPlacement getPlacementState];
}

+ (UnityAdsPlacementState)getPlacementStateWithPlacementId:(NSString *)placementId {
    return [UADSApiPlacement getPlacementState:placementId];
}

+ (NSString *)getVersion {
    return [UADSSdkProperties getVersionName];
}

+ (BOOL)isInitialized {
    return [UADSSdkProperties isInitialized];
}

+ (NSString *)NSStringFromUnityAdsError:(UnityAdsError) error {
    switch (error) {
        case kUnityAdsErrorAdBlockerDetected:
            return @"AdBlockerDetected";
            break;
        case kUnityAdsErrorDeviceIdError:
            return @"DeviceIdError";
            break;
        case kUnityAdsErrorFileIoError:
            return @"ErrorFileIoError";
            break;
        case kUnityAdsErrorInitSanityCheckFail:
            return @"InitSanityCheckFail";
            break;
        case kUnityAdsErrorInitializedFailed:
            return @"InitializedFailed";
            break;
        case kUnityAdsErrorInternalError:
            return @"InternalError";
            break;
        case kUnityAdsErrorInvalidArgument:
            return @"InvalidArgument";
            break;
        case kUnityAdsErrorNotInitialized:
            return @"NotInitialized";
            break;
        case kUnityAdsErrorShowError:
            return @"ShowError";
            break;
        case kUnityAdsErrorVideoPlayerError:
            return @"VideoPlayerError";
            break;
    }
}

@end

