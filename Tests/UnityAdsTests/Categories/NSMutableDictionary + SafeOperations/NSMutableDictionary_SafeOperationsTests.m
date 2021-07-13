#import <XCTest/XCTest.h>
#import "NSMutableDictionary + SafeOperations.h"

@interface NSMutableDictionary_SafeOperationsTests : XCTestCase

@end

@implementation NSMutableDictionary_SafeOperationsTests


- (void)test_dictionary_doesnt_set_nil_object_nor_set_the_key {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    NSString *testKey = @"Test";

    [dictionary uads_setValueIfNotNil: nil
                               forKey: testKey];
    XCTAssertEqual(dictionary.allKeys.count, 0);
}

- (void)test_dictionary_set_nonnul_object {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    NSString *testKey = @"Test";
    NSNumber *testValue = @3;

    [dictionary uads_setValueIfNotNil: testValue
                               forKey: testKey];
    XCTAssertEqual(dictionary.allKeys.count, 1);
    XCTAssertEqualObjects(dictionary[testKey], testValue);
}

@end
