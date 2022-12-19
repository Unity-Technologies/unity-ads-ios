#import <XCTest/XCTest.h>
#import "UADSGMAScar.h"
#import "GMAIntegrationTestsConstants.h"
#import "UADSGMAScar+SyncGetter.h"
#import "GMAAdLoaderStrategy.h"
#import "GMAError+XCTest.h"
#import "EventSenderMock.h"
#import "XCTestCase+Convenience.h"
#import "UADSGMAScarForTest.h"
#import "GMABaseQuerySignalReaderV85.h"

#define GMA_INTERSTITIAL_LIST @[@"interstitial_video"]
#define GMA_REWARDED_LIST     @[@"rewarded_video"]

@interface UADSGMAScarTests : XCTestCase
@property (nonatomic, strong) UADSGMAScarForTest *sut;
@property (nonatomic, strong) GMABaseSCARSignalsReader *signalsService;
@property (nonatomic, strong) EventSenderMock *senderMock;
@end

@implementation UADSGMAScarTests

- (void)setUp {
    [self setUpE2ETests];
}

- (void)setUpE2ETests {
    _senderMock = [EventSenderMock new];
    _sut = [[UADSGMAScarForTest alloc] initWithEventSender: _senderMock];
}

- (void)tearDown {
    _sut = nil;
    _signalsService = nil;
}

- (void)test_get_signals_return_response {
    [_sut getSignalsSyncWithErrorTest: GMA_INTERSTITIAL_LIST
                      andRewardedList: GMA_REWARDED_LIST
                              forTest: self
                        andCompletion:^(NSString *_Nullable encodedString) {
                            XCTAssertNotNil(encodedString);
                            XCTAssertTrue([encodedString length] > 0);
                        }];
}

- (void)test_get_loads_an_ad_after_signals_success {
    [_sut getSignalsSyncWithTestCase: self
                 andInterstitialList: GMA_INTERSTITIAL_LIST
                     andRewardedList: @[]];

    GMAAdMetaData *meta = [self defaultMetaForType: GADQueryInfoAdTypeInterstitial];

    meta.placementID = GMA_INTERSTITIAL_LIST[0];
    meta.adString = [self fakeAdString];

    [_sut loadSuccessSyncWithTestCase: self
                          andMetaData: meta
                 andSuccessCompletion:^(GADBaseAd *_Nullable ad) {
                     XCTAssertNotNil(ad);
                 }];
}

- (void)test_load_ad_not_found_error {
    [_sut getSignalsSyncWithTestCase: self
                 andInterstitialList: GMA_INTERSTITIAL_LIST
                     andRewardedList: @[]];

    GMAAdMetaData *meta = [self defaultMetaForType: GADQueryInfoAdTypeInterstitial];
    NSString *eventName;
    NSArray *params;
    if ([GMABaseQuerySignalReaderV85 isSupported]) {
        eventName = @"LOAD_ERROR";
        params = @[meta.placementID, meta.queryID, kGMAAdStringWasInvalid, @(13)];
    } else {
        eventName = @"QUERY_NOT_FOUND_ERROR";
        params = @[meta.placementID,
                   meta.queryID,
                   [NSString stringWithFormat: kGMAQueryNotFoundFormat, meta.placementID]];
    }
    [_sut loadErrorSyncWithTestCase: self
                        andMetaData: meta
                 andErrorCompletion:^(id<UADSError> _Nonnull error) {
                     GMAError *gmaError = (GMAError *)error;
                     [gmaError testWithEventName: eventName
                                       expParams: params];
                 }];
}

- (NSString *)fakeAdString {
    return [NSString stringWithFormat: @"{\"request_id\":\"%@\"}", _sut.lastRequestId];
}

- (void)test_non_supported_loader_produces_the_right_error {
    GMAAdMetaData *meta = [self defaultMetaForType: GADQueryInfoAdTypeInterstitial];

    meta.type = 5;
    NSString *message = [NSString stringWithFormat: kGMANonSupportedLoaderFormat, @"Rewarded"];
    id errorcompletion = ^(id<UADSError> error) {
        GMAError *gmaError = (GMAError *)error;
        [gmaError testWithEventName: @"INTERNAL_LOAD_ERROR"
                          expParams: @[ meta.placementID, meta.queryID, message]];
    };

    [_sut loadErrorSyncWithTestCase: self
                        andMetaData: meta
                 andErrorCompletion: errorcompletion];
}

- (GMAAdMetaData *)defaultMetaForType: (GADQueryInfoAdType)type  {
    GMAAdMetaData *meta = [GMAAdMetaData new];

    meta.adString = @"adString";
    meta.placementID = @"placementID";
    meta.adUnitID = kDefaultAdUnitID;
    meta.videoLength = @10;
    meta.queryID = @"queryID";
    meta.type = type;
    return meta;
}

@end
