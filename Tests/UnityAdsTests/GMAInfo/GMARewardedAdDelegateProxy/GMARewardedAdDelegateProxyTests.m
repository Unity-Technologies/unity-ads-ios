#import <XCTest/XCTest.h>
#import "USRVWebViewAppMock.h"
#import "USRVWebViewApp.h"
#import "GMARewardedAdDelegateProxy.h"
#import "GMAWebViewEvent.h"
#import "NSArray + Map.h"
#import "XCTestCase+Convenience.h"
#import "NSError+UADSError.h"
#import "GMADelegatesFactory.h"
#import "UADSWebViewErrorHandler.h"
#import "GMAError.h"
#import "GMATestCommonConstants.h"


@interface GMARewardedAdDelegateProxyTests : XCTestCase
@property (nonatomic, strong) USRVWebViewAppMock *webAppMock;
@end

@implementation GMARewardedAdDelegateProxyTests

- (void)setUp {
    _webAppMock = [USRVWebViewAppMock new];
    [USRVWebViewApp setCurrentApp: _webAppMock];
}

- (void)tearDown {
    _webAppMock = nil;
    [USRVWebViewApp setCurrentApp: _webAppMock];
}

- (void)test_will_present_for_the_first_time_triggers_events {
    GMARewardedAdDelegateProxy *delegateToTest = self.defaultProxyToTest;

    [delegateToTest rewardedAdDidPresent:  self.fakeAdObject];
    GMAAdMetaData *meta = self.defaultMeta;
    NSArray<GMAWebViewEvent *> *expectedEvents = @[
        [GMAWebViewEvent newAdStartedWithMeta: meta],
        [GMAWebViewEvent newFirstQuartileWithMeta: meta],
        [GMAWebViewEvent newMidPointWithMeta: meta],
        [GMAWebViewEvent newAdEarnRewardWithMeta: meta]
    ];

    [self validateExpectedEvents: expectedEvents];
}

- (void)test_did_present_full_screen_for_the_first_time_triggers_events {
    GMARewardedAdDelegateProxy *delegateToTest = self.defaultProxyToTest;

    [delegateToTest adDidPresentFullScreenContent:  self.fakeAdObject];
    GMAAdMetaData *meta = self.defaultMeta;
    NSArray<GMAWebViewEvent *> *expectedEvents = @[
        [GMAWebViewEvent newAdStartedWithMeta: meta],
        [GMAWebViewEvent newFirstQuartileWithMeta: meta],
        [GMAWebViewEvent newMidPointWithMeta: meta],
        [GMAWebViewEvent newAdEarnRewardWithMeta: meta]
    ];

    [self validateExpectedEvents: expectedEvents];
}

- (void)test_did_present_full_screen_triggers_events_only_once {
    GMARewardedAdDelegateProxy *delegateToTest = self.defaultProxyToTest;

    [delegateToTest adDidPresentFullScreenContent:  self.fakeAdObject];
    [delegateToTest adDidPresentFullScreenContent:  self.fakeAdObject];
    GMAAdMetaData *meta = self.defaultMeta;
    NSArray<GMAWebViewEvent *> *expectedEvents = @[
        [GMAWebViewEvent newAdStartedWithMeta: meta],
        [GMAWebViewEvent newFirstQuartileWithMeta: meta],
        [GMAWebViewEvent newMidPointWithMeta: meta],
        [GMAWebViewEvent newAdEarnRewardWithMeta: meta],
        [GMAWebViewEvent newAdStartedWithMeta: meta],
    ];

    [self validateExpectedEvents: expectedEvents];
}

- (void)test_will_present_triggers_events_only_once {
    GMARewardedAdDelegateProxy *delegateToTest = self.defaultProxyToTest;

    [delegateToTest rewardedAdDidPresent:  self.fakeAdObject];
    [delegateToTest rewardedAdDidPresent:  self.fakeAdObject];
    GMAAdMetaData *meta = self.defaultMeta;
    NSArray<GMAWebViewEvent *> *expectedEvents = @[
        [GMAWebViewEvent newAdStartedWithMeta: meta],
        [GMAWebViewEvent newFirstQuartileWithMeta: meta],
        [GMAWebViewEvent newMidPointWithMeta: meta],
        [GMAWebViewEvent newAdEarnRewardWithMeta: meta],
        [GMAWebViewEvent newAdStartedWithMeta: meta],
    ];

    [self validateExpectedEvents: expectedEvents];
}

