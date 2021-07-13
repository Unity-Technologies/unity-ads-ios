#ifndef UADSBANNEREVENT_H
#define UADSBANNEREVENT_H

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, UADSBannerEvent) {
    UADSBannerEventResized,
    UADSBannerEventVisibilityChanged,
    UADSBannerEventLoaded,
    UADSBannerEventDestroyed,
    UADSBannerEventAttached,
    UADSBannerEventDetached,
    // Banner load by placement events
    UADSBannerEventLoadPlacement,
    UADSBannerEventDestroyBanner
};

/**
 * These visibility values mirror those of Android's.
 */
typedef NS_ENUM (NSInteger, UADSBannerVisibility) {
    UADSBannerVisibilityVisible   = 0x00000000,
    UADSBannerVisibilityInvisible = 0x00000004,
    UADSBannerVisibilityGone      = 0x00000008
};

NSString * UADSNSStringFromBannerEvent(UADSBannerEvent event);

#endif /* ifndef UADSBANNEREVENT_H */
