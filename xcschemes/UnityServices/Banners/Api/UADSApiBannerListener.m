#import "UADSApiBannerListener.h"
#import "UADSBanner.h"
#import "USRVWebViewCallback.h"
#import "UADSBannerView.h"
#import "UADSBannerProperties.h"

@implementation UADSApiBannerListener

+(void)WebViewExposed_sendShowEvent:(NSString *)placementId callback:(USRVWebViewCallback *)callback {
    id <UnityAdsBannerDelegate> delegate = [UADSBannerProperties getDelegate];
    if (delegate && [delegate respondsToSelector:@selector(unityAdsBannerDidShow:)]) {
        [delegate unityAdsBannerDidShow:placementId];
    }
    [callback invoke:nil];
}

+(void)WebViewExposed_sendHideEvent:(NSString *)placementId callback:(USRVWebViewCallback *)callback {
    id <UnityAdsBannerDelegate> delegate = [UADSBannerProperties getDelegate];
    if (delegate && [delegate respondsToSelector:@selector(unityAdsBannerDidHide:)]) {
        [delegate unityAdsBannerDidHide:placementId];
    }
    [callback invoke:nil];
}

+(void)WebViewExposed_sendClickEvent:(NSString *)placementId callback:(USRVWebViewCallback *)callback {
    id <UnityAdsBannerDelegate> delegate = [UADSBannerProperties getDelegate];
    if (delegate && [delegate respondsToSelector:@selector(unityAdsBannerDidClick:)]) {
        [delegate unityAdsBannerDidClick:placementId];
    }
    [callback invoke:nil];
}

+(void)WebViewExposed_sendErrorEvent:(NSString *)message callback:(USRVWebViewCallback *)callback {
    id <UnityAdsBannerDelegate> delegate = [UADSBannerProperties getDelegate];
    if (delegate && [delegate respondsToSelector:@selector(unityAdsBannerDidError:)]) {
        [delegate unityAdsBannerDidError:message];
    }
    [callback invoke:nil];
}

+(void)WebViewExposed_sendLoadEvent:(NSString *)placementId callback:(USRVWebViewCallback *)callback {
    id <UnityAdsBannerDelegate> delegate = [UADSBannerProperties getDelegate];
    if (delegate && [delegate respondsToSelector:@selector(unityAdsBannerDidLoad:view:)]) {
        [delegate unityAdsBannerDidLoad:placementId view:[UADSBannerView getInstance]];
    }
    [callback invoke:nil];
}

+(void)WebViewExposed_sendUnloadEvent:(NSString *)placementId callback:(USRVWebViewCallback *)callback {
    id <UnityAdsBannerDelegate> delegate = [UADSBannerProperties getDelegate];
    if (delegate && [delegate respondsToSelector:@selector(unityAdsBannerDidUnload:)]) {
        [delegate unityAdsBannerDidUnload:placementId];
    }
    [callback invoke:nil];
}

@end
