#import <XCTest/XCTest.h>
#import "UADSWebPlayerViewManager.h"

@interface UADSWebPlayerViewManagerTests : XCTestCase
@end

@implementation UADSWebPlayerViewManagerTests

- (void)testAddWebPlayerView {
    UADSWebPlayerViewManager *manager = [[UADSWebPlayerViewManager alloc] init];
    UADSWebPlayerView *firstView = [[UADSWebPlayerView alloc] initWithFrame:CGRectZero viewId:@"firstView" webPlayerSettings:nil];
    [manager addWebPlayerView:firstView viewId:@"firstView"];
    UADSWebPlayerView *webPlayerView = [manager getWebPlayerViewWithViewId:@"firstView"];

    XCTAssertNotNil(webPlayerView);
    XCTAssertEqual(firstView, webPlayerView);
}

- (void)testMultipleAddWebPlayerView {
    UADSWebPlayerViewManager *manager = [[UADSWebPlayerViewManager alloc] init];
    UADSWebPlayerView *firstView = [[UADSWebPlayerView alloc] initWithFrame:CGRectZero viewId:@"firstView" webPlayerSettings:nil];
    UADSWebPlayerView *secondView = [[UADSWebPlayerView alloc] initWithFrame:CGRectZero viewId:@"secondView" webPlayerSettings:nil];
    [manager addWebPlayerView:firstView viewId:@"firstView"];
    [manager addWebPlayerView:secondView viewId:@"secondView"];
    UADSWebPlayerView *webPlayerView = [manager getWebPlayerViewWithViewId:@"firstView"];

    XCTAssertNotNil(webPlayerView);
    XCTAssertEqual(firstView, webPlayerView);

    UADSWebPlayerView *webPlayerView2 = [manager getWebPlayerViewWithViewId:@"secondView"];

    XCTAssertNotNil(webPlayerView2);
    XCTAssertEqual(secondView, webPlayerView2);
}

- (void)testRemoveWebPlayerViewWithPlacementId {
    UADSWebPlayerViewManager *manager = [[UADSWebPlayerViewManager alloc] init];
    UADSWebPlayerView *firstView = [[UADSWebPlayerView alloc] initWithFrame:CGRectZero viewId:@"firstView" webPlayerSettings:nil];
    [manager addWebPlayerView:firstView viewId:@"firstView"];
    UADSWebPlayerView *webPlayerView = [manager getWebPlayerViewWithViewId:@"firstView"];

    XCTAssertNotNil(webPlayerView);
    XCTAssertEqual(firstView, webPlayerView);

    [manager removeWebPlayerViewWithViewId:@"firstView"];
    webPlayerView = [manager getWebPlayerViewWithViewId:@"firstView"];

    XCTAssertNil(webPlayerView);
}

@end
