#import <XCTest/XCTest.h>
#import "USRVWebViewAppMock.h"
#import "USRVWebViewApp.h"
#import "GMAInterstitialAdDelegateProxy.h"
#import "GMAWebViewEvent.h"
#import "NSArray + Map.h"
#import "XCTestCase+Convenience.h"
#import "NSError+UADSError.h"
#import "GMADelegatesFactory.h"
#import "UADSWebViewErrorHandler.h"
#import "GMAError.h"
#import "GMATestCommonConstants.h"

@interface GMAInterstitialAdDelegateProxyTests : XCTestCase
@property (nonatomic, strong) USRVWebViewAppMock *webAppMock;
@end

@implementation GMAInterstitialAdDelegateProxyTests

- (void)setUp {
    _webAppMock = [USRVWebViewAppMock new];
    [USRVWebViewApp setCurrentApp: _webAppMock];
}

- (void)tearDown {
    _webAppMock = nil;
    [USRVWebViewApp setCurrentApp: _webAppMock];
}

- (void)test_will_present_for_the_first_time_triggers_events {
    GMAInterstitialAdDelegateProxy *delegateToTest = self.defaultProxyToTest;

    [delegateToTest interstitialWillPresentScreen:  self.fakeAdObject];
    GMAAdMetaData *meta = self.defaultMeta;
    NSArray<GMAWebViewEvent *> *expectedEvents = @[
        [GMAWebViewEvent newAdStartedWithMeta: meta],
        [GMAWebViewEvent newFirstQuartileWithMeta: meta],
        [GMAWebViewEvent newMidPointWithMeta: meta],
    ];

    [self validateExpectedEvents: expectedEvents];
    [self validateExpectedDefaultParamsInEvents: expectedEvents];
}

- (void)test_did_present_full_screen_for_the_first_time_triggers_events {
    GMAInterstitialAdDelegateProxy *delegateToTest = self.defaultProxyToTest;

    [delegateToTest adDidPresentFullScreenContent:  self.fakeAdObject];
    GMAAdMetaData *meta = self.defaultMeta;
    NSArray<GMAWebViewEvent *> *expectedEvents = @[
        [GMAWebViewEvent newAdStartedWithMeta: meta],
        [GMAWebViewEvent newFirstQuartileWithMeta: meta],
        [GMAWebViewEvent newMidPointWithMeta: meta],
    ];

    [self validateExpectedEvents: expectedEvents];
    [self validateExpectedDefaultParamsInEvents: expectedEvents];
}

- (void)test_did_present_full_screen_triggers_events_only_once {
    GMAInterstitialAdDelegateProxy *delegateToTest = self.defaultProxyToTest;

    [delegateToTest adDidPresentFullScreenContent:  self.fakeAdObject];
    [delegateToTest adDidPresentFullScreenContent:  self.fakeAdObject];
    GMAAdMetaData *meta = self.defaultMeta;
    NSArray<GMAWebViewEvent *> *expectedEvents = @[
        [GMAWebViewEvent newAdStartedWithMeta: meta],
        [GMAWebViewEvent newFirstQuartileWithMeta: meta],
        [GMAWebViewEvent newMidPointWithMeta: meta],
        [GMAWebViewEvent newAdStartedWithMeta: meta],
    ];

    [self validateExpectedEvents: expectedEvents];
    [self validateExpectedDefaultParamsInEvents: expectedEvents];
}

- (void)test_will_present_triggers_events_only_once {
    GMAInterstitialAdDelegateProxy *delegateToTest = self.defaultProxyToTest;

    [delegateToTest interstitialWillPresentScreen:  self.fakeAdObject];
    [delegateToTest interstitialWillPresentScreen:  self.fakeAdObject];
    GMAAdMetaData *meta = self.defaultMeta;
    NSArray<GMAWebViewEvent *> *expectedEvents = @[
        [GMAWebViewEvent newAdStartedWithMeta: meta],
        [GMAWebViewEvent newFirstQuartileWithMeta: meta],
        [GMAWebViewEvent newMidPointWithMeta: meta],
        [GMAWebViewEvent newAdStartedWithMeta: meta],
    ];

    [self validateExpectedEvents: expectedEvents];
    [self validateExpectedDefaultParamsInEvents: expectedEvents];
}

