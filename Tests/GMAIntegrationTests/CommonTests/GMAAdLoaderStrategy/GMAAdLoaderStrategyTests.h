#import <XCTest/XCTest.h>
#import "GMARewardedAdDelegateProxy.h"
#import "GMAInterstitialAdDelegateMock.h"
#import "GMAInterstitialAdDelegateProxy.h"
#import "GMARewardedAdDelegateMock.h"
#import "GMAAdLoaderStrategy + SyncCategory.h"
#import "UADSWebViewErrorHandler.h"
#import "GMADelegatesFactoryMock.h"

#ifndef GMAAdLoaderStrategyTests_h
#define GMAAdLoaderStrategyTests_h

@interface GMAAdLoaderStrategyTests : XCTestCase
@property (nonatomic, strong) GMAAdLoaderStrategy *sut;
@property (nonatomic, strong) GMAInterstitialAdDelegateMock *interstitialDelegate;
@property (nonatomic, strong) GMARewardedAdDelegateMock *rewardedDelegate;
@property (nonatomic, strong) GMADelegatesFactoryMock *factoryMock;

- (void)runShowAdSuccessFlowForType: (GADQueryInfoAdType)type
                   inViewController: (UIViewController *)vc;
- (UIViewController *)rootViewController;
@end

#endif /* GMAAdLoaderStrategyTests_h */
