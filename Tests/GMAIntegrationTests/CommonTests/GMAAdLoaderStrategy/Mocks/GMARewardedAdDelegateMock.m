#import "GMARewardedAdDelegateMock.h"

@implementation GMARewardedAdDelegateMock
- (void)rewardedAdDidDismiss: (id)rewardedAd {
    self.ad = rewardedAd;
    _didDismissCalled += 1;
    [self fulfillExpectation];
}

- (void)rewardedAd: (id)rewardedAd didFailToPresentWithError: (id)error {
    self.ad = rewardedAd;
    self.failedError = error;
    _didFailCalled += 1;
    [self fulfillExpectation];
}

- (void)rewardedAdDidPresent: (id)rewardedAd {
    self.ad = rewardedAd;
    _didPresentCalled += 1;
    [self fulfillExpectation];
}

- (void)rewardedAd: (id)rewardedAd userDidEarnReward: (id)reward {
    self.ad = rewardedAd;
    [self fulfillExpectation];
}

- (void)didEarnReward: (id)rewardedAd {
    self.ad = rewardedAd;
    [self fulfillExpectation];
}

- (void)fulfillExpectation {
    [self.exp fulfill];
}

- (void)ad: (nonnull id)ad didFailToPresentFullScreenContentWithError: (nonnull NSError *)error {
    [self rewardedAd: ad
           didFailToPresentWithError: error];
    [self fulfillExpectation];
}

- (void)adDidDismissFullScreenContent: (nonnull id)ad {
    [self rewardedAdDidDismiss: ad];
}

- (void)adDidPresentFullScreenContent: (nonnull id)ad {
    [self rewardedAdDidPresent: ad];
}

- (void)adWillPresentFullScreenContent: (nonnull id)ad {
    [self rewardedAdDidPresent: ad];
}

@end
