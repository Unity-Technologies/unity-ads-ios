#import "USRVApiSdk.h"
#import "USRVWebViewApp.h"
#import "USRVClientProperties.h"
#import "USRVSdkProperties.h"
#import "USRVWebViewCallback.h"
#import "USRVInitialize.h"
#import "USRVDevice.h"

@implementation USRVApiSdk

+ (void)WebViewExposed_loadComplete: (USRVWebViewCallback *)callback {
    USRVLogDebug(@"Web application loaded");
    [[USRVWebViewApp getCurrentApp] setWebAppLoaded: true];

    [callback invoke:
     [USRVClientProperties getGameId],
     [NSNumber numberWithBool: [USRVSdkProperties isTestMode]],
     [USRVClientProperties getAppName],
     [USRVClientProperties getAppVersion],
     [NSNumber numberWithInt: [USRVSdkProperties getVersionCode]],
     [USRVSdkProperties getVersionName],
     [NSNumber numberWithBool: [USRVClientProperties isAppDebuggable]],
     [USRVSdkProperties getConfigUrl],
     [[[USRVWebViewApp getCurrentApp] configuration] webViewUrl],
     [[[USRVWebViewApp getCurrentApp] configuration] webViewHash] ? [[[USRVWebViewApp getCurrentApp] configuration] webViewHash] : [NSNull null],
     [[[USRVWebViewApp getCurrentApp] configuration] webViewVersion] ? [[[USRVWebViewApp getCurrentApp] configuration] webViewVersion] : [NSNull null],
     [NSNumber numberWithLongLong: [USRVSdkProperties getInitializationTime]],
     [NSNumber numberWithBool: [USRVSdkProperties isReinitialized]],
     [NSNumber numberWithBool: [USRVSdkProperties isPerPlacementLoadEnabled]],
     [NSNumber numberWithBool: [USRVSdkProperties getLatestConfiguration] != nil],
     [USRVDevice getElapsedRealtime],
     nil];
} /* WebViewExposed_loadComplete */

+ (void)WebViewExposed_initComplete: (USRVWebViewCallback *)callback {
    USRVLogDebug(@"Web application initialized");
    [USRVSdkProperties setInitialized: YES];
    [[USRVWebViewApp getCurrentApp] completeWebViewAppInitialization: YES];
    [callback invoke: nil];
}

+ (void)WebViewExposed_initError: (NSString *)message code: (NSNumber *)code callback: (USRVWebViewCallback *)callback {
    USRVLogError(@"Web application failed to load with error : %@", message);
    [[USRVWebViewApp getCurrentApp] setWebAppFailureMessage: message];
    [[USRVWebViewApp getCurrentApp] setWebAppFailureCode: code];
    [[USRVWebViewApp getCurrentApp] completeWebViewAppInitialization: NO];
    [callback invoke: nil];
}

+ (void)WebViewExposed_setDebugMode: (NSNumber *)debugMode callback: (USRVWebViewCallback *)callback {
    [USRVSdkProperties setDebugMode: [debugMode boolValue]];
    [callback invoke: nil];
}

+ (void)WebViewExposed_getDebugMode: (USRVWebViewCallback *)callback {
    [callback invoke: [NSNumber numberWithBool: [USRVSdkProperties getDebugMode]], nil];
}

+ (void)WebViewExposed_logError: (NSString *)message callback: (USRVWebViewCallback *)callback {
    USRVLogError(@"%@", message);
    [callback invoke: nil];
}

+ (void)WebViewExposed_logWarning: (NSString *)message callback: (USRVWebViewCallback *)callback {
    USRVLogWarning(@"%@", message);
    [callback invoke: nil];
}

+ (void)WebViewExposed_logInfo: (NSString *)message callback: (USRVWebViewCallback *)callback {
    USRVLogInfo(@"%@", message);
    [callback invoke: nil];
}

+ (void)WebViewExposed_logDebug: (NSString *)message callback: (USRVWebViewCallback *)callback {
    USRVLogDebug(@"%@", message);
    [callback invoke: nil];
}

+ (void)WebViewExposed_reinitialize: (USRVWebViewCallback *)callback {
    USRVWebViewApp *currentWebViewApp = [USRVWebViewApp getCurrentApp];

    if (currentWebViewApp != nil) {
        [currentWebViewApp setWebAppLoaded: false];
        [currentWebViewApp completeWebViewAppInitialization: false];
    }

    [USRVSdkProperties setReinitialized: true];
    [USRVInitialize initialize: [[USRVWebViewApp getCurrentApp] configuration]];
}

+ (void)WebViewExposed_downloadLatestWebView: (USRVWebViewCallback *)callback {
    USRVLogDebug(@"Unity Ads init: WebView called download");
    USRVDownloadLatestWebViewStatus status = [USRVInitialize downloadLatestWebView];

    [callback invoke: [NSNumber numberWithInt: status], nil];
}

@end
