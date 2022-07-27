#import <XCTest/XCTest.h>
#import "UADSOverlayEventHandler.h"
#import "USRVWebViewApp.h"
#import "USRVWebViewAppMock.h"
#import "UADSOverlayWebViewEvent.h"
#import "NSArray+Map.h"

@interface UADSOverlayEventHandlerTests : XCTestCase
@property (nonatomic, strong) USRVWebViewAppMock *webAppMock;
@end

@implementation UADSOverlayEventHandlerTests

- (void)setUp {
    _webAppMock = [USRVWebViewAppMock new];
    [USRVWebViewApp setCurrentApp: _webAppMock];
}

- (void)tearDown {
    _webAppMock = nil;
    [USRVWebViewApp setCurrentApp: _webAppMock];
}

- (void)test_sends_webview_events {
    UADSOverlayEventHandler *sut = [[UADSOverlayEventHandler alloc] initWithEventSender: [UADSWebViewEventSenderBase new]];

    if (@available(iOS 14.0, *)) {
        [sut sendOverlayWillStartPresentation: nil];
        [sut sendOverlayDidFinishPresentation: nil];
        [sut sendOverlayWillStartDismissal: nil];
        [sut sendOverlayDidFinishDismissal: nil];
        [sut sendOverlayDidFailToLoad: nil
                                error: kOverlayAlreadyShown
                              message: nil];

        [self validateExpectedEvents: @[
             [UADSOverlayWebViewEvent newWillStartPresentation],
             [UADSOverlayWebViewEvent newDidFinishPresentation],
             [UADSOverlayWebViewEvent newWillStartDismissal],
             [UADSOverlayWebViewEvent newDidFinishDismissal],
             [UADSOverlayWebViewEvent newDidFailToLoadWithParams: nil]
        ]];
    } else {
        [sut sendOverlayDidFailToLoad: kOverlayNotAvailable];
        [self validateExpectedEvents: @[
             [UADSOverlayWebViewEvent newDidFailToLoadWithParams: nil]
        ]];
    }
}

- (void)validateExpectedEvents: (NSArray<UADSOverlayWebViewEvent *> *)expectedEvents {
    NSArray *expectedEventNames = [expectedEvents uads_mapObjectsUsingBlock: ^id _Nonnull (UADSOverlayWebViewEvent *_Nonnull obj) {
        return obj.eventName;
    }];

    NSArray *expectedCategoryNames = [expectedEvents uads_mapObjectsUsingBlock: ^id _Nonnull (UADSOverlayWebViewEvent *_Nonnull obj) {
        return obj.categoryName;
    }];

    XCTAssertEqualObjects(_webAppMock.eventNames, expectedEventNames);
    XCTAssertEqualObjects(_webAppMock.categoryNames, expectedCategoryNames);
}

@end
