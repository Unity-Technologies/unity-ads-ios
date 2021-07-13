#import "GMAAdLoaderStrategyTests.h"
#import <XCTest/XCTest.h>

@interface GMAAdLoaderStrategyV8Tests : GMAAdLoaderStrategyTests

@end

@implementation GMAAdLoaderStrategyV8Tests

- (void)test_show_interstitial_ad_error_flow {
    //if a viewController is not in hierarchy GMA will return an error that the VC is not presented
    //this allows us to test failure path.
    [self runShowAdSuccessFlowForType: GADQueryInfoAdTypeInterstitial
                     inViewController: [UIViewController new]];


    XCTAssertEqual(self.interstitialDelegate.failedToPresent, 1);
}

@end
