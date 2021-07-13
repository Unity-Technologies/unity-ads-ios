#import <XCTest/XCTest.h>
#import "NSDate + NSNumber.h"

@interface NSDate_NSNumberTests : XCTestCase

@end

@implementation NSDate_NSNumberTests

- (void)test_returns_timestamp_as_ns_number {
    XCTAssertTrue([[NSDate new].uads_timeIntervalSince1970 isKindOfClass: [NSNumber class]]);
}

- (void)test_returns_correct_double_value {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: 100.100];
    NSNumber *timestamp = date.uads_timeIntervalSince1970;

    XCTAssertEqual(date.timeIntervalSince1970, timestamp.doubleValue);
}

@end
