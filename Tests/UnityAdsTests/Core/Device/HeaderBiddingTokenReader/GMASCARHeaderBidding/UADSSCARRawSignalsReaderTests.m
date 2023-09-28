#import <XCTest/XCTest.h>
#import "UADSSCARRawSignalsReader.h"
#import "GMASCARSignalServiceMock.h"
#import "UADSSCARSignalIdentifiers.h"
#import "UADSConfigurationReaderMock.h"

@interface UADSSCARRawSignalsReaderTests : XCTestCase
@property(nonatomic, strong) UADSSCARRawSignalsReader* scarSignalReader;
@property(nonatomic, strong) UADSHeaderBiddingTokenReaderSCARSignalsConfig *configMock;
@property(nonatomic, strong) GMASCARSignalServiceMock *signalsMock;
@property(nonatomic, strong) UADSConfigurationReaderMock *configReaderMock;
@end

@implementation UADSSCARRawSignalsReaderTests

- (void)setUp {
    _scarSignalReader =  [UADSSCARRawSignalsReader new];
    _configMock = [UADSHeaderBiddingTokenReaderSCARSignalsConfig new];
    _signalsMock = [GMASCARSignalServiceMock new];
    _configReaderMock = [UADSConfigurationReaderMock new];
    _configMock.signalService = _signalsMock;
    _configMock.configurationReader = _configReaderMock;
    _scarSignalReader.config = _configMock;
}

- (void)test_does_not_collect_banner_signals_if_not_enabled {
    [self executeWithBanner: NO completeWith: @{} result: nil];
}

- (void)test_collects_banner_signals_if_enabled {
    [self executeWithBanner: YES completeWith: @{} result: nil];
}

- (void)test_returns_nil_if_no_requested_signals_collected {
    NSDictionary *expected = @{ UADSScarBannerSignal: @"signal" };
    [self executeWithBanner: NO completeWith: expected result: nil];
}

- (void)test_returns_signals_if_collected_banner {
    NSDictionary *expected = @{ UADSScarBannerSignal: @"signal" };
    [self executeWithBanner: YES completeWith: expected result: expected];
}

- (void)test_returns_signals_if_collected_with_banner_disabled {
    NSDictionary *expected = @{ UADSScarRewardedSignal: @"signal", UADSScarInterstitialSignal: @"signal"};
    [self executeWithBanner: NO completeWith: expected result: expected];
}

- (void)test_returns_signals_if_collected_with_banner_enabled {
    NSDictionary *expected = @{ UADSScarRewardedSignal: @"signal", UADSScarInterstitialSignal: @"signal"};
    [self executeWithBanner: YES completeWith: expected result: expected];
}

- (void)executeWithBanner: (BOOL)banner completeWith:(UADSSCARSignals *)completion result:(UADSSCARSignals *)expectedResult {
    _configReaderMock.experiments = @{ @"scar_bn": @(banner) };
   
    XCTestExpectation *exp = [self expectationWithDescription:@"signals"];
    [_scarSignalReader requestSCARSignalsWithIsAsync:true
                                          completion:^(UADSSCARSignals * _Nullable result) {
        XCTAssertEqualObjects(result, expectedResult);
        [exp fulfill];
    }];
    [_signalsMock callSuccessCompletion: completion];
    [self waitForExpectations:@[exp] timeout:1.0];
    
    XCTAssertEqualObjects(_signalsMock.requestedSignals, [self signalsToCollectWithBanner: banner]);
}

- (NSArray<UADSScarSignalParameters *>*)signalsToCollectWithBanner:(BOOL)withBanner {
    NSMutableArray<UADSScarSignalParameters *> *params = [NSMutableArray arrayWithArray:@[
        [[UADSScarSignalParameters alloc] initWithPlacementId:UADSScarInterstitialSignal adFormat:GADQueryInfoAdTypeInterstitial],
        [[UADSScarSignalParameters alloc] initWithPlacementId:UADSScarRewardedSignal adFormat: GADQueryInfoAdTypeRewarded]
    ]];
    if (withBanner) {
        [params addObject:[[UADSScarSignalParameters alloc] initWithPlacementId:UADSScarBannerSignal adFormat:GADQueryInfoAdTypeBanner]];
    }
    return params;
}

@end
