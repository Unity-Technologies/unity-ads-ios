#import <XCTest/XCTest.h>
#import "GADQueryInfoBridge.h"
#import "GMABaseQueryInfoReader+TestCategory.h"

@interface GADQueryInfoBridgeTests : XCTestCase

@end

@implementation GADQueryInfoBridgeTests

- (void)test_the_class_exists {
    XCTAssertTrue([GADQueryInfoBridge exists]);
}

- (void)test_creates_queryInfo {
    XCTAssertNotNil([self bridgeOfType: GADQueryInfoAdTypeInterstitial]);
    XCTAssertNotNil([self bridgeOfType: GADQueryInfoAdTypeRewarded]);
}

- (void)test_request_id_of_interstitial_is_not_nil {
    GADQueryInfoBridge *info = [self bridgeOfType: GADQueryInfoAdTypeInterstitial];

    XCTAssertNotNil(info.requestIdentifier);
}

- (void)test_request_id_of_rewarded_is_not_nil {
    GADQueryInfoBridge *info = [self bridgeOfType: GADQueryInfoAdTypeRewarded];

    XCTAssertNotNil(info.requestIdentifier);
}

- (void)test_source_query_dictionary_of_interstitial_is_not_nil {
    GADQueryInfoBridge *info = [self bridgeOfType: GADQueryInfoAdTypeInterstitial];

    XCTAssertNotNil(info.sourceQueryDictionary);
}

- (void)test_source_query_dictionary_of_rewarded_is_not_nil {
    GADQueryInfoBridge *info = [self bridgeOfType: GADQueryInfoAdTypeRewarded];

    XCTAssertNotNil(info.sourceQueryDictionary);
}

- (void)test_query_dictionary_of_interstitial_is_not_nil {
    GADQueryInfoBridge *info = [self bridgeOfType: GADQueryInfoAdTypeInterstitial];

    XCTAssertNotNil(info.queryDictionary);
}

- (void)test_query_dictionary_of_rewarded_is_not_nil {
    GADQueryInfoBridge *info = [self bridgeOfType: GADQueryInfoAdTypeRewarded];

    XCTAssertNotNil(info.queryDictionary);
}

- (void)test_query_string_of_interstitial_is_not_nil {
    GADQueryInfoBridge *info = [self bridgeOfType: GADQueryInfoAdTypeInterstitial];

    XCTAssertNotNil(info.query);
}

- (void)test_query_string_of_rewarded_is_not_nil {
    GADQueryInfoBridge *info = [self bridgeOfType: GADQueryInfoAdTypeRewarded];

    XCTAssertNotNil(info.query);
}

- (GADQueryInfoBridge *)bridgeOfType: (GADQueryInfoAdType)type {
    return [GMABaseQueryInfoReader getQueryInfoSyncOfType: type
                                              forTestCase: self];
}

@end
