#import <Foundation/Foundation.h>
#import "GMAWebViewEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface GMABannerWebViewEvent : GMAWebViewEvent

+ (instancetype)newBannerLoadedWithMeta: (GMAAdMetaData *)meta;
+ (instancetype)newBannerLoadFailedWithMeta: (GMAAdMetaData *)meta;
+ (instancetype)newBannerOpenedWithMeta: (GMAAdMetaData *)meta;
+ (instancetype)newBannerClosedWithMeta: (GMAAdMetaData *)meta;
+ (instancetype)newBannerImpressionWithMeta: (GMAAdMetaData *)meta;
+ (instancetype)newBannerClickedWithMeta: (GMAAdMetaData *)meta;
+ (instancetype)newBannerAttachedWithMeta: (GMAAdMetaData *)meta;
+ (instancetype)newBannerDetachedWithMeta: (GMAAdMetaData *)meta;

@end

NS_ASSUME_NONNULL_END
