#import <XCTest/XCTest.h>
#import "GMATestsHelper.h"
#import "GMAWebViewEvent.h"
#import "GMAError.h"
@interface UADSNoGMAApiTests : XCTestCase
@property (nonatomic, strong) GMATestsHelper *tester;
@end

@implementation UADSNoGMAApiTests

- (void)setUp {
    _tester = [GMATestsHelper new];
    [_tester install];
}

- (void)tearDown {
    [_tester clear];
    _tester = nil;
}

- (void)test_returns_is_available_flag_false {
    [_tester emulateIsAvailableCall:^(NSNumber *_Nullable result) {
        XCTAssertEqualObjects(result, [NSNumber numberWithBool: false]);
    }];
}

- (void)test_returns_version_placeholder {
    [_tester emulateGetVersionCall:^(NSString *_Nullable version) {
        XCTAssertEqualObjects(version, @"0.0.0");
    }];
}

- (void)test_returns_internal_error_when_get_signals_is_called {
    GMAError *error = [GMAError newInternalSignalsError];

    [_tester emulateGetScarSignals: @[@"test"]
                rewardedPlacements: @[]
                          testCase: self
                    expectedEvents: @[[error convertToEvent]]];
}

- (void)test_returns_internal_error_when_load_is_called {
    GMAAdMetaData *meta = [GMAAdMetaData new];

    meta.placementID = @"placementID";
    meta.type = GADQueryInfoAdTypeInterstitial;
    meta.adString = @"adString";
    meta.queryID = @"queryID";
    meta.adUnitID = @"adUnitID";
    meta.videoLength = @1;
    GMAError *error = [GMAError newNonSupportedLoader: meta];
    NSArray *params = @[
        meta.placementID,
        meta.queryID,
        @(meta.type),
        meta.adUnitID,
        meta.adString,
        meta.videoLength
    ];

    [_tester emulateLoadWithParams: params
                          testCase: self
                    expectedEvents: @[[error convertToEvent]]];
}

- (void)test_returns_internal_error_when_show_is_called {
    GMAAdMetaData *meta = [GMAAdMetaData new];

    meta.placementID = @"placementID";
    meta.type = GADQueryInfoAdTypeInterstitial;
    meta.adString = @"adString";
    meta.queryID = @"queryID";
    meta.adUnitID = @"adUnitID";
    meta.videoLength = @1;
    GMAError *error = [GMAError newNonSupportedPresenter: meta];
    NSArray *params = @[
        meta.placementID,
        meta.queryID,
        @(meta.type),
    ];

    [_tester emulateShowWithParams: params
                          testCase: self
                    expectedEvents: @[[error convertToEvent]]];
}

- (void)test_passing_wrong_types_of_arguments_to_load {
    GMAAdMetaData *meta = [GMAAdMetaData new];


    meta.placementID = (NSString *)@1;     // to compare with the result
    meta.type = GADQueryInfoAdTypeInterstitial;
    meta.adString = @"";
    meta.queryID = (NSString *)@0;     // to compare with the result
    meta.adUnitID = @"";
    meta.videoLength = @1;
    GMAError *error = [GMAError newNonSupportedLoader: meta];

    NSArray *params = @[
        @1,
        @(false),
        @"test",
        @1,
        @3,
        @"test2"
    ];

    [_tester emulateLoadWithParams: params
                          testCase: self
                    expectedEvents:  @[[error convertToEvent]]];
}

@end
