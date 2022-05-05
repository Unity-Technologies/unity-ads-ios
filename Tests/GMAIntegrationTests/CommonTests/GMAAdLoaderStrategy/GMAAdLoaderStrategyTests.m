#import "GMAAdLoaderStrategyTests.h"
#import "GADRequestFactoryMock.h"
#import "GMAError+XCTest.h"
#import "GMAIntegrationTestsConstants.h"
#import "GMAError.h"
#import "XCTestCase+Convenience.h"
#import "GMAIntegrationTestsConstants.h"

#import "AppDelegate.h"
static NSString *const kGMANullPlacementID = @"NULL_PLACEMENT_ID";

@implementation GMAAdLoaderStrategyTests


- (void)setUp {
    _factoryMock = [GMADelegatesFactoryMock new];
    _interstitialDelegate = [GMAInterstitialAdDelegateMock new];
    _rewardedDelegate = [GMARewardedAdDelegateMock new];
    _factoryMock.interstitialDelegate = _interstitialDelegate;
    _factoryMock.rewardedDelegate = _rewardedDelegate;
    _sut =  [GMAAdLoaderStrategy newWithRequestFactory: [GADRequestFactoryMock new]
                                    andDelegateFactory: self.delegatesFactory];
    [self setUpUI];
}

- (void)tearDown {
    _sut = nil;
    _factoryMock = nil;
    _interstitialDelegate = nil;
    _rewardedDelegate = nil;
}

- (void)setUpUI {
    [self.rootViewController.presentedViewController dismissViewControllerAnimated: false
                                                                        completion: nil];
    [self waitForTimeInterval: 1];
}

- (UIWindow *)rootWindow {
    return self.appDelegate.window;
}

- (UIViewController *)rootViewController {
    return self.rootWindow.rootViewController;
}

- (AppDelegate *)appDelegate {
    return (AppDelegate *)UIApplication.sharedApplication.delegate;
}

- (void)test_gma_is_supported_true {
    XCTAssertTrue([self.sut isSupported]);
}

- (void)test_success_flow_for_loading_an_interstitial_ad {
    [self runSuccessTest: GADQueryInfoAdTypeInterstitial];
}

- (void)test_success_flow_for_loading_a_rewarded_ad {
    [self runSuccessTest: GADQueryInfoAdTypeRewarded];
}

- (void)test_internal_error_loader_not_found {
    GMAAdMetaData *meta = [GMAAdMetaData new];

    meta.type = 10;
    NSString *message = [NSString stringWithFormat: kGMANonSupportedLoaderFormat, @"Rewarded"];

    [self runErrorTestFor: meta
            andCompletion:^(GMAError *error) {
                [error testWithEventName: @"INTERNAL_LOAD_ERROR"
                               expParams: @[kGMANullPlacementID, message]];
            }];
}

- (void)test_ad_load_interstitial_error {
    [self runTestAdLoadErrorForType: GADQueryInfoAdTypeInterstitial];
}

- (void)test_ad_load_rewarded_error {
    [self runTestAdLoadErrorForType: GADQueryInfoAdTypeRewarded];
}

- (void)runShowAdSuccessFlowForType: (GADQueryInfoAdType)type inViewController:  (UIViewController *)vc {
    _sut =  [GMAAdLoaderStrategy newWithRequestFactory: [GADRequestFactoryMock new]
                                    andDelegateFactory: _factoryMock];
    [self runSuccessTest: type];

    id<UADSError> error;


    GMAAdMetaData *meta = [self defaultMetaForType: type];

    [_sut showAdUsingMetaData: meta
             inViewController: vc
                        error: &error];
    [self waitForTimeInterval: 2];
}

- (void)test_produces_internal_error_if_request_is_nil {
    GMAAdMetaData *meta = [self defaultMetaForType: GADQueryInfoAdTypeInterstitial];
    GADRequestFactoryMock *factory = [GADRequestFactoryMock new];

    factory.returnedError = [GMAError newInternalLoadQueryNotFound: meta];

    _sut = [GMAAdLoaderStrategy newWithRequestFactory: factory
                                   andDelegateFactory: self.delegatesFactory];
    NSString *message = [NSString stringWithFormat: kGMAQueryNotFoundFormat, meta.placementID];

    [self runErrorTestFor: meta
            andCompletion:^(GMAError *error) {
                [error testWithEventName: @"QUERY_NOT_FOUND_ERROR"
                               expParams: @[meta.placementID, meta.queryID, message]];
            }];
}

