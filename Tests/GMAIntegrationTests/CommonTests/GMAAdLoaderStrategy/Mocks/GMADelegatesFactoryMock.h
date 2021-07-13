#import <Foundation/Foundation.h>
#import "GMAInterstitialAdDelegateProxy.h"
#import "GMARewardedAdDelegateProxy.h"
#import "GMADelegatesFactory.h"
#import "GMAInterstitialAdDelegateMock.h"
#import "GMARewardedAdDelegateMock.h"
NS_ASSUME_NONNULL_BEGIN

@interface GMADelegatesFactoryMock : NSObject<GMADelegatesFactory>
@property (nonatomic, strong) GMAInterstitialAdDelegateMock *interstitialDelegate;
@property (nonatomic, strong) GMARewardedAdDelegateMock *rewardedDelegate;
@end

NS_ASSUME_NONNULL_END
