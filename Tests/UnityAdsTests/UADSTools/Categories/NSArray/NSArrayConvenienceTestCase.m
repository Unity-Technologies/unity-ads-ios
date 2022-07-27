#import "NSArray+Convenience.h"
#import "NSArray+SafeOperations.h"
#import <XCTest/XCTest.h>

@interface NSArrayConvenienceTestCase : XCTestCase

@end

@implementation NSArrayConvenienceTestCase


- (void)test_removing_first_removes_the_last_element {
    NSArray *filtered = [self.sut uads_removingFirstWhere:^bool (NSNumber *_Nonnull obj) {
        return [obj isEqual: @(4)];
    }];
    NSArray<NSNumber *> *expected = @[@(1), @(2), @(1), @(2), @(3), @(1), @(3), @(5)];

    XCTAssertEqualObjects(expected, filtered);
}

- (void)test_removing_first_removes_the_first_element {
    NSArray *filtered = [self.sut uads_removingFirstWhere:^bool (NSNumber *_Nonnull obj) {
        return [obj isEqual: @(1)];
    }];
    NSArray<NSNumber *> *expected = @[@(2), @(1), @(2), @(3), @(1), @(3), @(5), @(4)];

    XCTAssertEqualObjects(expected, filtered);
}

- (void)test_removing_first_removes_the_element_in_the_middle_of_the_array {
    NSArray *filtered = [self.sut uads_removingFirstWhere:^bool (NSNumber *_Nonnull obj) {
        return [obj isEqual: @(3)];
    }];
    NSArray<NSNumber *> *expected = @[@(1), @(2), @(1), @(2), @(1), @(3), @(5), @(4)];

    XCTAssertEqualObjects(expected, filtered);
}

- (void)test_removes_first_n_elements_n_smaller_then_count {
    NSArray *result = [self.sut uads_removingFirstElements: 3];
    NSArray<NSNumber *> *expected = @[@(2), @(3), @(1), @(3), @(5), @(4)];

    XCTAssertEqualObjects(expected, result);
}

- (void)test_removes_first_n_elements_n_greater_then_count {
    NSArray *initial = self.sut;
    NSArray *result = [initial uads_removingFirstElements: initial.count + 1];

    XCTAssertEqualObjects(result, @[]);
}

- (void)test_removes_first_n_elements_n_equal_count {
    NSArray *initial = self.sut;
    NSArray *result = [initial uads_removingFirstElements: initial.count];

    XCTAssertEqualObjects(result, @[]);
}

- (NSArray<NSNumber *> *)sut {
    return @[@(1), @(2), @(1), @(2), @(3), @(1), @(3), @(5), @(4)];
}

@end
