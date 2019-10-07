#import "USRVBannerBridge.h"
#import "USRVWebViewApp.h"
#include "USRVWebViewEventCategory.h"
#import "UADSBannerViewManager.h"

@implementation USRVBannerBridge

+ (void)loadBannerPlacement:(NSString *)placementId bannerAdId:(NSString *)bannerAdId size:(CGSize)size {
    USRVWebViewApp *app = [USRVWebViewApp getCurrentApp];
    if (app) {
        NSNumber *width = [NSNumber numberWithFloat:size.width];
        NSNumber *height = [NSNumber numberWithFloat:size.height];
        [app sendEvent:UADSNSStringFromBannerEvent(UADSBannerEventLoadPlacement) category:USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryBanner) params:@[placementId, bannerAdId, width, height]];
    } else {
        UADSBannerError *error = [[UADSBannerError alloc] initWithCode:UADSBannerErrorCodeNativeError userInfo:@{
                NSLocalizedDescriptionKey: @"WebViewApp was not available, this is likely because UnityAds has not been initialized"
        }];
        [[UADSBannerViewManager sharedInstance] triggerBannerDidError:bannerAdId error:error];
    }
}

+ (void)destroyBannerWithId:(NSString *)bannerAdId {
    USRVWebViewApp *app = [USRVWebViewApp getCurrentApp];
    if (app) {
        [app sendEvent:UADSNSStringFromBannerEvent(UADSBannerEventDestroyBanner) category:USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryBanner) params:@[bannerAdId]];
    }
}

+ (void)bannerDidResizeWithBannerId:(NSString *)bannerAdId frame:(CGRect)frame alpha:(CGFloat)alpha {
    USRVWebViewApp *app = [USRVWebViewApp getCurrentApp];
    if (app) {
        [app sendEvent:UADSNSStringFromBannerEvent(UADSBannerEventResized) category:USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryBanner) params:@[
                bannerAdId,
                [NSNumber numberWithFloat:frame.origin.x],
                [NSNumber numberWithFloat:frame.origin.y],
                [NSNumber numberWithFloat:frame.size.width],
                [NSNumber numberWithFloat:frame.size.height],
                [NSNumber numberWithFloat:alpha]
        ]];
    }
}

+ (void)bannerVisibilityChangedWithBannerId:(NSString *)bannerAdId bannerVisibility:(UADSBannerVisibility)bannerVisibility {
    USRVWebViewApp *app = [USRVWebViewApp getCurrentApp];
    if (app) {
        [app sendEvent:UADSNSStringFromBannerEvent(UADSBannerEventVisibilityChanged) category:USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryBanner) params:@[
                bannerAdId,
                [NSNumber numberWithInteger:bannerVisibility]
        ]];
    }
}

+ (void)bannerDidLoadedWithBannerId:(NSString *)bannerAdId {
    USRVWebViewApp *app = [USRVWebViewApp getCurrentApp];
    if (app) {
        [app sendEvent:UADSNSStringFromBannerEvent(UADSBannerEventLoaded) category:USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryBanner) params:@[bannerAdId]];
    }
}

+ (void)bannerDidDestroyWithBannerId:(NSString *)bannerAdId {
    USRVWebViewApp *app = [USRVWebViewApp getCurrentApp];
    if (app) {
        [app sendEvent:UADSNSStringFromBannerEvent(UADSBannerEventDestroyed) category:USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryBanner) params:@[bannerAdId]];
    }
}

+ (void)bannerDidAttachWithBannerId:(NSString *)bannerAdId {
    USRVWebViewApp *app = [USRVWebViewApp getCurrentApp];
    if (app) {
        [app sendEvent:UADSNSStringFromBannerEvent(UADSBannerEventAttached) category:USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryBanner) params:@[bannerAdId]];
    }
}

+ (void)bannerDidDetachWithBannerId:(NSString *)bannerAdId {
    USRVWebViewApp *app = [USRVWebViewApp getCurrentApp];
    if (app) {
        [app sendEvent:UADSNSStringFromBannerEvent(UADSBannerEventDetached) category:USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryBanner) params:@[bannerAdId]];
    }
}

@end
