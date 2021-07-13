#import "UADSGenericCompletion.h"
#import "GADFullScreenContentDelegateProxy.h"
#import "GMAAdDelegateBase.h"
@interface GMAInterstitialAdDelegateProxy : GMAAdDelegateBase

/// GMA callback which "tells the delegate an ad request succeeded"
- (void)interstitialDidReceiveAd: (id)ad;

/// GMA callback which "tells the delegate an ad request failed"
- (void)           interstitial: (id)ad
    didFailToReceiveAdWithError: (NSError *)error;

/// GMA callback which "tells the delegate that an interstitial will be presented"
- (void)interstitialWillPresentScreen: (id)ad;

/// GMA callback which "tells the delegate the interstitial is to be animated off the screen"
- (void)interstitialWillDismissScreen: (id)ad;

/// GMA callback which "tells the delegate the interstitial had been animated off the screen"
- (void)interstitialDidDismissScreen: (id)ad;

/// GMA callback which "tells the delegate that a user click will open another app (such as the App Store), backgrounding the current app"
- (void)interstitialWillLeaveApplication: (id)ad;

@end
