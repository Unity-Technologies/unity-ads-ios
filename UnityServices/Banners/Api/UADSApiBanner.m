#import "UADSApiBanner.h"
#import "USRVWebViewCallback.h"
#import "UADSBannerView.h"
#import "UADSBannerPosition.h"
#import "USRVWebViewApp.h"
#import "USRVWebViewEventCategory.h"
#import "UADSBannerEvent.h"

@implementation UADSApiBanner

+(void)WebViewExposed_load:(NSArray *)views bannerStyle:(NSString *)bannerStyle width:(NSNumber *)width height:(NSNumber *)height callback:(USRVWebViewCallback *)callback {
    UADSBannerView *banner = [UADSBannerView getOrCreateInstance];
    float widthAsFloat = [width floatValue];
    float heightAsFloat = [height floatValue];
    [banner setAdSize:CGSizeMake(widthAsFloat, heightAsFloat)];
    [banner setPosition:UADSBannerPositionFromNSString(bannerStyle)];
    [banner setFrame:CGRectMake(0, 0, widthAsFloat, heightAsFloat)];
    [banner setViews:views];

    USRVWebViewApp *app = [USRVWebViewApp getCurrentApp];
    if (app) {
        [app sendEvent:NSStringFromBannerEvent(kUnityAdsBannerEventLoaded) category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryBanner) param1:nil];
    }

    [callback invoke:nil];
}

+(void)WebViewExposed_destroy:(USRVWebViewCallback *)callback {
    UADSBannerView *banner = [UADSBannerView getInstance];
    if (banner) {
        [banner close];
        USRVWebViewApp *app = [USRVWebViewApp getCurrentApp];
        [UADSBannerView destroyInstance];
        if (app) {
            [app sendEvent:NSStringFromBannerEvent(kUnityAdsBannerEventDestroyed) category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryBanner) param1:nil];
        }
    }
    [callback invoke:nil];
}

+(void)WebViewExposed_setViewFrame:(NSString *)viewName x:(NSNumber *)x y:(NSNumber *)y width:(NSNumber *)width height:(NSNumber *)height callback:(USRVWebViewCallback *)callback {
    UADSBannerView *banner = [UADSBannerView getInstance];
    if (banner) {
        [banner setViewFrame:viewName x:[x floatValue] y:[y floatValue] width:[width floatValue] height:[height floatValue]];
    }
    [callback invoke:nil];
}

+(void)WebViewExposed_setBannerFrame:(NSString *)bannerStyle width:(NSNumber *)width height:(NSNumber *)height callback:(USRVWebViewCallback *)callback {
    UADSBannerView *banner = [UADSBannerView getInstance];
    if (banner) {
        float widthAsFloat = [width floatValue];
        float heightAsFloat = [height floatValue];
        [banner setAdSize:CGSizeMake(widthAsFloat, heightAsFloat)];
        [banner setPosition:UADSBannerPositionFromNSString(bannerStyle)];
        [banner setFrame:CGRectMake(0, 0, widthAsFloat, heightAsFloat)];
    }
    [callback invoke:nil];
}

+(void)WebViewExposed_setViews:(NSArray *)views callback:(USRVWebViewCallback *)callback {
    UADSBannerView *banner = [UADSBannerView getInstance];
    if (banner) {
        [banner setViews:views];
    }
    [callback invoke:nil];
}

@end