- (void)test_did_dismiss_sends_ad_skipped_and_closed {
    GMARewardedAdDelegateProxy *delegateToTest = self.defaultProxyToTest;

    [delegateToTest rewardedAdDidPresent:  self.fakeAdObject];
    [delegateToTest rewardedAdDidDismiss: self.fakeAdObject];
    GMAAdMetaData *meta = self.defaultMeta;
    NSArray<GMAWebViewEvent *> *expectedEvents = @[
        [GMAWebViewEvent newAdStartedWithMeta: meta],
        [GMAWebViewEvent newFirstQuartileWithMeta: meta],
        [GMAWebViewEvent newMidPointWithMeta: meta],
        [GMAWebViewEvent newAdEarnRewardWithMeta: meta],
        [GMAWebViewEvent newAdSkippedWithMeta: meta],
        [GMAWebViewEvent newAdClosedWithMeta: meta],
    ];

    [self validateExpectedEvents: expectedEvents];
}

- (void)test_did_dismiss_doesnt_send_ad_skipped_when_finished {
    GMARewardedAdDelegateProxy *delegateToTest = self.defaultProxyToTest;

    [delegateToTest rewardedAdDidPresent:  self.fakeAdObject];

    [self waitForTimeInterval: 2];
    [delegateToTest rewardedAdDidDismiss: self.fakeAdObject];
    GMAAdMetaData *meta = self.defaultMeta;
    NSArray<GMAWebViewEvent *> *expectedEvents = @[
        [GMAWebViewEvent newAdStartedWithMeta: meta],
        [GMAWebViewEvent newFirstQuartileWithMeta: meta],
        [GMAWebViewEvent newMidPointWithMeta: meta],
        [GMAWebViewEvent newAdEarnRewardWithMeta: meta],
        [GMAWebViewEvent newAdClosedWithMeta: meta],
    ];

    [self validateExpectedEvents: expectedEvents];
}

- (void)test_ad_did_dismiss_full_screen_sends_ad_skipped_and_closed {
    GMARewardedAdDelegateProxy *delegateToTest = self.defaultProxyToTest;

    [delegateToTest rewardedAdDidPresent:  self.fakeAdObject];
    [delegateToTest adDidDismissFullScreenContent: self.fakeAdObject];
    GMAAdMetaData *meta = self.defaultMeta;
    NSArray<GMAWebViewEvent *> *expectedEvents = @[
        [GMAWebViewEvent newAdStartedWithMeta: meta],
        [GMAWebViewEvent newFirstQuartileWithMeta: meta],
        [GMAWebViewEvent newMidPointWithMeta: meta],
        [GMAWebViewEvent newAdEarnRewardWithMeta: meta],
        [GMAWebViewEvent newAdSkippedWithMeta: meta],
        [GMAWebViewEvent newAdClosedWithMeta: meta],
    ];

    [self validateExpectedEvents: expectedEvents];
}

- (void)test_ad_did_dismiss_full_screen_doesnt_send_ad_skipped_when_finished  {
    GMARewardedAdDelegateProxy *delegateToTest = self.defaultProxyToTest;

    [delegateToTest rewardedAdDidPresent:  self.fakeAdObject];
    [self waitForTimeInterval: 2];
    [delegateToTest adDidDismissFullScreenContent: self.fakeAdObject];
    GMAAdMetaData *meta = self.defaultMeta;
    NSArray<GMAWebViewEvent *> *expectedEvents = @[
        [GMAWebViewEvent newAdStartedWithMeta: meta],
        [GMAWebViewEvent newFirstQuartileWithMeta: meta],
        [GMAWebViewEvent newMidPointWithMeta: meta],
        [GMAWebViewEvent newAdEarnRewardWithMeta: meta],
        [GMAWebViewEvent newAdClosedWithMeta: meta],
    ];

    [self validateExpectedEvents: expectedEvents];
}

- (void)test_did_fail_sends_id_error_and_code {
    NSError *fakeError = [[NSError alloc] initWithDomain: @"domain"
                                                    code: 100
                                                userInfo: nil];

    GMARewardedAdDelegateProxy *delegateToTest = self.defaultProxyToTest;

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

- (id)fakeAdObject {
    return [NSObject new];
}

- (GMARewardedAdDelegateProxy *)defaultProxyToTest {
    return [self.delegatesFactory rewardedDelegate: self.defaultMeta];
}

- (GMAAdMetaData *)defaultMeta {
    GMAAdMetaData *meta = [GMAAdMetaData new];

    meta.adString = @"adString";
    meta.placementID = kFakePlacementID;
    meta.videoLength = @1;
    meta.queryID = kGMAQueryID;
    meta.type = GADQueryInfoAdTypeRewarded;
    return meta;
}

- (id<GMADelegatesFactory>)delegatesFactory {
    id<UADSWebViewEventSender>eventSender = [UADSWebViewEventSenderBase new];

    id<UADSErrorHandler>errorHandler = [UADSWebViewErrorHandler newWithEventSender: eventSender];

    return [GMADelegatesBaseFactory newWithEventSender: eventSender
                                          errorHandler: errorHandler];
}

@end
