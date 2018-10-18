#import "UADSBannerProperties.h"

@implementation UADSBannerProperties
static id <UnityAdsBannerDelegate> s_bannerDelegate;

+(void)setDelegate:(id <UnityAdsBannerDelegate>)delegate {
    s_bannerDelegate = delegate;
}

+(id <UnityAdsBannerDelegate>)getDelegate {
    return s_bannerDelegate;
}

@end
