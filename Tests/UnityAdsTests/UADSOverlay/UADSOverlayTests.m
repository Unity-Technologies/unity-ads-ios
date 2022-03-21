#import <XCTest/XCTest.h>
#import <StoreKit/StoreKit.h>
#import "UADSOverlay.h"
#import "UADSOverlayEventHandlerMock.h"

@interface UADSOverlayTests : XCTestCase
@property (nonatomic, strong) UADSOverlayEventHandlerMock *handlerMock;
@property (nonatomic, strong) UADSOverlay *sut;
@end

@implementation UADSOverlayTests

- (void)setUp {
    self.handlerMock = [[UADSOverlayEventHandlerMock alloc] init];
    self.sut = [[UADSOverlay alloc] initWithEventHandler: self.handlerMock];
    // [self.sut hide]; // to make sure no overlay is shown
}

- (void)tearDown {
    self.handlerMock = nil;
    [self.sut hide];
    self.sut = nil;
}

- (void)test_show_overlay_fails_without_appIdentifier {
    if (@available(iOS 14.0, *)) {
        XCTestExpectation *failLoadExpectation = [self.handlerMock setFailCallbackWithExpectedError: kOverlayInvalidParamaters];

        [self.sut show: @{}];

        [self waitForExpectations: @[failLoadExpectation]
                          timeout: 1.0];
    }
}

- (void)test_shows_and_hides_overlay_with_valid_appIdentifier {
    NSDictionary *showParameters = [self validShowParameters];

    if (@available(iOS 14.0, *)) {
        XCTestExpectation *presentationExpectation = [self.handlerMock setPresentationCallbacks];

        [self.sut show: showParameters];
        [self waitForExpectations: @[presentationExpectation]
                          timeout: 2.0];

        XCTestExpectation *dismissalExpectation = [self.handlerMock setDismissalCallbacks];

        [self.sut hide];
        [self waitForExpectations: @[dismissalExpectation]
                          timeout: 1.0];
    } else {
        XCTestExpectation *failLoadExpectation = [self.handlerMock setFailCallbackWithExpectedError: kOverlayNotAvailable];

        [self.sut show: showParameters];

        [self waitForExpectations: @[failLoadExpectation]
                          timeout: 1.0];
    }
}

- (void)test_does_not_show_overlay_twice {
    if (@available(iOS 14.0, *)) {
        NSDictionary *showParameters = [self validShowParameters];
        XCTestExpectation *presentationExpectation = [self.handlerMock setPresentationCallbacks];

        [self.sut show: showParameters];
        [self waitForExpectations: @[presentationExpectation]
                          timeout: 2.0];

        XCTestExpectation *failExpectation = [self.handlerMock setFailCallbackWithExpectedError: kOverlayAlreadyShown];

        [self.sut show: showParameters];
        [self waitForExpectations: @[failExpectation]
                          timeout: 1.0];
    }
}

- (NSDictionary *)validShowParameters {
    return @{
        @"appIdentifier": @"871767552",
        @"position": @"1"
    };
}

@end
