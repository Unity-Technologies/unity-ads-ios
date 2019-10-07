#import <XCTest/XCTest.h>
#import "UADSBannerViewManager.h"

@interface UADSBannerView (Test)
@property(nonatomic, strong) NSString *viewId;
@end

@interface BannerDelegate : NSObject <UADSBannerViewDelegate>

@property(nonatomic, copy) void (^didLoadBlock)(UADSBannerView *);
@property(nonatomic, copy) void (^didNoFillBlock)(UADSBannerView *);
@property(nonatomic, copy) void (^didLeaveApplicationBlock)(UADSBannerView *);
@property(nonatomic, copy) void (^didClickBlock)(UADSBannerView *);
@property(nonatomic, copy) void (^didErrorBlock)(UADSBannerView *, NSError *);

@end

@implementation BannerDelegate

// MARK UnityAdsBannerDelegate

- (void)bannerViewDidLoad:(UADSBannerView *)bannerView {
    if (_didLoadBlock) {
        _didLoadBlock(bannerView);
    }
}

- (void)bannerViewDidClick:(UADSBannerView *)bannerView {
    if (_didClickBlock) {
        _didClickBlock(bannerView);
    }
}

- (void)bannerViewDidLeaveApplication:(UADSBannerView *)bannerView {
    if (_didLeaveApplicationBlock) {
        _didLeaveApplicationBlock(bannerView);
    }
}

- (void)bannerViewDidError:(UADSBannerView *)bannerView error:(UADSBannerError *)error {
    if (_didErrorBlock) {
        _didErrorBlock(bannerView, error);
    }
}

@end

@interface UADSBannerViewManagerTests : XCTestCase
@end

@implementation UADSBannerViewManagerTests

- (void)testAddBannerView {
    UADSBannerViewManager *manager = [[UADSBannerViewManager alloc] init];
    UADSBannerView *firstView = [[UADSBannerView alloc] initWithPlacementId:@"firstView" size:CGSizeMake(320, 50)];
    [manager addBannerView:firstView bannerAdId:@"firstView"];
    UADSBannerView *bannerView = [manager getBannerViewWithBannerAdId:@"firstView"];

    XCTAssertNotNil(bannerView);
    XCTAssertEqual(firstView, bannerView);
}

- (void)testMultipleAddBannerView {
    UADSBannerViewManager *manager = [[UADSBannerViewManager alloc] init];
    UADSBannerView *firstView = [[UADSBannerView alloc] initWithPlacementId:@"firstView" size:CGSizeMake(320, 50)];
    UADSBannerView *secondView = [[UADSBannerView alloc] initWithPlacementId:@"secondView" size:CGSizeMake(320, 50)];
    [manager addBannerView:firstView bannerAdId:@"firstView"];
    [manager addBannerView:secondView bannerAdId:@"secondView"];
    UADSBannerView *bannerView1 = [manager getBannerViewWithBannerAdId:@"firstView"];

    XCTAssertNotNil(bannerView1);
    XCTAssertEqual(firstView, bannerView1);

    UADSBannerView *bannerView2 = [manager getBannerViewWithBannerAdId:@"secondView"];

    XCTAssertNotNil(bannerView2);
    XCTAssertEqual(secondView, bannerView2);
}

- (void)testRemoveBannerViewWithPlacementId {
    UADSBannerViewManager *manager = [[UADSBannerViewManager alloc] init];
    UADSBannerView *firstView = [[UADSBannerView alloc] initWithPlacementId:@"firstView" size:CGSizeMake(320, 50)];
    [manager addBannerView:firstView bannerAdId:@"firstView"];
    UADSBannerView *bannerView = [manager getBannerViewWithBannerAdId:@"firstView"];

    XCTAssertNotNil(bannerView);
    XCTAssertEqual(firstView, bannerView);

    [manager removeBannerViewWithBannerAdId:@"firstView"];
    bannerView = [manager getBannerViewWithBannerAdId:@"firstView"];

    XCTAssertNil(bannerView);
}

