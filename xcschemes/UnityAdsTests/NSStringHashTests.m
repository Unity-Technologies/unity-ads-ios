#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface NSStringHashTests : XCTestCase
@end

@implementation NSStringHashTests

- (void)testSha256 {
    XCTAssertEqualObjects([@"hello" sha256], @"2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824", "SHA256 not what was expected");
    XCTAssertEqualObjects([@"" sha256], @"e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855", "SHA256 not what was expected");
}

@end