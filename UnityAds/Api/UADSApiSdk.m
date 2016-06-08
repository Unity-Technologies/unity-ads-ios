#import "UADSApiSdk.h"
#import "UADSWebViewApp.h"
#import "UADSClientProperties.h"
#import "UADSSdkProperties.h"
#import "UADSWebViewCallback.h"
#import "UnityAds.h"
#import "UADSInitialize.h"

@implementation UADSApiSdk

+ (void)WebViewExposed_loadComplete:(UADSWebViewCallback *)callback {
    UADSLogDebug(@"Web application loaded");
    [[UADSWebViewApp getCurrentApp] setWebAppLoaded:true];

    [callback invoke:
        [UADSClientProperties getGameId],
        [NSNumber numberWithBool:[UADSSdkProperties isTestMode]],
        [UADSClientProperties getAppName],
        [UADSClientProperties getAppVersion],
        [NSNumber numberWithInt:[UADSSdkProperties getVersionCode]],
        [UADSSdkProperties getVersionName],
        [NSNumber numberWithBool:[UADSClientProperties isAppDebuggable]],
        [[[UADSWebViewApp getCurrentApp] configuration] configUrl],
        [[[UADSWebViewApp getCurrentApp] configuration] webViewUrl],
        [[[UADSWebViewApp getCurrentApp] configuration] webViewHash],
        [[[UADSWebViewApp getCurrentApp] configuration] webViewVersion],
     nil];
}

+ (void)WebViewExposed_initComplete:(UADSWebViewCallback *)callback {
    UADSLogDebug(@"Web application initialized");
    [UADSSdkProperties setInitialized:true];
    [[UADSWebViewApp getCurrentApp] setWebAppInitialized:true];
    [callback invoke:nil];
}

+ (void)WebViewExposed_setDebugMode:(NSNumber *)debugMode callback:(UADSWebViewCallback *)callback {
    [UnityAds setDebugMode:[debugMode boolValue]];
    [callback invoke:nil];
}

+ (void)WebViewExposed_getDebugMode:(UADSWebViewCallback *)callback {
    [callback invoke:[NSNumber numberWithBool:[UnityAds getDebugMode]]];
}

+ (void)WebViewExposed_logError:(NSString *)message callback:(UADSWebViewCallback *)callback {
    UADSLogError(@"%@", message);
    [callback invoke:nil];
}

+ (void)WebViewExposed_logWarning:(NSString *)message callback:(UADSWebViewCallback *)callback {
    UADSLogWarning(@"%@", message);
    [callback invoke:nil];
}

+ (void)WebViewExposed_logInfo:(NSString *)message callback:(UADSWebViewCallback *)callback {
    UADSLogInfo(@"%@", message);
    [callback invoke:nil];
}

+ (void)WebViewExposed_logDebug:(NSString *)message callback:(UADSWebViewCallback *)callback {
    UADSLogDebug(@"%@", message);
    [callback invoke:nil];
}

+ (void)WebViewExposed_setShowTimeout:(NSNumber *)timeout callback:(UADSWebViewCallback *)callback {
    [UADSSdkProperties setShowTimeout:[timeout intValue]];
    [callback invoke:nil];
}

+ (void)WebViewExposed_reinitialize:(UADSWebViewCallback *)callback {
    [UADSInitialize initialize:[[UADSWebViewApp getCurrentApp] configuration]];
}

@end