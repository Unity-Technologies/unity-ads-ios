#import <XCTest/XCTest.h>
#import "NSDictionary+JSONString.h"

@interface NSDictionaryQueryString : XCTestCase

@end

@implementation NSDictionaryQueryString


- (void)test_creates_query_string {
    NSDictionary *data = @{
        @"username": @"user_name",
        @"id": @"unique_ID"
    };

    XCTAssertEqualObjects(data.uads_queryString, @"?id=unique_ID&username=user_name");
}

@end
