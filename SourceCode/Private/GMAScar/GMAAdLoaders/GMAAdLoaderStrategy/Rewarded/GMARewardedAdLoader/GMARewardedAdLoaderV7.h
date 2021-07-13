#import "GMALoaderBase.h"
#import "GADRewardedAdBridge.h"
NS_ASSUME_NONNULL_BEGIN

/**
     Class that provides full flow for loading GADRewardedAd. Contains internal storage for saving GADRewardedAd and RewardedDelegateProxy for each placementID so they can be retrieved during `show` call.
 */
@interface GMARewardedAdLoaderV7 : GMALoaderBase<GADRewardedAdBridge *, GMARewardedAdDelegateProxy *>

@end

NS_ASSUME_NONNULL_END
