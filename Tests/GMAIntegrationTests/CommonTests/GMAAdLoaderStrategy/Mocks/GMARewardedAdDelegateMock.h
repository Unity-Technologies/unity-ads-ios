#import <Foundation/Foundation.h>
#import "GADBaseAd.h"
#import <XCTest/XCTest.h>
#import "UADSGenericCompletion.h"

NS_ASSUME_NONNULL_BEGIN

@interface GMARewardedAdDelegateMock : NSObject
@property (nonatomic) int didFailCalled;
@property (nonatomic) int didPresentCalled;
@property (nonatomic) int didDismissCalled;
@property (nonatomic) NSError *failedError;
@property (nonatomic, strong) XCTestExpectation *exp;
@property (nonatomic, strong) GADBaseAd *_Nullable ad;
@property (nonatomic, strong) UADSAnyCompletion *completion;

- (void)rewardedAd: (id)rewardedAd userDidEarnReward: (id)reward;
- (void)rewardedAdDidPresent: (id)rewardedAd;
- (void)rewardedAd: (id)rewardedAd didFailToPresentWithError: (id)error;
- (void)rewardedAdDidDismiss: (id)rewardedAd;
- (void)didEarnReward: (id)rewardedAd;
@end

NS_ASSUME_NONNULL_END
