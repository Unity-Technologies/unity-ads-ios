#import <XCTest/XCTest.h>
#import "GMAError.h"
#import "GMATestCommonConstants.h"
#import "UADSWebViewEvent.h"
#import "NSError+UADSError.h"

static NSString *const kGMANullPlacementID = @"NULL_PLACEMENT_ID";
static NSString *const kGMAInterstitialName = @"Interstitial";
static NSString *const kGMARewardedName = @"Rewarded";
@interface GMAErrorTests : XCTestCase

@end

@implementation GMAErrorTests

- (void)test_show_error_contains_right_params {
    GMAError *error = [GMAError newNoAdFoundToShowForMeta: self.defaultMeta];
    NSString *message = [NSString stringWithFormat: kGMANoAdFoundFormat, kGMAInterstitialName];

    [self compareError: error
          expEventName: @"NO_AD_ERROR"
             expParams: @[self.defaultMeta.placementID,
                          self.defaultMeta.queryID,
                          message]];
}

- (void)test_ad_is_null_contains_right_params_when_meta_is_empty {
    GMAError *error = [GMAError newCannotCreateAd: [GMAAdMetaData new]];
    NSString *message = [NSString stringWithFormat: kGMACannotCreateAdFormat, kGMARewardedName];

    [self compareError: error
          expEventName: @"INTERNAL_LOAD_ERROR"
             expParams: @[kGMANullPlacementID, message]];
}

- (void)test_ad_is_null_contains_right_params_with_meta {
    GMAError *error = [GMAError newCannotCreateAd: self.defaultMeta];
    NSString *message = [NSString stringWithFormat: kGMACannotCreateAdFormat, kGMAInterstitialName];

    [self compareError: error
          expEventName: @"INTERNAL_LOAD_ERROR"
             expParams: @[self.defaultMeta.placementID, self.defaultMeta.queryID, message]];
}

- (void)test_strategy_not_supported_error_params_when_meta_is_empty {
    GMAError *error = [GMAError newNonSupportedLoader: [GMAAdMetaData new]];
    NSString *message = [NSString stringWithFormat: kGMANonSupportedLoaderFormat, @"Rewarded"];

    [self compareError: error
          expEventName: @"INTERNAL_LOAD_ERROR"
             expParams: @[kGMANullPlacementID, message]];
}

- (void)test_loader_not_supported_error_params_with_meta {
    GMAError *error = [GMAError newNonSupportedLoader: self.defaultMeta];
    NSString *message = [NSString stringWithFormat: kGMANonSupportedLoaderFormat, @"Interstitial"];

    [self compareError: error
          expEventName: @"INTERNAL_LOAD_ERROR"
             expParams: @[self.defaultMeta.placementID, self.defaultMeta.queryID, message]];
}

- (void)test_load_error_contains_right_params_no_meta {
    NSError *nsError = self.fakeError;
    GMAError *error = [GMAError newLoadErrorUsingMetaData: [GMAAdMetaData new]
                                                 andError: nsError];

    [self compareError: error
          expEventName: @"LOAD_ERROR"
             expParams: @[ kGMANullPlacementID,
                           nsError.errorString,
                           nsError.errorCode]];
}

- (void)test_load_error_contains_right_params_with_meta {
    NSError *nsError = self.fakeError;
    GMAError *error = [GMAError newLoadErrorUsingMetaData: self.defaultMeta
                                                 andError: nsError];

    [self compareError: error
          expEventName: @"LOAD_ERROR"
             expParams: @[ self.defaultMeta.placementID,
                           self.defaultMeta.queryID,
                           nsError.errorString,
                           nsError.errorCode]];
}

- (void)test_query_not_found_contains_right_params_with_meta {
    GMAError *error = [GMAError newInternalLoadQueryNotFound: self.defaultMeta];
    NSString *message = [NSString stringWithFormat: kGMAQueryNotFoundFormat, self.defaultMeta.placementID];

    [self compareError: error
          expEventName: @"QUERY_NOT_FOUND_ERROR"
             expParams: @[self.defaultMeta.placementID,
                          self.defaultMeta.queryID,
                          message]];
}

- (void)test_ad_not_created_contains_right_params_with_meta {
    GMAError *error = [GMAError newCannotCreateAd: self.defaultMeta];
    NSString *message = [NSString stringWithFormat: kGMACannotCreateAdFormat, @"Interstitial"];

    [self compareError: error
          expEventName: @"INTERNAL_LOAD_ERROR"
             expParams: @[self.defaultMeta.placementID,
                          self.defaultMeta.queryID,
                          message]];
}

- (void)test_show_error_contains_right_params_with_meta {
    NSError *nsError = self.fakeError;
    GMAError *error = [GMAError newShowErrorWithMeta: self.defaultMeta
                                           withError: nsError];

    [self compareError: error
          expEventName: @"INTERSTITIAL_SHOW_ERROR"
             expParams: @[ self.defaultMeta.placementID,
                           self.defaultMeta.queryID,
                           nsError.errorString,
                           nsError.errorCode]];
}

- (NSError *)fakeError {
    return [[NSError alloc] initWithDomain: @"domain "
                                      code: 100
                                  userInfo: nil];
}

- (void)compareError: (GMAError *)error
        expEventName: (NSString *)name
           expParams: (NSArray *)params {
    id<UADSWebViewEvent>event = [error convertToEvent];

    XCTAssertEqualObjects(event.eventName, name);
    XCTAssertEqualObjects(event.categoryName, kGMAEventName);
    XCTAssertEqualObjects(event.params, params);
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

@end
