#import "UADSApiWebPlayer.h"
#import "UADSApiAdUnit.h"
#import "USRVWebViewCallback.h"
#import "UADSWebPlayerError.h"
#import "UADSAdUnitError.h"
#import "UADSBannerView.h"

@implementation UADSApiWebPlayer

static NSDictionary *_webPlayerSettings = nil;
static NSDictionary *_webPlayerEventSettings = nil;

+ (NSDictionary *)getWebPlayerSettings {
    return _webPlayerSettings;
}

+ (NSDictionary *)getWebPlayerEventSettings {
    return _webPlayerEventSettings;
}

+ (void)WebViewExposed_setUrl:(NSString *)url viewId:(NSString *)viewId callback:(USRVWebViewCallback *)callback {
    UADSWebPlayerView *view = [self getWebPlayer:viewId];
    if (view == nil) {
        [callback error:NSStringFromWebPlayerError(kUnityAdsWebPlayerNull) arg1:nil];
        return;
    }
    [view loadUrl:url];
    [callback invoke:nil];
}

+ (void)WebViewExposed_setData:(NSString *)data mimeType:(NSString *)mimeType encoding:(NSString *)encoding viewId:(NSString *)viewId callback:(USRVWebViewCallback *)callback {
    UADSWebPlayerView *view = [self getWebPlayer:viewId];
    if (view == nil) {
        [callback error:NSStringFromWebPlayerError(kUnityAdsWebPlayerNull) arg1:nil];
        return;
    }
    [view loadData:data mimeType:mimeType encoding:encoding];
    [callback invoke:nil];
}

+ (void)WebViewExposed_setDataWithUrl:(NSString *)baseUrl data:(NSString *)data mimeType:(NSString *)mimeType encoding:(NSString *)encoding viewId:(NSString *)viewId callback:(USRVWebViewCallback *)callback {
    UADSWebPlayerView *view = [self getWebPlayer:viewId];
    if (view == nil) {
        [callback error:NSStringFromWebPlayerError(kUnityAdsWebPlayerNull) arg1:nil];
        return;
    }
    [view loadData:data mimeType:mimeType encoding:encoding baseUrl:baseUrl];
    [callback invoke:nil];
}

+ (void)WebViewExposed_setSettings:(NSDictionary*)webPlayerSettings ignoredSettings:(NSDictionary *)ignoredSettings viewId:(NSString *)viewId callback:(USRVWebViewCallback *)callback {
    if ([viewId isEqualToString:@"webplayer"]) {
        _webPlayerSettings = webPlayerSettings;
    } else if ([viewId isEqualToString:@"bannerplayer"]) {
        [UADSBannerView setWebPlayerSettings:webPlayerSettings];
    } else {
        [callback error:[NSString stringWithFormat:@"Unknown view id %@", viewId] arg1: nil];
        return;
    }
    [callback invoke:nil];
}

+ (void)WebViewExposed_setEventSettings:(NSDictionary *)settings viewId:(NSString *)viewId callback:(USRVWebViewCallback *)callback {
    if ([viewId isEqualToString:@"webplayer"]) {
        _webPlayerEventSettings = settings;
    } else if ([viewId isEqualToString:@"bannerplayer"]) {
        [UADSBannerView setWebPlayerEventSettings:settings];
    } else {
        [callback error:[NSString stringWithFormat:@"Unknown view id %@", viewId] arg1: nil];
        return;
    }
    [callback invoke:nil];
}

+ (void)WebViewExposed_clearSettings:(NSString *)viewId callback:(USRVWebViewCallback *)callback {
    if ([viewId isEqualToString:@"webplayer"]) {
        _webPlayerSettings = nil;
        _webPlayerEventSettings = nil;
    } else if ([viewId isEqualToString:@"bannerplayer"]) {
        [[[UADSBannerView getInstance] webPlayer] setWebPlayerSettings:nil];
    } else {
        [callback error:[NSString stringWithFormat:@"Unknown view id %@", viewId] arg1: nil];
    }
    [callback invoke:nil];
}

+ (void)WebViewExposed_sendEvent:(NSString *)params viewId:(NSString *)viewId callback:(USRVWebViewCallback *)callback {
    UADSWebPlayerView *view = [self getWebPlayer:viewId];
    if (view == nil) {
        [callback error:NSStringFromWebPlayerError(kUnityAdsWebPlayerNull) arg1:nil];
        return;
    }
    [view receiveEvent:params];
    [callback invoke:nil];
}

+ (UADSWebPlayerView *)getWebPlayer:(NSString *)viewId {
    if ([viewId isEqualToString:@"webplayer"]) {
        if ([UADSApiAdUnit getAdUnit] && [[UADSApiAdUnit getAdUnit] getViewHandler:@"webplayer"]) {
            return (UADSWebPlayerView *)[[[UADSApiAdUnit getAdUnit] getViewHandler:@"webplayer"] getView];
        }
    } else if ([viewId isEqualToString:@"bannerplayer"]) {
        return [[UADSBannerView getInstance] webPlayer];
    }

    return nil;
}

@end