- (void)test_show_interstitial_ad_success_flow {
    UIViewController *vc = [[UIViewController alloc] initWithNibName: nil
                                                              bundle: nil];

    [self.rootViewController showViewController: vc
                                         sender: nil];
    [self runShowAdSuccessFlowForType: GADQueryInfoAdTypeInterstitial
                     inViewController: vc];
    XCTAssertEqual(self.interstitialDelegate.willPresentCalled, 1);
}

- (void)test_show_rewarded_ad_success_flow {
    UIViewController *vc = [[UIViewController alloc] initWithNibName: nil
                                                              bundle: nil];

    [self.rootViewController showViewController: vc
                                         sender: nil];

    [self runShowAdSuccessFlowForType: GADQueryInfoAdTypeRewarded
                     inViewController: vc];
    XCTAssertEqual(self.rewardedDelegate.didPresentCalled, 1);
    XCTAssertNil(self.rewardedDelegate.failedError);
}

- (void)test_no_ad_error_on_show {
    GMAAdMetaData *meta = [self defaultMetaForType: GADQueryInfoAdTypeRewarded];
    GMAError *error;
    UIViewController *vc = [[UIViewController alloc] initWithNibName: nil
                                                              bundle: nil];

    NSString *message = [NSString stringWithFormat: kGMANoAdFoundFormat, @"Rewarded"];

    [_sut showAdUsingMetaData: meta
             inViewController: vc
                        error: &error];
    [error testWithEventName: @"NO_AD_ERROR"
                   expParams: @[meta.placementID,
                                meta.queryID, message]];
}

- (void)test_show_rewarded_ad_failure_flow {
    UIViewController *vc = [[UIViewController alloc] initWithNibName: nil
                                                              bundle: nil];

    //if a viewController is not in hierarchy GMA will return an error that the VC is not presented
    //this allows us to test failure path.
    [self runShowAdSuccessFlowForType: GADQueryInfoAdTypeRewarded
                     inViewController: vc];
    XCTAssertEqual(self.rewardedDelegate.didFailCalled, 1);
}

//MARK: -helper methods
- (void)runTestAdLoadErrorForType: (GADQueryInfoAdType)type {
    GMAAdMetaData *meta = [self defaultMetaForType: type];

    meta.adUnitID = @"adUnitID";
    meta.adString = @"adString";

    [self runErrorTestFor: meta
            andCompletion:^(GMAError *_Nonnull error) {
                [error testWithEventName: @"LOAD_ERROR"
                               expParams: @[
                     meta.placementID,
                     meta.queryID,
                     error.errorString,
                     error.errorCode]];
            }];
}

- (void)runErrorTestFor: (GMAAdMetaData *)meta
          andCompletion: (void (^)(GMAError *))errorCompletion {
    [_sut loadErrorSyncWithTestCase: self
                        andMetaData: meta
                 andErrorCompletion: errorCompletion];
}

- (void)runSuccessTest: (GADQueryInfoAdType)type {
    [_sut loadSuccessSyncWithTestCase: self
                          andMetaData: [self defaultMetaForType: type]
                 andSuccessCompletion:^(id _Nullable obj) { XCTAssertNotNil(obj); }];
}

- (GMAAdMetaData *)defaultMetaForType: (GADQueryInfoAdType)type  {
    GMAAdMetaData *meta = [GMAAdMetaData new];

    meta.adString = @"adString";
    meta.placementID = @"placement";
    meta.adUnitID = kDefaultAdUnitID;
    meta.videoLength = @10;
    meta.queryID = @"queryID";
    meta.type = type;
    return meta;
}

- (id<GMADelegatesFactory>)delegatesFactory {
    return [GMADelegatesBaseFactory newWithEventSender: self.eventSender
                                          errorHandler: self.errorHandler];
}

- (id<UADSWebViewEventSender>)eventSender {
    return [UADSWebViewEventSenderBase new];
}

- (id<UADSErrorHandler>)errorHandler {
    return [UADSWebViewErrorHandler newWithEventSender: self.eventSender];
}

- (void)waitForTimeInterval: (NSTimeInterval)waitTime {
    XCTestExpectation *expectation = [self expectationWithDescription: @"wait.expectations"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, waitTime * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectations: @[expectation]
                      timeout: waitTime + 2];
}

@end
