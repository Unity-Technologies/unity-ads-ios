#import <XCTest/XCTest.h>
#import "UADSCurrentTimestampBase.h"
#import "NSDate+Mock.h"
@interface UADSCurrentTimestampTests : XCTestCase

@end

@implementation UADSCurrentTimestampTests

- (void)test_current_timestamp_does_not_depend_on_date_change {
    UADSCurrentTimestampBase *sut = [UADSCurrentTimestampBase new];

    [NSDate setMockDate: false];

    NSTimeInterval currentTime = sut.currentTimestamp;
    NSTimeInterval epochTime = sut.epochSeconds;

    [NSDate setMockDate: true];

    NSTimeInterval afterChangeTime = sut.currentTimestamp;
    NSTimeInterval afterEpochTime = sut.epochSeconds;

    XCTAssertEqualWithAccuracy(currentTime, afterChangeTime, 0.01);
    XCTAssertNotEqualWithAccuracy(epochTime, afterEpochTime, 0.01);

    [NSDate setMockDate: false];
}

@end
