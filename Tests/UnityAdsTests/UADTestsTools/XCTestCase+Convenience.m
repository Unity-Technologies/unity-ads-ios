
#import "XCTestCase+Convenience.h"
#import "XCTestAssert+Fail.h"
#import "UADSTools.h"
#import "UnityAds+Testability.h"
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

- (void)asyncExecuteTimes: (int)count block: (void (^)(XCTestExpectation *expectation, int index))block {
    XCTestExpectation *expectation = [self expectationWithDescription: @"test"];

    expectation.expectedFulfillmentCount = count;

    for (int i = 0; i < count; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            block(expectation, i);
        });
    }

    [self waitForExpectations: @[expectation]
                      timeout: 30];
}

- (void)runBlockAsync: (int)count block: (UADSVoidClosure)closureToPerform {
    for (int i = 0; i < count; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            closureToPerform();
        });
    }
}

- (void)postDidBecomeActive {
    [[NSNotificationCenter defaultCenter] postNotificationName: UIApplicationDidBecomeActiveNotification
                                                        object: nil];
}

- (void)postDidEnterBackground {
    [[NSNotificationCenter defaultCenter] postNotificationName: UIApplicationDidEnterBackgroundNotification
                                                        object: nil];
}

- (void)resetUnityAds {
    [UnityAds resetForTest];
}

@end
