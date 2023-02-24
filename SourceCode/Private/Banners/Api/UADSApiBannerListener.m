#import "UADSApiBannerListener.h"
#import "USRVWebViewCallback.h"
#import "UADSBannerLoadModule.h"

@implementation UADSApiBannerListener

+ (void)WebViewExposed_sendLoadEvent: (NSString *)bannerAdId callback: (USRVWebViewCallback *)callback {
    [[UADSBannerLoadModule sharedInstance] sendAdLoadedForPlacementID:@"" andListenerID:bannerAdId];
    [callback invoke: nil];
}

+ (void)WebViewExposed_sendClickEvent: (NSString *)bannerAdId callback: (USRVWebViewCallback *)callback {
    [[UADSBannerLoadModule sharedInstance] sendClickEventForListenerID:bannerAdId];
    [callback invoke: nil];
}

+ (void)WebViewExposed_sendLeaveApplicationEvent: (NSString *)bannerAdId callback: (USRVWebViewCallback *)callback {
    [[UADSBannerLoadModule sharedInstance] sendLeaveApplicationEventForListenerID:bannerAdId];
    [callback invoke: nil];
}

+ (void)WebViewExposed_sendErrorEvent: (NSString *)bannerAdId code: (NSNumber *)code message: (NSString *)message callback: (USRVWebViewCallback *)callback {
    [[UADSBannerLoadModule sharedInstance] sendAdFailedToLoadForPlacementID:@"" listenerID:bannerAdId message:message error: [code integerValue]];
    [callback invoke: nil];
}

@end
