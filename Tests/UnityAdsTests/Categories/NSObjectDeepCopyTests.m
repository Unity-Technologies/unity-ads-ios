#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface NSObjectDeepCopyTests : XCTestCase
@end

@implementation NSObjectDeepCopyTests


- (void)testDeepCopyDictionary {
    NSDictionary *innerDict = @{ @"1.1": @"one", @"1.2": @{ @"2": @"two" } };
    NSMutableDictionary *original = [@{ @"1": innerDict } mutableCopy];
    NSDictionary *deepCopy = [original deepCopy];

    XCTAssertEqualObjects(original, deepCopy);

    original[@"1"] = @{ @"2": @"new" };

    XCTAssertNotEqualObjects(original, deepCopy);
    XCTAssertEqualObjects(deepCopy[@"1"], innerDict);
}

- (void)testDeepCopyArray {
    NSArray *innerArray = @[@"0", @"1"];
    NSMutableArray *original = [@[innerArray, @[@"2"], @[@"3"]] mutableCopy];
    NSArray *deepCopy = [original deepCopy];

    XCTAssertEqualObjects(original, deepCopy);

    original[0] = @[@"4"];

    XCTAssertNotEqualObjects(original, deepCopy);
    XCTAssertEqualObjects(deepCopy[0], innerArray);
}

@end
