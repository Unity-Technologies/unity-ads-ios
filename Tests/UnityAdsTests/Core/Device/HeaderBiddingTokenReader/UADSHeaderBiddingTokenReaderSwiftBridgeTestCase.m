#import <XCTest/XCTest.h>
#import "UADSHeaderBiddingTokenReaderSwiftBridge.h"

@interface UADSHeaderBiddingTokenReaderSwiftBridgeTestCase : XCTestCase

@end

@implementation UADSHeaderBiddingTokenReaderSwiftBridgeTestCase

- (void)setUp {
    [self saveConfigurationWithSwiftDeviceInfo:true];
}

- (void)tearDown {
}

- (void)test_native_generator_in_swift_returns_token {
    UADSHeaderBiddingTokenReaderSwiftBridge *bridge = [UADSHeaderBiddingTokenReaderSwiftBridge new];
    XCTestExpectation *exp = [self expectationWithDescription:@""];
    [bridge getToken:^(UADSHeaderBiddingToken * _Nullable token) {
        XCTAssertNotNil(token.value);
        XCTAssertGreaterThan(token.info.count, 1);
        [exp fulfill];
    }];
    [self waitForExpectations:@[exp] timeout:1000.0];
}

- (void)saveConfigurationWithSwiftDeviceInfo:(BOOL)sDin {
    USRVConfiguration *config =  [USRVConfiguration newFromJSON:@{
        @"expo": @{@"s_din": @{ @"value": @(sDin)}},
        @"url": @"webviewurl",
        @"hash": @"hash"
    }];
    
    [config saveToDisk];
}

@end
