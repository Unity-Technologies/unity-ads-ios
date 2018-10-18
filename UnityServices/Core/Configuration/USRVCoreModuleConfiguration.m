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

@implementation USRVCoreModuleConfiguration

- (NSArray<NSString*>*)getWebAppApiClassList {
    return @[
             @"USRVApiSdk",
             @"USRVApiStorage",
             @"USRVApiDeviceInfo",
             @"USRVApiCache",
             @"USRVApiUrl",
             @"USRVApiRequest",
             @"USRVApiUrlScheme",
             @"USRVApiNotification",
             @"USRVApiConnectivity",
             @"USRVApiPreferences",
             @"USRVApiSensorInfo",
             @"USRVApiAppSheet",
             @"USRVApiPermissions",
             @"USRVApiMainBundle"
             ];
}

- (BOOL)resetState:(USRVConfiguration *)configuration {
    [USRVDevice initCarrierUpdates];
    [USRVConnectivityUtils initCarrierInfo];
    [USRVSdkProperties setInitialized:false];
    [USRVCacheQueue cancelAllDownloads];
    [USRVWebRequestQueue cancelAllOperations];
    dispatch_async(dispatch_get_main_queue(), ^{
        [USRVConnectivityMonitor stopAll];
    });
    [USRVStorageManager init];
    [USRVNotificationObserver unregisterNotificationObserver];
    [USRVVolumeChange clearAllDelegates];

    return true;
}

- (BOOL)initModuleState:(USRVConfiguration *)configuration {
    return true;
}

- (BOOL)initErrorState:(USRVConfiguration *)configuration state:(NSString *)state message:(NSString *)message {
    return true;
}

- (BOOL)initCompleteState:(USRVConfiguration *)configuration {
    return true;
}

@end
