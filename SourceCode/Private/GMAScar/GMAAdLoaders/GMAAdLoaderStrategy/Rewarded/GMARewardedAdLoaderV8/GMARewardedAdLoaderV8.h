#import "GMALoaderBase.h"
#import "GMARewardedAdDelegateProxy.h"
#import "GADRewardedAdBridgeV8.h"
NS_ASSUME_NONNULL_BEGIN

@interface GMARewardedAdLoaderV8 : GMALoaderBase<GADRewardedAdBridgeV8 *, GMARewardedAdDelegateProxy *>

@end

NS_ASSUME_NONNULL_END
