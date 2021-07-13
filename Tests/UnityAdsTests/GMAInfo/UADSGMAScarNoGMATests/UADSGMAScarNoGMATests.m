#import <XCTest/XCTest.h>
#import "UADSGMAScar+SyncGetter.h"
#import "GMAError+XCTest.h"

@interface UADSGMAScarNoGMATests : XCTestCase
@property (nonatomic, strong) UADSGMAScar *sut;
@end

@implementation UADSGMAScarNoGMATests

- (void)setUp {
    _sut = UADSGMAScar.sharedInstance;
}

- (void)test_should_return_empty_string_as_version {
    XCTAssertEqualObjects(_sut.sdkVersion, @"0.0.0");
}

- (void)test_is_available_returns_false {
    XCTAssertEqual(_sut.isAvailable, false);
}

- (void)test_get_signals_should_return_an_internal_error {
    [_sut getSignalsSyncWithSuccessTest: @[@""]
                        andRewardedList: @[]
                                forTest: self
                     andErrorCompletion:^(id<UADSError> _Nonnull error) {
                         GMAError *gmaError = (GMAError *)error;
                         [gmaError testWithEventName: @"INTERNAL_SIGNALS_ERROR"
                                           expParams: @[kGMAInternalSignalsErrorMessage]];
                     }];
}

- (void)test_load_returns_error_of_non_supported_loader {
    GMAAdMetaData *meta = [GMAAdMetaData new];

    meta.placementID = @"placementID";
    meta.type = GADQueryInfoAdTypeInterstitial;
    NSString *message = [NSString stringWithFormat: kGMANonSupportedLoaderFormat, @"Interstitial"];


    [_sut loadErrorSyncWithTestCase: self
                        andMetaData: meta
                 andErrorCompletion:^(id<UADSError> _Nonnull error) {
                     GMAError *gmaError = (GMAError *)error;
                     [gmaError testWithEventName: @"INTERNAL_LOAD_ERROR"
                                       expParams: @[meta.placementID, message]];
                 }];
}

@end
