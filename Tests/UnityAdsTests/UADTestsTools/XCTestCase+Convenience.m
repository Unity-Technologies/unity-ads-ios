
#import "XCTestCase+Convenience.h"
#import "XCTestAssert+Fail.h"
@implementation XCTestCase (Category)
- (XCTestExpectation *)defaultExpectation {
    return [self expectationWithDescription: NSStringFromClass([self class])];
}

- (ErrorCompletion)failIfError {
    return ^(id<UADSError> _Nonnull error) {
               XCTFail(@"Should not fall into error flow");
    };
}

- (void)waitForTimeInterval: (NSTimeInterval)waitTime {
    XCTestExpectation *expectation = [self expectationWithDescription: @"wait.expectations"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, waitTime * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectations: @[expectation]
                      timeout: waitTime + 2];
}

@end
