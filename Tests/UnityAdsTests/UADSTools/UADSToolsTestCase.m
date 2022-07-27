#import <XCTest/XCTest.h>
#import "UADSTools.h"
#import "XCTestCase+Convenience.h"
#import "NSDate+Mock.h"

@interface UADSToolsTestCase : XCTestCase

@end

@implementation UADSToolsTestCase

- (void)setUp {
    [NSDate setMockDate: false];
}

- (void)tearDown {
    [NSDate setMockDate: true];
}

- (void)test_performance_measure_async_returns_duration {
    NSTimeInterval delay = 1;

    XCTestExpectation *exp = self.defaultExpectation;
    UADSDurationMeasureClosure blockToMeasure = ^(UADSVoidClosure completion) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            [NSThread sleepForTimeInterval: delay];
            completion();
        });
    };

    UADSDurationClosure resultClosure = ^(CFTimeInterval result) {
        XCTAssertEqualWithAccuracy(result, delay, 0.02);
        [exp fulfill];
    };


    uads_measure_duration_async(blockToMeasure, resultClosure);

    [self waitForExpectations: @[exp]
                      timeout: delay + 1];
}

- (void)test_performance_measure_sync_returns_duration {
    NSTimeInterval delay = 1;
    NSTimeInterval result = uads_measure_duration_sync(^{
        [NSThread sleepForTimeInterval: delay];
    });

    XCTAssertEqualWithAccuracy(result, 1000, 2); // in ms
}

@end
