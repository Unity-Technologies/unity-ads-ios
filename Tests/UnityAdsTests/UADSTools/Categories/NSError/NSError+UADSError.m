#import <XCTest/XCTest.h>
#import "NSError+UADSError.h"
@interface NSError_UADSError : XCTestCase

@end

@implementation NSError_UADSError

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)test_extract_function_returns_string {
    NSString *expectedError = @"TEST_ERROR";

    XCTAssertEqualObjects(expectedError, uads_extractErrorString(expectedError));
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock: ^{
        // Put the code you want to measure the time of here.
    }];
}

@end
