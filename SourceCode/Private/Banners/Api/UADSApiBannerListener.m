#import "UADSApiBannerListener.h"
#import "USRVWebViewCallback.h"
#import "UADSBannerViewManager.h"

@implementation UADSApiBannerListener

+ (void)WebViewExposed_sendLoadEvent: (NSString *)bannerAdId callback: (USRVWebViewCallback *)callback {
    [[UADSBannerViewManager sharedInstance] triggerBannerDidLoad: bannerAdId];
    [callback invoke: nil];
}

+ (void)WebViewExposed_sendClickEvent: (NSString *)bannerAdId callback: (USRVWebViewCallback *)callback {
    [[UADSBannerViewManager sharedInstance] triggerBannerDidClick: bannerAdId];
    [callback invoke: nil];
}

+ (void)WebViewExposed_sendLeaveApplicationEvent: (NSString *)bannerAdId callback: (USRVWebViewCallback *)callback {
    [[UADSBannerViewManager sharedInstance] triggerBannerDidLeaveApplication: bannerAdId];
    [callback invoke: nil];
}

+ (void)WebViewExposed_sendErrorEvent: (NSString *)bannerAdId code: (NSNumber *)code message: (NSString *)message callback: (USRVWebViewCallback *)callback {
    UADSBannerError *error = [[UADSBannerError alloc] initWithCode: [code integerValue]
                                                          userInfo: @{
                                  NSLocalizedDescriptionKey: message
    }];

    [[UADSBannerViewManager sharedInstance] triggerBannerDidError: bannerAdId
                                                            error: error];
    [callback invoke: nil];
}

@end
