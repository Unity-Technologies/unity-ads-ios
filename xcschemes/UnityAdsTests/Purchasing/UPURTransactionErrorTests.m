#import <XCTest/XCTest.h>
#import "UPURTransactionError.h"

@interface UPURTransactionErrorTests : XCTestCase
@end

@implementation UPURTransactionErrorTests

-(void)testNSStringFromUPURTransactionError {
    XCTAssertEqualObjects(@"NOT_SUPPORTED", NSStringFromUPURTransactionError(kUPURTransactionErrorNotSupported));
    XCTAssertEqualObjects(@"ITEM_UNAVAILABLE", NSStringFromUPURTransactionError(kUPURTransactionErrorItemUnavailable));
    XCTAssertEqualObjects(@"USER_CANCELLED", NSStringFromUPURTransactionError(kUPURTransactionErrorUserCancelled));
    XCTAssertEqualObjects(@"NETWORK_ERROR", NSStringFromUPURTransactionError(kUPURTransactionErrorNetworkError));
    XCTAssertEqualObjects(@"SERVER_ERROR", NSStringFromUPURTransactionError(kUPURTransactionErrorServerError));
    XCTAssertEqualObjects(@"UNKNOWN_ERROR", NSStringFromUPURTransactionError(kUPURTransactionErrorUnknownError));
}

@end
