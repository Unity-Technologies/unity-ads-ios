#import <Foundation/Foundation.h>
#import "GMALoaderBase.h"
#import "GADBannerViewBridge.h"
#import "GMABannerViewDelegateProxy.h"
NS_ASSUME_NONNULL_BEGIN

@interface GMABannerAdLoader :  GMALoaderBase<GADBannerViewBridge *, GMABannerViewDelegateProxy *>


@end

NS_ASSUME_NONNULL_END
