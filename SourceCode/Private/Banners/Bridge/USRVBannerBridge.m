#import "USRVBannerBridge.h"
#import "USRVWebViewApp.h"
#include "USRVWebViewEventCategory.h"

@implementation USRVBannerBridge

+ (void)destroyBannerWithId: (NSString *)bannerAdId {
    USRVWebViewApp *app = [USRVWebViewApp getCurrentApp];

    if (app) {
        [app sendEvent: UADSNSStringFromBannerEvent(UADSBannerEventDestroyBanner)
              category: USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryBanner)
                params: @[bannerAdId]];
    }
}

+ (void)bannerDidResizeWithBannerId: (NSString *)bannerAdId frame: (CGRect)frame alpha: (CGFloat)alpha {
    USRVWebViewApp *app = [USRVWebViewApp getCurrentApp];

    if (app) {
        [app sendEvent: UADSNSStringFromBannerEvent(UADSBannerEventResized)
              category: USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryBanner)
                params: @[
             bannerAdId,
             [NSNumber numberWithFloat: frame.origin.x],
             [NSNumber numberWithFloat: frame.origin.y],
             [NSNumber numberWithFloat: frame.size.width],
             [NSNumber numberWithFloat: frame.size.height],
             [NSNumber numberWithFloat: alpha]
        ]];
    }
}

+ (void)bannerVisibilityChangedWithBannerId: (NSString *)bannerAdId bannerVisibility: (UADSBannerVisibility)bannerVisibility {
    USRVWebViewApp *app = [USRVWebViewApp getCurrentApp];

    if (app) {
        [app sendEvent: UADSNSStringFromBannerEvent(UADSBannerEventVisibilityChanged)
              category: USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryBanner)
                params: @[
             bannerAdId,
             [NSNumber numberWithInteger: bannerVisibility]
        ]];
    }
}

+ (void)bannerDidLoadedWithBannerId: (NSString *)bannerAdId {
    USRVWebViewApp *app = [USRVWebViewApp getCurrentApp];

    if (app) {
        [app sendEvent: UADSNSStringFromBannerEvent(UADSBannerEventLoaded)
              category: USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryBanner)
                params: @[bannerAdId]];
    }
}

+ (void)bannerDidDestroyWithBannerId: (NSString *)bannerAdId {
    USRVWebViewApp *app = [USRVWebViewApp getCurrentApp];

    if (app) {
        [app sendEvent: UADSNSStringFromBannerEvent(UADSBannerEventDestroyed)
              category: USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryBanner)
                params: @[bannerAdId]];
    }
}

+ (void)bannerDidAttachWithBannerId: (NSString *)bannerAdId {
    USRVWebViewApp *app = [USRVWebViewApp getCurrentApp];

    if (app) {
        [app sendEvent: UADSNSStringFromBannerEvent(UADSBannerEventAttached)
              category: USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryBanner)
                params: @[bannerAdId]];
    }
}

+ (void)bannerDidDetachWithBannerId: (NSString *)bannerAdId {
    USRVWebViewApp *app = [USRVWebViewApp getCurrentApp];

    if (app) {
        [app sendEvent: UADSNSStringFromBannerEvent(UADSBannerEventDetached)
              category: USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryBanner)
                params: @[bannerAdId]];
    }
}

@end
