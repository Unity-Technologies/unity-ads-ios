#import "UADSBannerEvent.h"

NSString *bannerResized = @"BANNER_RESIZED";
NSString *bannerVisibilityChanged = @"BANNER_VISIBILITY_CHANGED";
NSString *bannerLoaded = @"BANNER_LOADED";
NSString *bannerDestroyed = @"BANNER_DESTROYED";
NSString *bannerAttached = @"BANNER_ATTACHED";
NSString *bannerDetached = @"BANNER_DETACHED";

NSString *NSStringFromBannerEvent(UnityAdsBannerEvent event) {
    switch (event) {
        case kUnityAdsBannerEventResized:
            return bannerResized;
        case kUnityAdsBannerEventVisibilityChanged:
            return bannerVisibilityChanged;
        case kUnityAdsBannerEventAttached:
            return bannerAttached;
        case kUnityAdsBannerEventDetached:
            return bannerDetached;
        case kUnityAdsBannerEventDestroyed:
            return bannerDestroyed;
        case kUnityAdsBannerEventLoaded:
            return bannerLoaded;
    }
    return nil;
}
