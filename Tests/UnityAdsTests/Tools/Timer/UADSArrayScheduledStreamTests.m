#import <XCTest/XCTest.h>
#import "XCTestCase+Convenience.h"
#import "UADSArrayScheduledStream.h"
#import "UADSRepeatableTimerMock.h"

@interface UADSArrayScheduledStreamTests : XCTestCase
@property (nonatomic, strong) UADSRepeatableTimerMock *mock;
@property (nonatomic, strong) NSArray *testArray;
@end

@implementation UADSArrayScheduledStreamTests

- (void)setUp {
    self.mock = [UADSRepeatableTimerMock new];
    self.testArray = @[@"1", @"2", @"3"];
}

- (void)test_schedules_timer_with_correct_parameters {
    NSTimeInterval totalTime = 6;

    [self sutWithTime: totalTime
                block:^(id _Nonnull item, NSInteger index) {}];

    XCTAssertEqual(_mock.count, _testArray.count);
    XCTAssertEqual(_mock.totalTime, totalTime / _testArray.count);
}

- (void)test_calls_block_when_timer_fires {
    XCTestExpectation *exp = [self defaultExpectation];

    exp.expectedFulfillmentCount = _testArray.count;
    __block NSInteger currentIndex = 0;

    [self sutWithBlock:^(id _Nonnull item, NSInteger index) {
        XCTAssertEqual(self.testArray[currentIndex], item);
        XCTAssertEqual(index, currentIndex);
        currentIndex += 1;
        [exp fulfill];
    }];

    [_mock fire: _testArray.count];

    [self waitForExpectations: @[exp]
                      timeout: 1.0];
}

- (void)test_does_not_call_block_after_invalidated {
    XCTestExpectation *exp = [self defaultExpectation];
    NSInteger callCount = 3;

    exp.expectedFulfillmentCount = callCount;
    __block NSInteger currentIndex = 0;

    UADSArrayScheduledStream *sut = [self sutWithBlock:^(id _Nonnull item, NSInteger index) {
        XCTAssertEqual(self.testArray[currentIndex], item);
        XCTAssertEqual(index, currentIndex);
        currentIndex += 1;
        [exp fulfill];
    }];

    [_mock fire: callCount];
    [sut invalidate];
    [_mock fire: 2];

    [self waitForExpectations: @[exp]
                      timeout: 1.0];

    XCTAssertTrue(_mock.invalidateCalled);
}

- (UADSArrayScheduledStream *)sutWithBlock: (void (^)(id item, NSInteger index))block {
    return [self sutWithTime: 1.0
                       block: block];
}

- (UADSArrayScheduledStream *)sutWithTime: (NSTimeInterval)time block: (void (^)(id item, NSInteger index))block {
    return [UADSArrayScheduledStream scheduledStreamWithArray: _testArray
                                                    totalTime: time
                                                        timer: _mock
                                                        block: block];
}

@end
