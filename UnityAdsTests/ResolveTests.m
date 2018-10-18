#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface ResolveTests : XCTestCase
@end

@implementation ResolveTests

- (void)setUp {
    [super setUp];
    [USRVWebRequestQueue start];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testBasicResolve {
    XCTestExpectation *expectation = [self expectationWithDescription:@"resolveExpectation"];
    __block NSString *returnError;
    __block NSString *returnErrorMessage;
    __block NSString *returnAddress;
    __block NSString *returnHost;
    
    UnityServicesResolveRequestCompletion completeBlock = ^(NSString *host, NSString *address, NSString *error, NSString *errorMessage) {
        returnHost = host;
        returnAddress = address;
        returnError = error;
        returnErrorMessage = errorMessage;
        
        [expectation fulfill];
    };
    
    BOOL success = [USRVWebRequestQueue resolve:@"google-public-dns-a.google.com" completeBlock:completeBlock];
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
    }];
    
    XCTAssertTrue(success, "Calling WebRequestQueue.resolve should have succeeded");
    XCTAssertNil(returnError, "There shouldn't be an error");
    XCTAssertNil(returnErrorMessage, "There shouldn't be an error message");
    XCTAssertEqualObjects([NSString stringWithFormat:@"google-public-dns-a.google.com"], returnHost, "original and returning host should be the same");
    XCTAssertNotNil(returnAddress, "Return address should not be NULL");
    XCTAssertEqualObjects(returnAddress, [NSString stringWithFormat:@"8.8.8.8"], "google-public-dns-a.google.com should'be resolved to 8.8.8.8");
}

@end