- (void)test_did_dismiss_sends_ad_skipped_and_closed {
    GMAInterstitialAdDelegateProxy *delegateToTest = self.defaultProxyToTest;

    [delegateToTest interstitialWillPresentScreen:  self.fakeAdObject];
    [delegateToTest interstitialDidDismissScreen: self.fakeAdObject];
    GMAAdMetaData *meta = self.defaultMeta;
    NSArray<GMAWebViewEvent *> *expectedEvents = @[
        [GMAWebViewEvent newAdStartedWithMeta: meta],
        [GMAWebViewEvent newFirstQuartileWithMeta: meta],
        [GMAWebViewEvent newMidPointWithMeta: meta],
        [GMAWebViewEvent newAdSkippedWithMeta: meta],
        [GMAWebViewEvent newAdClosedWithMeta: meta],
    ];

    [self validateExpectedEvents: expectedEvents];
    [self validateExpectedDefaultParamsInEvents: expectedEvents];
}

- (void)test_did_dismiss_doesnt_send_ad_skipped_when_finished {
    GMAInterstitialAdDelegateProxy *delegateToTest = self.defaultProxyToTest;

    [delegateToTest interstitialWillPresentScreen:  self.fakeAdObject];

    [self waitForTimeInterval: 2];
    [delegateToTest interstitialDidDismissScreen: self.fakeAdObject];
    GMAAdMetaData *meta = self.defaultMeta;
    NSArray<GMAWebViewEvent *> *expectedEvents = @[
        [GMAWebViewEvent newAdStartedWithMeta: meta],
        [GMAWebViewEvent newFirstQuartileWithMeta: meta],
        [GMAWebViewEvent newMidPointWithMeta: meta],
        [GMAWebViewEvent newAdClosedWithMeta: meta],
    ];

    [self validateExpectedEvents: expectedEvents];
    [self validateExpectedDefaultParamsInEvents: expectedEvents];
}

- (void)test_ad_did_dismiss_full_screen_sends_ad_skipped_and_closed {
    GMAInterstitialAdDelegateProxy *delegateToTest = self.defaultProxyToTest;

    [delegateToTest interstitialWillPresentScreen:  self.fakeAdObject];
    [delegateToTest adDidDismissFullScreenContent: self.fakeAdObject];
    GMAAdMetaData *meta = self.defaultMeta;
    NSArray<GMAWebViewEvent *> *expectedEvents = @[
        [GMAWebViewEvent newAdStartedWithMeta: meta],
        [GMAWebViewEvent newFirstQuartileWithMeta: meta],
        [GMAWebViewEvent newMidPointWithMeta: meta],
        [GMAWebViewEvent newAdSkippedWithMeta: meta],
        [GMAWebViewEvent newAdClosedWithMeta: meta],
    ];

    [self validateExpectedEvents: expectedEvents];
    [self validateExpectedDefaultParamsInEvents: expectedEvents];
}

- (void)test_ad_did_dismiss_full_screen_doesnt_send_ad_skipped_when_finished  {
    GMAInterstitialAdDelegateProxy *delegateToTest = self.defaultProxyToTest;

    [delegateToTest interstitialWillPresentScreen:  self.fakeAdObject];
    [self waitForTimeInterval: 2];
    [delegateToTest adDidDismissFullScreenContent: self.fakeAdObject];
    GMAAdMetaData *meta = self.defaultMeta;
    NSArray<GMAWebViewEvent *> *expectedEvents = @[
        [GMAWebViewEvent newAdStartedWithMeta: meta],
        [GMAWebViewEvent newFirstQuartileWithMeta: meta],
        [GMAWebViewEvent newMidPointWithMeta: meta],
        [GMAWebViewEvent newAdClosedWithMeta: meta],
    ];

    [self validateExpectedEvents: expectedEvents];
    [self validateExpectedDefaultParamsInEvents: expectedEvents];
}

