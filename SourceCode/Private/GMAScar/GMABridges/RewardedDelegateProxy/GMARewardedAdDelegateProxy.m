#import "GMARewardedAdDelegateProxy.h"
#import "USRVWebViewApp.h"
#import "NSError+UADSError.h"
#import "UADSWebViewEventSender.h"
#import "GMAWebViewEvent.h"

@interface GMARewardedAdDelegateProxy ()
@property bool hasRewarded;
@end

@implementation GMARewardedAdDelegateProxy


/// GMA callback which "tells the delegate that the user earned a reward"
- (void)   rewardedAd: (id)rewardedAd
    userDidEarnReward: (id)reward {
    if (!self.hasRewarded) {
        [self.eventSender sendEvent: [GMAWebViewEvent newAdEarnRewardWithMeta: self.meta]];
        self.hasRewarded = true;
    }
}

- (void)willPresentAd: (id)ad {
    [super willPresentAd: ad];

    if (!self.hasRewarded) {
        [self.eventSender sendEvent: [GMAWebViewEvent newAdEarnRewardWithMeta: self.meta]];
        self.hasRewarded = true;
    }
}

/// GMA callback which "tells the delegate that the rewarded ad was presented"
- (void)rewardedAdDidPresent: (id)rewardedAd {
    [self willPresentAd: rewardedAd];
}

/// GMA callback which "tells the delegate that the rewarded ad failed to present"
- (void)rewardedAd: (id)rewardedAd didFailToPresentWithError: (id)error {
    [self ad: rewardedAd
           didFailToPresentFullScreenContentWithError: error];
}

/// GMA callback which "tells the delegate that the rewarded ad was dismissed"
- (void)rewardedAdDidDismiss: (id)rewardedAd {
    [self didDismissAd: rewardedAd];
}

- (void)didEarnReward: (id)rewardedAd {
    [self rewardedAd: rewardedAd
           userDidEarnReward: nil];
}

@end
