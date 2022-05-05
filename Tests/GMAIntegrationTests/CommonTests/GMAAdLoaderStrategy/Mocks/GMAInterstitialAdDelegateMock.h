#import <Foundation/Foundation.h>
#import "GADBaseAd.h"
#import <XCTest/XCTest.h>
#import "UADSGenericCompletion.h"
NS_ASSUME_NONNULL_BEGIN

@interface GMAInterstitialAdDelegateMock : NSObject
@property (nonatomic) int didReceivedCalled;
@property (nonatomic) int didFailCalled;
@property (nonatomic) int willPresentCalled;
@property (nonatomic) int didPresentCalled;
@property (nonatomic) int willDismissCalled;
@property (nonatomic) int didDismissCalled;
@property (nonatomic) int failedToPresent;
@property (nonatomic, strong) XCTestExpectation *exp;
@property (nonatomic, strong) GADBaseAd *_Nullable ad;
@property (nonatomic, strong) UADSAnyCompletion *completion;

@end

NS_ASSUME_NONNULL_END
