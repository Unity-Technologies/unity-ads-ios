#import <XCTest/XCTest.h>
#import "UPURTransactionErrorDetails+JsonAdditions.h"

@interface UPURTransactionErrorDetailsTests : XCTestCase
@end

@implementation UPURTransactionErrorDetailsTests

-(void)testGetJSONDictionary {
    NSDictionary *expected = @{
            @"transactionError": @"NETWORK_ERROR",
            @"exceptionMessage": @"test exception happened",
            @"store": @"APPLE_APP_STORE",
            @"storeSpecificErrorCode": @"Apple App Store Error Test",
            @"extras": @{
                    @"test": @"testvalue",
                    @"secondTest": @"secondTestValue"
            }
    };
    UPURTransactionErrorDetails *details = [UPURTransactionErrorDetails build:^(UPURTransactionErrorDetailsBuilder *builder) {
        builder.store = kUPURStoreAppleAppStore;
        builder.transactionError = kUPURTransactionErrorNetworkError;
        builder.exceptionMessage = @"test exception happened";
        builder.storeSpecificErrorCode = @"Apple App Store Error Test";
        builder.extras = [NSMutableDictionary dictionaryWithDictionary:@{
                @"test": @"testvalue"
        }];
        [builder putExtra:@"secondTest" value:@"secondTestValue"];
    }];
    NSDictionary *json = [details getJSONDictionary];
    XCTAssertEqualObjects(expected, json);
}

-(void)testGetJSONDictionaryNull {
    NSDictionary *expected = @{
            @"transactionError": @"UNKNOWN_ERROR",
            @"exceptionMessage": [NSNull null],
            @"store": @"NOT_SPECIFIED",
            @"storeSpecificErrorCode": [NSNull null],
            @"extras": [NSNull null]
    };
    UPURTransactionErrorDetails *details = [UPURTransactionErrorDetails build:^(UPURTransactionErrorDetailsBuilder *builder) {
        builder.extras = nil;
    }];
    NSDictionary *json = [details getJSONDictionary];
    XCTAssertEqualObjects(expected, json);
}

@end
