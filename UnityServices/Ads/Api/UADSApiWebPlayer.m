#import "UADSApiWebPlayer.h"
#import "UADSApiAdUnit.h"
#import "USRVWebViewCallback.h"
#import "UADSWebPlayerSettingsManager.h"
#import "UADSWebPlayerViewManager.h"
#import "UADSWebPlayerBridge.h"

@implementation UADSApiWebPlayer

+ (void)WebViewExposed_setUrl:(NSString *)url viewId:(NSString *)viewId callback:(USRVWebViewCallback *)callback {
    UADSWebPlayerView *webPlayerView = [[UADSWebPlayerViewManager sharedInstance] getWebPlayerViewWithViewId:viewId];
    dispatch_async(dispatch_get_main_queue(), ^() {
        if (webPlayerView) {
            [webPlayerView loadUrl:url];
        }
    });
    [callback invoke:nil];
}

+ (void)WebViewExposed_setData:(NSString *)data mimeType:(NSString *)mimeType encoding:(NSString *)encoding viewId:(NSString *)viewId callback:(USRVWebViewCallback *)callback {
    UADSWebPlayerView *webPlayerView = [[UADSWebPlayerViewManager sharedInstance] getWebPlayerViewWithViewId:viewId];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (webPlayerView) {
            [webPlayerView loadData:data mimeType:mimeType encoding:encoding];
        }
    });
    [callback invoke:nil];
}

+ (void)WebViewExposed_setDataWithUrl:(NSString *)baseUrl data:(NSString *)data mimeType:(NSString *)mimeType encoding:(NSString *)encoding viewId:(NSString *)viewId callback:(USRVWebViewCallback *)callback {
    UADSWebPlayerView *webPlayerView = [[UADSWebPlayerViewManager sharedInstance] getWebPlayerViewWithViewId:viewId];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (webPlayerView) {
            [webPlayerView loadData:data mimeType:mimeType encoding:encoding baseUrl:baseUrl];
        }
    });
    [callback invoke:nil];
}

+ (void)WebViewExposed_setSettings:(NSDictionary *)webPlayerSettings ignoredSettings:(NSDictionary *)ignoredSettings viewId:(NSString *)viewId callback:(USRVWebViewCallback *)callback {
    // Update UADSWebPlayerSettingsManager with updated settings
    [[UADSWebPlayerSettingsManager sharedInstance] addWebPlayerSettings:viewId settings:webPlayerSettings];
    // Update UADSWebPlayerView with updated settings if there is a view
    UADSWebPlayerView *webPlayerView = [[UADSWebPlayerViewManager sharedInstance] getWebPlayerViewWithViewId:viewId];
    if (webPlayerView) {
        [webPlayerView setWebPlayerSettings:webPlayerSettings];
    }
    [callback invoke:nil];
}

+ (void)WebViewExposed_setEventSettings:(NSDictionary *)settings viewId:(NSString *)viewId callback:(USRVWebViewCallback *)callback {
    // Update UADSWebPlayerSettingsManager with updated settings
    [[UADSWebPlayerSettingsManager sharedInstance] addWebPlayerEventSettings:viewId settings:settings];
    // Update UADSWebPlayerView with updated settings if there is a view
    UADSWebPlayerView *webPlayerView = [[UADSWebPlayerViewManager sharedInstance] getWebPlayerViewWithViewId:viewId];
    if (webPlayerView) {
        [webPlayerView setEventSettings:settings];
    }
    [callback invoke:nil];
}

+ (void)WebViewExposed_clearSettings:(NSString *)viewId callback:(USRVWebViewCallback *)callback {
    // Remove settings from UADSWebPlayerSettingsManager
    UADSWebPlayerSettingsManager *settingsManager = [UADSWebPlayerSettingsManager sharedInstance];
    [settingsManager removeWebPlayerSettings:viewId];
    [settingsManager removeWebPlayerEventSettings:viewId];
    // Update UADSWebPlayerView settings to nil if there is a view
    UADSWebPlayerView *webPlayerView = [[UADSWebPlayerViewManager sharedInstance] getWebPlayerViewWithViewId:viewId];
    if (webPlayerView) {
        [webPlayerView setWebPlayerSettings:nil];
        [webPlayerView setEventSettings:nil];
    }
    [callback invoke:nil];
}

+ (void)WebViewExposed_sendEvent:(NSString *)params viewId:(NSString *)viewId callback:(USRVWebViewCallback *)callback {
    UADSWebPlayerView *webPlayerView = [[UADSWebPlayerViewManager sharedInstance] getWebPlayerViewWithViewId:viewId];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (webPlayerView) {
            [webPlayerView receiveEvent:params];
        }
    });
    [callback invoke:nil];
}

+ (void)WebViewExposed_getFrame:(NSString *)callId viewId:(NSString *)viewId callback:(USRVWebViewCallback *)callback {
    UADSWebPlayerView *webPlayerView = [[UADSWebPlayerViewManager sharedInstance] getWebPlayerViewWithViewId:viewId];
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect frame = CGRectZero;
        CGFloat alpha = 0;
        if (webPlayerView) {
            // Push the new frame to webview
            alpha = webPlayerView.alpha;
            UIWindow *window;
            if ([[[UIApplication sharedApplication] delegate] window]) {
                window = [[[UIApplication sharedApplication] delegate] window];
            } else {
                window = webPlayerView.window;
            }
            if (window) {
                frame = [webPlayerView convertRect:webPlayerView.frame toView:window];
            }
        }
        [UADSWebPlayerBridge sendGetFrameResponse:callId viewId:viewId frame:frame alpha:alpha];
    });
    [callback invoke:nil];
}

@end
