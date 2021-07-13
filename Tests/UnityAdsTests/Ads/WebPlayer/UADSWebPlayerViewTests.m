#import <XCTest/XCTest.h>
#import "UADSWebPlayerView.h"

@interface ApplicationDelegate : NSObject <UIApplicationDelegate>

- (UIWindow *)window;

@end

@implementation ApplicationDelegate

- (UIWindow *)window {
    return [[UIWindow alloc] init];
}

@end

@interface UADSWebPlayerViewTests : XCTestCase
@end

@implementation UADSWebPlayerViewTests

- (void)testSendFrameUpdateWithNilWindowDoesNotCrash {
    @try {
        UADSWebPlayerView *webPlayerView = [[UADSWebPlayerView alloc] initWithFrame: CGRectZero
                                                                             viewId: @"testViewId"
                                                                  webPlayerSettings: [[NSDictionary alloc] init]];
        [webPlayerView layoutSubviews];
        XCTAssertTrue(YES); // successfully did not throw
    } @catch (NSException *e) {
        XCTFail("Should not throw");
    }
}

- (void)testSendFrameUpdateWithWindowDoesNotCrash {
    @try {
        UADSWebPlayerView *webPlayerView = [[UADSWebPlayerView alloc] initWithFrame: CGRectZero
                                                                             viewId: @"testViewId"
                                                                  webPlayerSettings: [[NSDictionary alloc] init]];
        [UIApplication.sharedApplication.delegate.window addSubview: webPlayerView];
        [webPlayerView layoutSubviews];
        XCTAssertTrue(YES); // successfully did not throw
        [webPlayerView removeFromSuperview];
    } @catch (NSException *e) {
        XCTFail(@"Should not throw");
    }
}

@end
