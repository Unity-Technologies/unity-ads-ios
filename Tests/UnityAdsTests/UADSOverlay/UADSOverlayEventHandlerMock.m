#import "UADSOverlayEventHandlerMock.h"

@implementation UADSOverlayEventHandlerMock

- (XCTestExpectation *)setFailCallbackWithExpectedError: (UADSOverlayError)expectedError {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription: @"Should fail to load"];

    self.didFailToLoad = ^(UADSOverlayError error, NSString *message) {
        XCTAssertEqual(error, expectedError);
        [expectation fulfill];
    };
    self.willStartPresentation = ^{
        XCTFail(@"Shouldn't present overlay");
    };
    self.didFinishPresentation = ^{
        XCTFail(@"Shouldn't present overlay");
    };

    return expectation;
}

- (XCTestExpectation *)setPresentationCallbacks {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription: @"Should present overlay"];

    expectation.expectedFulfillmentCount = 2;

    self.willStartPresentation = ^{
        [expectation fulfill];
    };
    self.didFinishPresentation = ^{
        [expectation fulfill];
    };
    self.didFailToLoad = ^(UADSOverlayError error, NSString *message) {
        XCTFail(@"Shouldn't fail");
    };

    return expectation;
}

- (XCTestExpectation *)setDismissalCallbacks {
    XCTestExpectation *expectation = [[XCTestExpectation alloc] initWithDescription: @"Should dismiss overlay"];

    expectation.expectedFulfillmentCount = 2;

    self.willStartDismissal = ^{
        [expectation fulfill];
    };
    self.didFinishDismissal = ^() {
        [expectation fulfill];
    };
    self.didFailToLoad = ^(UADSOverlayError error, NSString *message) {
        XCTFail(@"Shouldn't fail");
    };
    return expectation;
}

- (void)sendOverlayDidFailToLoad: (SKOverlay *)overlay error: (UADSOverlayError)error message: (NSString *)message API_AVAILABLE(ios(14.0)) {
    self.didFailToLoad(error, message);
}

- (void)sendOverlayDidFailToLoad: (UADSOverlayError)error {
    self.didFailToLoad(error, nil);
}

- (void)sendOverlayDidFinishDismissal: (SKOverlay *)overlay API_AVAILABLE(ios(14.0)) {
    self.didFinishDismissal();
}

- (void)sendOverlayDidFinishPresentation: (SKOverlay *)overlay API_AVAILABLE(ios(14.0)) {
    self.didFinishPresentation();
}

- (void)sendOverlayWillStartDismissal: (SKOverlay *)overlay API_AVAILABLE(ios(14.0)) {
    self.willStartDismissal();
}

- (void)sendOverlayWillStartPresentation: (SKOverlay *)overlay API_AVAILABLE(ios(14.0)) {
    self.willStartPresentation();
}

@end
