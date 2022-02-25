#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import <UnityAds/UnityAds.h>
#import "BannerTestDelegate.h"
#import "UnityBannerTestDelegate.h"
#import "UADSBannerRefreshInfo.h"

@implementation NSURLRequest (ATS)
+ (BOOL)allowsAnyHTTPSCertificateForHost: (NSString *)host {
    return YES;
}

@end

@interface BannerTests : XCTestCase
@end

@implementation BannerTests

// Run once before all tests
+ (void)setUp {
    [super setUp];
    [UnityAds initialize: @"14850"
                testMode: YES];
}

//
//- (void)testBannerLoadLifeCycle {
//    UADSBannerView *bannerView = [[UADSBannerView alloc] initWithPlacementId: @"bannerads"
//                                                                        size: CGSizeMake(320, 50)];
//    BannerTestDelegate *bannerTestDelegate = [[BannerTestDelegate alloc] init];
//    XCTestExpectation *loadExpectation = [self expectationWithDescription: @"didLoadBlockExpectation"];
//
//    bannerTestDelegate.didLoadBlock = ^(UADSBannerView *_bannerView) {
//        XCTAssertEqual(_bannerView, bannerView);
//        [loadExpectation fulfill];
//    };
//    bannerTestDelegate.didErrorBlock = ^(UADSBannerView *_bannerView, UADSBannerError *error) {
//        XCTFail(@"testBannerLoadLifeCycle %@", error.localizedDescription, nil);
//        [loadExpectation fulfill];
//    };
//    bannerView.delegate = bannerTestDelegate;
//    [bannerView load];
//
//    [self waitForExpectationsWithTimeout: 100
//                                 handler: ^(NSError *_Nullable error) {
//                                 }];
//} /* testBannerLoadLifeCycle */
//
//- (void)testLegacyBannerLoadLifeCycle {
//    UnityBannerTestDelegate *unityBannerTestDelegate = [[UnityBannerTestDelegate alloc] init];
//
//    [UnityAdsBanner setDelegate: unityBannerTestDelegate];
//    XCTestExpectation *loadExpectation = [self expectationWithDescription: @"didLoadBlockExpectation"];
//
//    unityBannerTestDelegate.didLoadBlock = ^(NSString *placementId, UIView *view) {
//        XCTAssertEqual(placementId, @"bannerads");
//        XCTAssertNotNil(view);
//        [loadExpectation fulfill];
//    };
//    [UnityAdsBanner loadBanner: @"bannerads"];
//
//    [self waitForExpectationsWithTimeout: 100
//                                 handler: ^(NSError *_Nullable error) {
//                                 }];
//    [UnityAdsBanner destroy];
//}
//
//- (void)testLegacyBannerLoadLifeCycleFromBackground {
//    UnityBannerTestDelegate *unityBannerTestDelegate = [[UnityBannerTestDelegate alloc] init];
//
//    [UnityAdsBanner setDelegate: unityBannerTestDelegate];
//    XCTestExpectation *loadExpectation = [self expectationWithDescription: @"didLoadBlockExpectation"];
//
//    unityBannerTestDelegate.didLoadBlock = ^(NSString *placementId, UIView *view) {
//        XCTAssertEqual(placementId, @"bannerads");
//        XCTAssertNotNil(view);
//        [loadExpectation fulfill];
//    };
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
//        [UnityAdsBanner loadBanner: @"bannerads"];
//    });
//
//    [self waitForExpectationsWithTimeout: 100
//                                 handler: ^(NSError *_Nullable error) {
//                                 }];
//    [UnityAdsBanner destroy];
//}
//
//- (void)testLegacyBannerLoadwithRefresh {
//    UnityBannerTestDelegate *unityBannerTestDelegate = [[UnityBannerTestDelegate alloc] init];
//
//    [UnityAdsBanner setDelegate: unityBannerTestDelegate];
//    [[UADSBannerRefreshInfo sharedInstance] setRefreshRateForPlacementId: @"bannerads"
//                                                             refreshRate: [NSNumber numberWithInt: 15]];
//
//    XCTestExpectation *loadExpectation = [self expectationWithDescription: @"didLoadBlockExpectation"];
//
//    unityBannerTestDelegate.didLoadBlock = ^(NSString *placementId, UIView *view) {
//        XCTAssertEqual(placementId, @"bannerads");
//        XCTAssertNotNil(view);
//        [loadExpectation fulfill];
//    };
//    [UnityAdsBanner loadBanner: @"bannerads"];
//    [self waitForExpectationsWithTimeout: 100
//                                 handler: ^(NSError *_Nullable error) {
//                                 }];
//
//    loadExpectation = [self expectationWithDescription: @"didLoadBlockExpectation"];
//    unityBannerTestDelegate.didLoadBlock = ^(NSString *placementId, UIView *view) {
//        XCTAssertEqual(placementId, @"bannerads");
//        XCTAssertNotNil(view);
//        [loadExpectation fulfill];
//    };
//    [self waitForExpectationsWithTimeout: 100
//                                 handler: ^(NSError *_Nullable error) {
//                                 }];
//
//    [UnityAdsBanner destroy];
//} /* testLegacyBannerLoadwithRefresh */


@end