- (void)test_will_leave_app_triggers_click {
    GMAInterstitialAdDelegateProxy *delegateToTest = self.defaultProxyToTest;

    [delegateToTest interstitialWillLeaveApplication: self.fakeAdObject];

    GMAAdMetaData *meta = self.defaultMeta;
    NSArray<GMAWebViewEvent *> *expectedEvents = @[
        [GMAWebViewEvent newAdClickedWithMeta: meta],
    ];

    [self validateExpectedEvents: expectedEvents];
    [self validateExpectedDefaultParamsInEvents: expectedEvents];
}

- (void)test_did_fail_sends_id_error_and_code {
    NSError *fakeError = [[NSError alloc] initWithDomain: @"domain "
                                                    code: 100
                                                userInfo: nil];

    GMAInterstitialAdDelegateProxy *delegateToTest = self.defaultProxyToTest;

    [delegateToTest ad: kFakePlacementID
           didFailToPresentFullScreenContentWithError: fakeError];

    NSArray<GMAWebViewEvent *> *expectedEvents = @[
        [[GMAError newShowErrorWithMeta: self.defaultMeta
                              withError: fakeError] convertToEvent]
    ];

    [self validateExpectedEvents: expectedEvents];


    NSArray *receivedParams = _webAppMock.params[0];

    XCTAssertEqualObjects(receivedParams[0], kFakePlacementID);
    XCTAssertEqualObjects(receivedParams[1], kGMAQueryID);
    XCTAssertEqualObjects(receivedParams[2], fakeError.errorString);
    XCTAssertEqualObjects(receivedParams[3], fakeError.errorCode);
}

- (void)validateExpectedEvents: (NSArray<GMAWebViewEvent *> *)expectedEvents {
    NSArray *expectedEventNames = [expectedEvents uads_mapObjectsUsingBlock: ^id _Nonnull (GMAWebViewEvent *_Nonnull obj) {
        return obj.eventName;
    }];

    NSArray *expectedCategoryNames = [expectedEvents uads_mapObjectsUsingBlock: ^id _Nonnull (GMAWebViewEvent *_Nonnull obj) {
        return obj.categoryName;
    }];

    XCTAssertEqualObjects(_webAppMock.eventNames, expectedEventNames);
    XCTAssertEqualObjects(_webAppMock.categoryNames, expectedCategoryNames);
}

- (void)validateExpectedDefaultParamsInEvents: (NSArray<GMAWebViewEvent *> *)expectedEvents  {
    NSArray *expectedParams = [NSArray new];

    for (id event in expectedEvents) {
        expectedParams = [expectedParams arrayByAddingObject: @[kFakePlacementID, kGMAQueryID]];         // creating expected array since default params are the same
    }

    XCTAssertEqualObjects(_webAppMock.params, expectedParams);
}

- (id)fakeAdObject {
    return [NSObject new];
}

- (GMAInterstitialAdDelegateProxy *)defaultProxyToTest {
    return [self.delegatesFactory interstitialDelegate: self.defaultMeta
                                         andCompletion: [UADSAnyCompletion new]];
}

- (GMAAdMetaData *)defaultMeta {
    GMAAdMetaData *meta = [GMAAdMetaData new];

    meta.adString = @"adString ";
    meta.placementID = kFakePlacementID;
    meta.videoLength = @1;
    meta.queryID = kGMAQueryID;
    meta.type = GADQueryInfoAdTypeInterstitial;
    return meta;
}

- (id<GMADelegatesFactory>)delegatesFactory {
    id<UADSWebViewEventSender>eventSender = [UADSWebViewEventSenderBase new];

    id<UADSErrorHandler>errorHandler = [UADSWebViewErrorHandler newWithEventSender: eventSender];

    return [GMADelegatesBaseFactory newWithEventSender: eventSender
                                          errorHandler: errorHandler];
}

@end
