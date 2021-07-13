#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#include "UADSBannerEvent.h"

@interface USRVBannerBridge : NSObject

+ (void)loadBannerPlacement: (NSString *)placementId bannerAdId: (NSString *)bannerAdId size: (CGSize)size;

+ (void)destroyBannerWithId: (NSString *)bannerAdId;

+ (void)bannerDidResizeWithBannerId: (NSString *)bannerAdId frame: (CGRect)frame alpha: (CGFloat)alpha;

+ (void)bannerVisibilityChangedWithBannerId: (NSString *)bannerAdId bannerVisibility: (UADSBannerVisibility)bannerVisibility;

+ (void)bannerDidLoadedWithBannerId: (NSString *)bannerAdId;

+ (void)bannerDidDestroyWithBannerId: (NSString *)bannerAdId;

// This is effectively show
+ (void)bannerDidAttachWithBannerId: (NSString *)bannerAdId;

// This is effectively hide
+ (void)bannerDidDetachWithBannerId: (NSString *)bannerAdId;

@end
