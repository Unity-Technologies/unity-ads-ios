#import "USRVCoreModuleConfiguration.h"
#import "USRVDevice.h"
#import "USRVVolumeChange.h"
#import "USRVStorageManager.h"
#import "USRVNotificationObserver.h"
#import "USRVWebRequestQueue.h"
#import "USRVCacheQueue.h"
#import "USRVConnectivityUtils.h"
#import "USRVSdkProperties.h"
#import "USRVConnectivityMonitor.h"
#import "USRVInitialize.h"
#import "USRVInitializationNotificationCenter.h"
#import "USRVSDKMetrics.h"
#import "UADSServiceProvider.h"
@implementation USRVCoreModuleConfiguration

- (NSArray<NSString *> *)getWebAppApiClassList {
    return @[
        @"USRVApiSdk",
        @"USRVApiStorage",
        @"USRVApiDeviceInfo",
        @"USRVApiClassDetection",
        @"USRVApiCache",
        @"USRVApiUrl",
        @"USRVApiRequest",
        @"USRVApiUrlScheme",
        @"USRVApiNotification",
        @"USRVApiConnectivity",
        @"USRVApiPreferences",
        @"USRVApiSensorInfo",
        @"USRVApiPermissions",
        @"USRVApiMainBundle",
        @"USRVApiWebAuth",
        @"USRVApiTrackingManager",
        @"USRVApiSKAdNetwork"
    ];
} /* getWebAppApiClassList */

- (BOOL)resetState: (USRVConfiguration *)configuration {
    [USRVDevice initCarrierUpdates];
    [USRVConnectivityUtils initCarrierInfo];
    [USRVSdkProperties setInitialized: NO];
    [USRVCacheQueue cancelAllDownloads];
    [USRVWebRequestQueue cancelAllOperations];
    dispatch_async(dispatch_get_main_queue(), ^{
        [USRVConnectivityMonitor stopAll];
    });
    [USRVStorageManager sharedInstance];
    [USRVNotificationObserver unregisterNotificationObserver];
    [USRVVolumeChange clearAllDelegates];

    return true;
}

- (BOOL)initModuleState: (USRVConfiguration *)configuration {
    return true;
}

- (BOOL)initErrorState: (USRVConfiguration *)configuration code: (UADSErrorState)stateCode message: (NSString *)message {
    [UADSServiceProvider.sharedInstance.configurationSaver saveConfiguration: configuration];
    [[USRVInitializationNotificationCenter sharedInstance] triggerSdkInitializeDidFail: @"Unity Ads SDK failed to initialize"
                                                                                  code: stateCode];

    NSString *errorMessage = @"Unity Ads failed to initialize due to internal error";

    if (uads_isWebViewErrorState(stateCode)) {
        errorMessage = message;
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        [USRVSdkProperties notifyInitializationFailed: kUnityInitializationErrorInternalError
                                     withErrorMessage: errorMessage];
    });

    return true;
}

- (BOOL)initCompleteState: (USRVConfiguration *)configuration {
    [[USRVInitializationNotificationCenter sharedInstance] triggerSdkDidInitialize];

    dispatch_async(dispatch_get_main_queue(), ^{
        [USRVSdkProperties notifyInitializationComplete];
    });
    return true;
}

@end
