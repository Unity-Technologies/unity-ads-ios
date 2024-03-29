#import "GADRequestBridgeV85.h"
#import "GADRequestBridge.h"
#import <XCTest/XCTest.h>

@interface GADRequestBridgeTest : XCTestCase

@end

@implementation GADRequestBridgeTest

- (void)test_request_exists {
    XCTAssertTrue([GADRequestBridgeV85 exists] || [GADRequestBridge exists]);
}

- (void)test_creates_non_null_request {
    XCTAssertNotNil([GADRequestBridge getNewRequest]);
}

@end
