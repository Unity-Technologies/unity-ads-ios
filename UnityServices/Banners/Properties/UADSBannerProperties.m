#import "UADSBannerProperties.h"

@implementation UADSBannerProperties

static __weak id <UnityAdsBannerDelegate> _Nullable s_bannerDelegate;

+(void)setDelegate:(nullable id <UnityAdsBannerDelegate>)delegate {
    s_bannerDelegate = delegate;
}

+(nullable id <UnityAdsBannerDelegate>)getDelegate {
    return s_bannerDelegate;
}

@end
