#import <XCTest/XCTest.h>
#import "UADSTimer.h"
#import "NSDate+Mock.h"
#import "XCTestCase+Convenience.h"

@interface UADSTimerTests : XCTestCase
@property (nonatomic, strong) UADSTimer *timer;
@end

@implementation UADSTimerTests

- (void)setUp {
    [NSDate setMockDate: NO];

    _timer = [UADSTimer new];
}

- (void)tearDown {
    [NSDate setMockDate: YES];
}

- (void)test_timer_called_only_four_times_with_correct_intervals {
    NSArray *intervals = @[@(0.1), @(0.15), @(0), @(0.2)];
    XCTestExpectation *exp = [self expectationWithDescription: @"timer_called_times_array"];

    exp.expectedFulfillmentCount = intervals.count;
    __block NSTimeInterval startTime = [NSDate currentTimeInterval];

    [_timer scheduleWithTimeIntervals: intervals
                                block:^(NSInteger index) {
                                    NSTimeInterval currentTime =  [NSDate currentTimeInterval];
                                    XCTAssertEqualWithAccuracy(currentTime - startTime, [intervals[index] doubleValue], 0.05);
                                    startTime = currentTime;
                                    [exp fulfill];
                                }];

    [self waitForExpectations: @[exp]
                      timeout: 1.0];
}

- (void)test_timer_called_with_equal_intervals {
    NSInteger repeatCount = 5;
    NSTimeInterval ti = 0.1;
    XCTestExpectation *exp = [self expectationWithDescription: @"timer_called_times_intervals"];

    exp.expectedFulfillmentCount = repeatCount;
    __block NSTimeInterval startTime = [NSDate currentTimeInterval];

    [_timer scheduleWithTimeInterval: ti
                         repeatCount: repeatCount
                               block:^(NSInteger index) {
                                   NSTimeInterval currentTime =  [NSDate currentTimeInterval];
                                   XCTAssertEqualWithAccuracy(currentTime - startTime, ti, 0.05);
                                   startTime = currentTime;
                                   [exp fulfill];
                               }];

    [self waitForExpectations: @[exp]
                      timeout: 1.0];
}

- (void)test_block_not_called_when_intervals_empty {
    XCTestExpectation *exp = [self expectationWithDescription: @"timer_not_called"];

    [exp setInverted: true];

    [_timer scheduleWithTimeIntervals: @[]
                                block:^(NSInteger index) {
                                    [exp fulfill];
                                }];

    [self waitForExpectations: @[exp]
                      timeout: 1.0];
}

- (void)test_block_not_called_after_invalidate {
    NSInteger repeatCount = 5;
    NSInteger calledCount = 2;
    NSTimeInterval ti = 1;
    XCTestExpectation *exp = [self expectationWithDescription: @"timer_called_times_invalidated"];

    exp.expectedFulfillmentCount = calledCount;
    __block NSTimeInterval startTime = [NSDate currentTimeInterval];

    [_timer scheduleWithTimeInterval: ti
                         repeatCount: repeatCount
                               block:^(NSInteger index) {
                                   NSTimeInterval currentTime =  [NSDate currentTimeInterval];
                                   XCTAssertEqualWithAccuracy(currentTime - startTime, ti, 0.3);
                                   startTime = currentTime;
                                   [exp fulfill];
                               }];

    [self waitForTimeInterval: calledCount * ti + 0.5];
    [_timer invalidate];
    [self waitForExpectations: @[exp]
                      timeout: 5.0];
}

- (void)test_second_schedule_restarts_timer {
    NSInteger repeatCount = 5;
    NSTimeInterval ti = 0.1;
    XCTestExpectation *exp = [self expectationWithDescription: @"timer_called_times_twice"];

    exp.expectedFulfillmentCount = repeatCount * 2;

    [_timer scheduleWithTimeInterval: ti
                         repeatCount: repeatCount
                               block:^(NSInteger index) {
                                   [exp fulfill];
                               }];
    [self waitForTimeInterval: 1.0];
    [_timer scheduleWithTimeInterval: ti
                         repeatCount: repeatCount
                               block:^(NSInteger index) {
                                   [exp fulfill];
                               }];
    [self waitForExpectations: @[exp]
                      timeout: 5.0];
}

- (void)test_after_pause_timer_fires_no_callbacks {
    NSInteger repeatCount = 5;
    NSTimeInterval ti = 0.5;
    XCTestExpectation *exp = [self expectationWithDescription: @"timer_called_two_times_before_pause"];

    exp.expectedFulfillmentCount = 2;
    __block NSTimeInterval startTime = [NSDate currentTimeInterval];

    [_timer scheduleWithTimeInterval: ti
                         repeatCount: repeatCount
                               block:^(NSInteger index) {
                                   NSTimeInterval currentTime =  [NSDate currentTimeInterval];
                                   XCTAssertEqualWithAccuracy(currentTime - startTime, ti, 0.05);
                                   startTime = currentTime;
                                   [exp fulfill];
                               }];

    [self waitForTimeInterval: 1];
    [_timer pause];
    [self waitForTimeInterval: 1];

    [self waitForExpectations: @[exp]
                      timeout: 3.0];
}

- (void)test_resumes_after_pause {
    NSInteger repeatCount = 5;
    NSInteger pauseIndex = 2;
    NSTimeInterval ti = 0.5;
    NSTimeInterval firstWait = pauseIndex * ti;
    NSTimeInterval secondWait = 3 * ti;
    XCTestExpectation *exp = [self expectationWithDescription: @"timer_resumes_after_pause"];

    exp.expectedFulfillmentCount = repeatCount;
    __block NSTimeInterval startTime = [NSDate currentTimeInterval];

    [_timer scheduleWithTimeInterval: ti
                         repeatCount: repeatCount
                               block:^(NSInteger index) {
                                   NSTimeInterval currentTime =  [NSDate currentTimeInterval];
                                   NSTimeInterval diff = index == pauseIndex ? secondWait + ti : ti;
                                   XCTAssertEqualWithAccuracy(currentTime - startTime, diff, 0.05);

                                   startTime = currentTime;
                                   [exp fulfill];
                               }];

    [self waitForTimeInterval: firstWait];
    [_timer pause];
    [self waitForTimeInterval: secondWait];
    [_timer resume];

    [self waitForExpectations: @[exp]
                      timeout: ti * repeatCount + 1.0];
}

@end
