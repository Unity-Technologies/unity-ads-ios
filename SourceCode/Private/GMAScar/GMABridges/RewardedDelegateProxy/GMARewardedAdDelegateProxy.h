#import "GADFullScreenContentDelegateProxy.h"
#import "GMAAdDelegateBase.h"
@interface GMARewardedAdDelegateProxy : GMAAdDelegateBase

/// GMA callback which "tells the delegate that the user earned a reward"
- (void)rewardedAd: (id)rewardedAd userDidEarnReward: (id)reward;

/// GMA callback which "tells the delegate that the rewarded ad was presented"
- (void)rewardedAdDidPresent: (id)rewardedAd;

/// GMA callback which "tells the delegate that the rewarded ad failed to present"
- (void)rewardedAd: (id)rewardedAd didFailToPresentWithError: (id)error;

/// GMA callback which "tells the delegate that the rewarded ad was dismissed"
- (void)rewardedAdDidDismiss: (id)rewardedAd;

- (void)didEarnReward: (id)rewardedAd;

@end
