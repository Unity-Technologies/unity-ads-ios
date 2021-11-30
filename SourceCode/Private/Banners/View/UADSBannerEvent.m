#import "UADSBannerEvent.h"

NSString *bannerResized = @"BANNER_RESIZED";
NSString *bannerVisibilityChanged = @"BANNER_VISIBILITY_CHANGED";
NSString *bannerLoaded = @"BANNER_LOADED";
NSString *bannerDestroyed = @"BANNER_DESTROYED";
NSString *bannerAttached = @"BANNER_ATTACHED";
NSString *bannerDetached = @"BANNER_DETACHED";
NSString *bannerLoadPlacement = @"BANNER_LOAD_PLACEMENT";
NSString *bannerDestroyBanner = @"BANNER_DESTROY_BANNER";

NSString * UADSNSStringFromBannerEvent(UADSBannerEvent event) {
    switch (event) {
        case UADSBannerEventResized:
            return bannerResized;

        case UADSBannerEventVisibilityChanged:
            return bannerVisibilityChanged;

        case UADSBannerEventAttached:
            return bannerAttached;

        case UADSBannerEventDetached:
            return bannerDetached;

        case UADSBannerEventDestroyed:
            return bannerDestroyed;

        case UADSBannerEventLoaded:
            return bannerLoaded;

        case UADSBannerEventLoadPlacement:
            return bannerLoadPlacement;

        case UADSBannerEventDestroyBanner:
            return bannerDestroyBanner;
    }     /* switch */
    return nil;
} /* UADSNSStringFromBannerEvent */
