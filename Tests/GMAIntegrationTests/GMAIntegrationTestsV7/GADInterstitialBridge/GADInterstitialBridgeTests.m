#import "GMAInterstitialAdLoaderV7.h"
#import "GMABaseQueryInfoReader+TestCategory.h"
#import <XCTest/XCTest.h>
#import "GMAQuerySignalReader.h"
#import "GMAInterstitialAdDelegateMock.h"
#import "GMAIntegrationTestsConstants.h"
@import GoogleMobileAds;


@interface GADInterstitialBridgeTests : XCTestCase
@property NSString *mystring;
@end


@implementation GADInterstitialBridgeTests


- (void)test_request_exists {
    XCTAssertTrue([GADInterstitialBridge exists]);
}

- (void)test_loads_interstitial_ads_and_notifies_the_delegate {
    GMAInterstitialAdDelegateMock *delegate = self.defaultDelegateMock;

    [self runSuccessFlowWithDelegate: delegate];
    XCTAssertEqual(delegate.didReceivedCalled, 1);
}

- (void)test_ad_contains_response_info {
    GMAInterstitialAdDelegateMock *delegate = self.defaultDelegateMock;

    [self runSuccessFlowWithDelegate: delegate];
    XCTAssertNotNil(delegate.ad.responseInfo);
    XCTAssertNotNil(delegate.ad.responseInfo.responseIdentifier);
}

- (void)test_fails_to_load_interstitial_ads_and_notifies_the_delegate {
    GMAInterstitialAdDelegateMock *delegate = self.defaultDelegateMock;

    [self runTestWithDelegate: delegate
                  andUnitAdID: @"Wrong_ID"];
    XCTAssertEqual(delegate.didFailCalled, 1);
}

- (void)runSuccessFlowWithDelegate: (GMAInterstitialAdDelegateMock *)delegate {
    [self runTestWithDelegate: delegate
                  andUnitAdID: kDefaultAdUnitID];
}

- (void)runTestWithDelegate: (GMAInterstitialAdDelegateMock *)delegate andUnitAdID: (NSString *)adUnitID {
    GADRequestBridge *request = [GADRequestBridge getNewRequest];
    GADInterstitialBridge *iAd = [GADInterstitialBridge newWithAdUnitID: adUnitID];

    //typecasting
    [iAd setDelegate: (GMAInterstitialAdDelegateProxy *)delegate];
    [iAd loadRequest: request];
    [self waitForExpectations: @[delegate.exp]
                      timeout: DEFAULT_WAITING_INTERVAL];
}

- (GADInterstitialBridge *)defaultAd {
    return [GADInterstitialBridge newWithAdUnitID: @"video"];
}

- (GMAInterstitialAdDelegateMock *)defaultDelegateMock {
    GMAInterstitialAdDelegateMock *delegate = [GMAInterstitialAdDelegateMock new];

    delegate.exp = [self expectationWithDescription: @"test"];
    return delegate;
}

@end
