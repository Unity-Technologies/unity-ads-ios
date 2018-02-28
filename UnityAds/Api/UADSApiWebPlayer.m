#import "UADSApiWebPlayer.h"
#import "UADSApiAdUnit.h"
#import "UADSWebViewCallback.h"
#import "UADSWebPlayerError.h"
#import "UADSAdUnitError.h"

@implementation UADSApiWebPlayer

static NSDictionary *_webPlayerSettings = nil;
static NSDictionary *_webPlayerEventSettings = nil;

+ (NSDictionary *)getWebPlayerSettings {
    return _webPlayerSettings;
}

+ (NSDictionary *)getWebPlayerEventSettings {
    return _webPlayerEventSettings;
}

+ (void)WebViewExposed_setUrl:(NSString *)url callback:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        if ([[UADSApiAdUnit getAdUnit] webPlayerView] != nil) {
            [[[UADSApiAdUnit getAdUnit] webPlayerView] loadUrl:url];
            [callback invoke:nil];
        }
        else {
            [callback error:NSStringFromWebPlayerError(kUnityAdsWebPlayerNull) arg1:nil];
        }
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

+ (void)WebViewExposed_setData:(NSString *)data mimeType:(NSString *)mimeType encoding:(NSString *)encoding callback:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        if ([[UADSApiAdUnit getAdUnit] webPlayerView] != nil) {
            [[[UADSApiAdUnit getAdUnit] webPlayerView] loadData:data mimeType:mimeType encoding:encoding];
            [callback invoke:nil];
        }
        else {
            [callback error:NSStringFromWebPlayerError(kUnityAdsWebPlayerNull) arg1:nil];
        }
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

+ (void)WebViewExposed_setDataWithUrl:(NSString *)baseUrl data:(NSString *)data mimeType:(NSString *)mimeType encoding:(NSString *)encoding callback:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        if ([[UADSApiAdUnit getAdUnit] webPlayerView] != nil) {
            [[[UADSApiAdUnit getAdUnit] webPlayerView] loadData:data mimeType:mimeType encoding:encoding baseUrl:baseUrl];
            [callback invoke:nil];
        }
        else {
            [callback error:NSStringFromWebPlayerError(kUnityAdsWebPlayerNull) arg1:nil];
        }
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

+ (void)WebViewExposed_setSettings:(NSDictionary*)webPlayerSettings ignoredSettings:(NSDictionary *)ignoredSettings callback:(UADSWebViewCallback *)callback {
    _webPlayerSettings = webPlayerSettings;
    [callback invoke:nil];
}

+ (void)WebViewExposed_setEventSettings:(NSDictionary *)settings callback:(UADSWebViewCallback *)callback {
    _webPlayerEventSettings = settings;
    if ([UADSApiAdUnit getAdUnit]) {
        if ([[UADSApiAdUnit getAdUnit] webPlayerView] != nil) {
            [[[UADSApiAdUnit getAdUnit] webPlayerView] setEventSettings:settings];
        }
    }
    [callback invoke:nil];

}

+ (void)WebViewExposed_clearSettings:(UADSWebViewCallback *)callback {
    _webPlayerSettings = nil;
    _webPlayerEventSettings = nil;
    [callback invoke:nil];
}

+ (void)WebViewExposed_sendEvent:(NSString *)params callback:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        if ([[UADSApiAdUnit getAdUnit] webPlayerView] != nil) {
            [[[UADSApiAdUnit getAdUnit] webPlayerView] receiveEvent:params];
            [callback invoke:nil];
        }
        else {
            [callback error:NSStringFromWebPlayerError(kUnityAdsWebPlayerNull) arg1:nil];
        }
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}
@end
