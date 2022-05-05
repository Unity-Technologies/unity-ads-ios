#import "GMAInterstitialAdDelegateProxy.h"
#import "USRVWebViewApp.h"
#import "NSError+UADSError.h"
#import "UADSWebViewEventSender.h"
#import "GMAWebViewEvent.h"
@interface GMAInterstitialAdDelegateProxy ()

@end

@implementation GMAInterstitialAdDelegateProxy

/// GMA callback which "tells the delegate an ad request succeeded"
- (void)interstitialDidReceiveAd: (id)ad {
    [self didReceiveAd: ad];
}

/// GMA callback which "tells the delegate an ad request failed"
- (void)           interstitial: (id)ad
    didFailToReceiveAdWithError: (NSError *)error {
    [self   loadingOfAd: ad
        failedWithError: error];
}

/// GMA callback which "tells the delegate that an interstitial will be presented"
- (void)interstitialWillPresentScreen: (id)ad {
    [self willPresentAd: ad];
}

/// GMA callback which "tells the delegate the interstitial is to be animated off the screen"
- (void)interstitialWillDismissScreen: (id)ad {
    [self willDismissAd: ad];
}

/// GMA callback which "tells the delegate the interstitial had been animated off the screen"
- (void)interstitialDidDismissScreen: (id)ad {
    [self didDismissAd: ad];
}

- (void)adDidDismissFullScreenContent: (nonnull id)ad {
    [self didDismissAd: ad];
}

- (void)didDismissAd: (id)ad {
    if (!self.hasSentQuartiles) {
        [self.eventSender sendEvent: [GMAWebViewEvent newAdSkippedWithMeta: self.meta]];
    }

    [super didDismissAd: ad];
}

/// GMA callback which "tells the delegate that a user click will open another app (such as the App Store), backgrounding the current app"
- (void)interstitialWillLeaveApplication: (id)ad {
    [self willLeaveApplication: ad];
}

@end