- (void)testTriggerBannerDidLoad {
    UADSBannerViewManager *manager = [[UADSBannerViewManager alloc] init];
    UADSBannerView *firstView = [[UADSBannerView alloc] initWithPlacementId:@"firstView" size:CGSizeMake(320, 50)];
    BannerDelegate *bannerDelegate = [[BannerDelegate alloc] init];
    firstView.delegate = bannerDelegate;
    XCTestExpectation *expectation = [self expectationWithDescription:@"testTriggerBannerDidLoad"];
    bannerDelegate.didLoadBlock = ^(UADSBannerView *bannerView) {
        XCTAssertEqual(bannerView, firstView);
        [expectation fulfill];
    };
    [manager addBannerView:firstView bannerAdId:firstView.viewId];
    [manager triggerBannerDidLoad:firstView.viewId];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testTriggerBannerDidLoadWithNullBanner {
    UADSBannerViewManager *manager = [[UADSBannerViewManager alloc] init];
    [manager triggerBannerDidLoad:@"test"];
    // test that no crash happens
}

- (void)testTriggerBannerDidClick {
    UADSBannerViewManager *manager = [[UADSBannerViewManager alloc] init];
    UADSBannerView *firstView = [[UADSBannerView alloc] initWithPlacementId:@"firstView" size:CGSizeMake(320, 50)];
    BannerDelegate *bannerDelegate = [[BannerDelegate alloc] init];
    firstView.delegate = bannerDelegate;
    XCTestExpectation *expectation = [self expectationWithDescription:@"testTriggerBannerDidClick"];
    bannerDelegate.didClickBlock = ^(UADSBannerView *bannerView) {
        XCTAssertEqual(bannerView, firstView);
        [expectation fulfill];
    };
    [manager addBannerView:firstView bannerAdId:firstView.viewId];
    [manager triggerBannerDidClick:firstView.viewId];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testTriggerBannerDidClickWithNullBanner {
    UADSBannerViewManager *manager = [[UADSBannerViewManager alloc] init];
    [manager triggerBannerDidClick:@"test"];
    // test that no crash happens
}

- (void)testTriggerBannerDidLeaveApplication {
    UADSBannerViewManager *manager = [[UADSBannerViewManager alloc] init];
    UADSBannerView *firstView = [[UADSBannerView alloc] initWithPlacementId:@"firstView" size:CGSizeMake(320, 50)];
    BannerDelegate *bannerDelegate = [[BannerDelegate alloc] init];
    firstView.delegate = bannerDelegate;
    XCTestExpectation *expectation = [self expectationWithDescription:@"testTriggerBannerDidLeaveApplication"];
    bannerDelegate.didLeaveApplicationBlock = ^(UADSBannerView *bannerView) {
        XCTAssertEqual(bannerView, firstView);
        [expectation fulfill];
    };
    [manager addBannerView:firstView bannerAdId:firstView.viewId];
    [manager triggerBannerDidLeaveApplication:firstView.viewId];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testTriggerBannerDidLeaveApplicationWithNullBanner {
    UADSBannerViewManager *manager = [[UADSBannerViewManager alloc] init];
    [manager triggerBannerDidLeaveApplication:@"test"];
    // test that no crash happens
}

- (void)testTriggerBannerDidError {
    UADSBannerViewManager *manager = [[UADSBannerViewManager alloc] init];
    UADSBannerView *firstView = [[UADSBannerView alloc] initWithPlacementId:@"firstView" size:CGSizeMake(320, 50)];
    BannerDelegate *bannerDelegate = [[BannerDelegate alloc] init];
    firstView.delegate = bannerDelegate;
    XCTestExpectation *expectation = [self expectationWithDescription:@"testTriggerBannerDidError"];
    UADSBannerError *unknownError = [[UADSBannerError alloc] initWithCode:UADSBannerErrorCodeUnknown userInfo:@{
            NSLocalizedDescriptionKey: @"test"
    }];
    bannerDelegate.didErrorBlock = ^(UADSBannerView *bannerView, NSError *error) {
        XCTAssertEqual(bannerView, firstView);
        XCTAssertEqual(error, unknownError);
        XCTAssertEqual(error.localizedDescription, @"test");
        [expectation fulfill];
    };
    [manager addBannerView:firstView bannerAdId:firstView.viewId];
    [manager triggerBannerDidError:firstView.viewId error:unknownError];
    [self waitForExpectationsWithTimeout:2 handler:nil];
}

- (void)testTriggerBannerDidErrorWithNullBanner {
    UADSBannerError *unknownError = [[UADSBannerError alloc] initWithCode:UADSBannerErrorCodeUnknown userInfo:@{
            NSLocalizedDescriptionKey: @"test"
    }];
    UADSBannerViewManager *manager = [[UADSBannerViewManager alloc] init];
    [manager triggerBannerDidError:@"test" error:unknownError];
    // test that no crash happens
}

@end
