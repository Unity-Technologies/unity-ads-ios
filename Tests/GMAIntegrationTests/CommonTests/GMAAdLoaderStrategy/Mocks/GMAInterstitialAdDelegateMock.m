#import "GMAInterstitialAdDelegateMock.h"
#import "NSError+UADSError.h"
@implementation GMAInterstitialAdDelegateMock

- (void)interstitialDidReceiveAd: (id)ad {
    _didReceivedCalled += 1;
    _ad = ad;
    [_completion success: ad];
    [self fulfillExpectation];
}

- (void)interstitial: (id)ad didFailToReceiveAdWithError: (NSError *)error {
    _didFailCalled += 1;
    [_completion error: error];
    [self fulfillExpectation];
}

- (void)interstitialWillPresentScreen: (id)ad {
    _willPresentCalled += 1;
    [self fulfillExpectation];
}

- (void)interstitialWillDismissScreen: (id)ad {
    _willDismissCalled += 1;
    [self fulfillExpectation];
}

- (void)interstitialDidDismissScreen: (id)ad {
    _didDismissCalled += 1;
    [self fulfillExpectation];
}

- (void)interstitialWillLeaveApplication: (id)ad {
    [self fulfillExpectation];
}

- (void)fulfillExpectation {
    [self.exp fulfill];
}

- (void)ad: (nonnull id)ad didFailToPresentFullScreenContentWithError: (nonnull NSError *)error {
    _failedToPresent += 1;
    [self fulfillExpectation];
}

- (void)adDidDismissFullScreenContent: (nonnull id)ad {
    [self interstitialDidDismissScreen: ad];
}

- (void)adDidPresentFullScreenContent: (nonnull id)ad {
    [self interstitialWillPresentScreen: ad];
}

@end
