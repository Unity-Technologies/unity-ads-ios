#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface WebRequestQueueTests : XCTestCase
@end

@implementation WebRequestQueueTests

- (void)setUp {
    [super setUp];
    [USRVWebRequestQueue start];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testBasicGetRequest {
    __block NSString *targetUrl = [TestUtilities getTestServerAddress];
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    [USRVWebRequestQueue requestUrl:targetUrl type:@"GET" headers:NULL body:NULL completeBlock:^(NSString *url, NSError *error, NSString *response, long responseCode, NSDictionary<NSString *,NSString *> *headers) {
        XCTAssertEqual(targetUrl, url, "Returned url and requested url should be the same");
        [expectation fulfill];
    } connectTimeout:30000];
    
    __block BOOL success = true;
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            success = false;
            XCTAssertTrue(success, "Did not complete");
        }
    }];
    
    
}

- (void)testMultipleGetRequests {
    __block NSString *targetUrl = [TestUtilities getTestServerAddress];
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    NSMutableArray *completions = [[NSMutableArray alloc] init];

    [USRVWebRequestQueue requestUrl:targetUrl type:@"GET" headers:NULL body:NULL completeBlock:^(NSString *url, NSError *error, NSString *response, long responseCode, NSDictionary<NSString *,NSString *> *headers) {
        [completions addObject:[NSNumber numberWithInt:1]];
        XCTAssertEqual(targetUrl, url, "Returned url and requested url should be the same");
    } connectTimeout:30000];
    
    [USRVWebRequestQueue requestUrl:targetUrl type:@"GET" headers:NULL body:NULL completeBlock:^(NSString *url, NSError *error, NSString *response, long responseCode, NSDictionary<NSString *,NSString *> *headers) {
        [completions addObject:[NSNumber numberWithInt:2]];
        XCTAssertEqual(targetUrl, url, "Returned url and requested url should be the same");
    } connectTimeout:30000];

    [USRVWebRequestQueue requestUrl:targetUrl type:@"GET" headers:NULL body:NULL completeBlock:^(NSString *url, NSError *error, NSString *response, long responseCode, NSDictionary<NSString *,NSString *> *headers) {
        [completions addObject:[NSNumber numberWithInt:3]];
        XCTAssertEqual(targetUrl, url, "Returned url and requested url should be the same");
    } connectTimeout:30000];

    [USRVWebRequestQueue requestUrl:targetUrl type:@"GET" headers:NULL body:NULL completeBlock:^(NSString *url, NSError *error, NSString *response, long responseCode, NSDictionary<NSString *,NSString *> *headers) {
        [completions addObject:[NSNumber numberWithInt:4]];
        XCTAssertEqual(targetUrl, url, "Returned url and requested url should be the same");
    } connectTimeout:30000];

    [USRVWebRequestQueue requestUrl:targetUrl type:@"GET" headers:NULL body:NULL completeBlock:^(NSString *url, NSError *error, NSString *response, long responseCode, NSDictionary<NSString *,NSString *> *headers) {
        [completions addObject:[NSNumber numberWithInt:5]];
        XCTAssertEqual(targetUrl, url, "Returned url and requested url should be the same");
        [expectation fulfill];
    } connectTimeout:30000];
    
    __block BOOL success = true;
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            success = false;
            XCTAssertTrue(success, "Did not complete");
        }
    }];
    
    NSNumber *previousValue = [NSNumber numberWithInt:0];
    for (NSNumber *value in completions) {
        XCTAssertTrue(previousValue < value, "Previous completion value should always be smaller than the next one");
    }
}

@end
