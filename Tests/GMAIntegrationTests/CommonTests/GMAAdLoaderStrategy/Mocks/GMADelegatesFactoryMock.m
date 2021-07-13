#import "GMADelegatesFactoryMock.h"

@implementation GMADelegatesFactoryMock
- (GMAInterstitialAdDelegateProxy *)interstitialDelegate: (GMAAdMetaData *)meta
                                           andCompletion: (UADSAnyCompletion *)completion  {
    _interstitialDelegate.completion = completion;
    return (GMAInterstitialAdDelegateProxy *)_interstitialDelegate;
}

- (GMARewardedAdDelegateProxy *)rewardedDelegate: (GMAAdMetaData *)meta {
    return (GMARewardedAdDelegateProxy *)_rewardedDelegate;
}

@end
