#import <XCTest/XCTest.h>
#import "NSDictionary+Filter.h"

@interface NSDictionaryFilter : XCTestCase

@end

@implementation NSDictionaryFilter

- (void)test_filters_out_keys {
    NSDictionary *filtered = [self.defaultMockData uads_filter:^BOOL (id _Nonnull key, id _Nonnull obj) {
        return [key isEqualToString: @"key3"];
    }];

    XCTAssertEqualObjects(filtered, @{ @"key3": @"value3" });
}

- (void)test_filters_out_values {
    NSDictionary *filtered = [self.defaultMockData uads_filter:^BOOL (id _Nonnull key, id _Nonnull obj) {
        return [obj isEqual: @(true)];
    }];

    XCTAssertEqualObjects(filtered, @{ @"key1": @(true) });
}

- (NSDictionary *)defaultMockData {
    return @{
        @"key1": @(true),
        @"key2": @(false),
        @"key3": @"value3"
    };
}

@end
