#import "UADSBanner.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSBannerProperties : NSObject

+(nullable id <UnityAdsBannerDelegate>)getDelegate;

+(void)setDelegate:(nullable id <UnityAdsBannerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
