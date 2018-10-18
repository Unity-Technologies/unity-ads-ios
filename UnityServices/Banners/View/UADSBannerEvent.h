#ifndef UADSBANNEREVENT_H
#define UADSBANNEREVENT_H

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UnityAdsBannerEvent) {
    kUnityAdsBannerEventResized,
    kUnityAdsBannerEventVisibilityChanged,
    kUnityAdsBannerEventLoaded,
    kUnityAdsBannerEventDestroyed,
    kUnityAdsBannerEventAttached,
    kUnityAdsBannerEventDetached
};

/**
 * These visibility values mirror those of Android's.
 */
typedef NS_ENUM(NSInteger, UnityAdsBannerVisibility) {
    kUnityAdsBannerVisibilityVisible = 0x00000000,
    kUnityAdsBannerVisibilityInvisible = 0x00000004,
    kUnityAdsBannerVisibilityGone = 0x00000008
};

NSString *NSStringFromBannerEvent(UnityAdsBannerEvent event);

#endif
