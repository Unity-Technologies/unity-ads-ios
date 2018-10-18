#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface WebRequestTests : XCTestCase
@end

@implementation WebRequestTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}


- (void)testBasicGetRequest {
    NSString *url = [TestUtilities getTestServerAddress];
    USRVWebRequest *request = [[USRVWebRequest alloc] initWithUrl:url requestType:@"GET" headers:NULL connectTimeout:30000];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __block NSData *data = [[NSData alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    dispatch_async(queue, ^{
        data = [request makeRequest];
        [expectation fulfill];
    });
    
    __block BOOL success = true;
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            success = false;
            XCTAssertTrue(success, "Did not complete");
        }
    }];
    
    XCTAssertNil(request.error, "Error should be null");
    XCTAssertEqualObjects(request.url, url, "URL's should still be the same");
    XCTAssertNotNil(data, "Data should not be null");
    XCTAssertEqualObjects(@"OK", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], "Data should contain 'OK'");
}

- (void)testBasicPostRequest {
    NSString *url =  [TestUtilities getTestServerAddress];
    USRVWebRequest *request = [[USRVWebRequest alloc] initWithUrl:url requestType:@"POST" headers:NULL connectTimeout:30000];
    [request setBody:@"hello=world"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __block NSData *data = [[NSData alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    dispatch_async(queue, ^{
        data = [request makeRequest];
        [expectation fulfill];
    });
    
    __block BOOL success = true;
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            success = false;
            XCTAssertTrue(success, "Did not complete");
        }
    }];
    
    XCTAssertNil(request.error, "Error should be null");
    XCTAssertEqualObjects(request.url, url, "URL's should still be the same");
    XCTAssertNotNil(data, "Data should not be null");
}

- (void)testEmptyGetUrl {
    NSString *url = @"";
    USRVWebRequest *request = [[USRVWebRequest alloc] initWithUrl:url requestType:@"GET" headers:NULL connectTimeout:30000];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __block NSData *data = [[NSData alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    dispatch_async(queue, ^{
        data = [request makeRequest];
        [expectation fulfill];
    });
    
    __block BOOL success = true;
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            success = false;
            XCTAssertTrue(success, "Did not complete");
        }
    }];
    
    XCTAssertNotNil(request.error, "Error should not be null");
    NSString *message = [request.error.userInfo objectForKey:@"message"];
    XCTAssertTrue([message containsString:@"unsupported URL"], "Error message should contain 'unsupported URL'");
    XCTAssertTrue(data.length == 0, "Data length should be zero");
}

- (void)testEmptyPostUrl {
    NSString *url = @"";
    USRVWebRequest *request = [[USRVWebRequest alloc] initWithUrl:url requestType:@"POST" headers:NULL connectTimeout:30000];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __block NSData *data = [[NSData alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    dispatch_async(queue, ^{
        data = [request makeRequest];
        [expectation fulfill];
    });
    
    __block BOOL success = true;
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            success = false;
            XCTAssertTrue(success, "Did not complete");
        }
    }];
    
    XCTAssertNotNil(request.error, "Error should not be null");
    NSString *message = [request.error.userInfo objectForKey:@"message"];
    XCTAssertTrue([message containsString:@"unsupported URL"], "Error message should contain 'unsupported URL'");
    XCTAssertTrue(data.length == 0, "Data length should be zero");
}

- (void)testNullGetUrl {
    NSString *url = NULL;
    USRVWebRequest *request = [[USRVWebRequest alloc] initWithUrl:url requestType:@"GET" headers:NULL connectTimeout:30000];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __block NSData *data = [[NSData alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    dispatch_async(queue, ^{
        data = [request makeRequest];
        [expectation fulfill];
    });
    
    __block BOOL success = true;
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            success = false;
            XCTAssertTrue(success, "Did not complete");
        }
    }];
    
    XCTAssertNotNil(request.error, "Error should not be null");
    NSString *message = [request.error.userInfo objectForKey:@"message"];
    XCTAssertTrue([message containsString:@"unsupported URL"], "Error message should contain 'unsupported URL'");
    XCTAssertTrue(data.length == 0, "Data length should be zero");
}

- (void)testNullPostUrl {
    NSString *url = NULL;
    USRVWebRequest *request = [[USRVWebRequest alloc] initWithUrl:url requestType:@"POST" headers:NULL connectTimeout:30000];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __block NSData *data = [[NSData alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    dispatch_async(queue, ^{
        data = [request makeRequest];
        [expectation fulfill];
    });
    
    __block BOOL success = true;
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            success = false;
            XCTAssertTrue(success, "Did not complete");
        }
    }];
    
    XCTAssertNotNil(request.error, "Error should not be null");
    NSString *message = [request.error.userInfo objectForKey:@"message"];
    XCTAssertTrue([message containsString:@"unsupported URL"], "Error message should contain 'unsupported URL'");
    XCTAssertTrue(data.length == 0, "Data length should be zero");
}

- (void)testInvalidGetUrl {
    NSString *url = @"https://www.gougle.fi/";
    USRVWebRequest *request = [[USRVWebRequest alloc] initWithUrl:url requestType:@"GET" headers:NULL connectTimeout:30000];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __block NSData *data = [[NSData alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    dispatch_async(queue, ^{
        data = [request makeRequest];
        [expectation fulfill];
    });
    
    __block BOOL success = true;
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            success = false;
            XCTAssertTrue(success, "Did not complete");
        }
    }];
    
    XCTAssertNotNil(request.error, "Error should not be null");
    NSString *message = [request.error.userInfo objectForKey:@"message"];
    XCTAssertTrue([message containsString:@"A server with the specified hostname could not be found."], "Error message should contain 'A server with the specified hostname could not be found.'");
    XCTAssertTrue(data.length == 0, "Data length should be zero");
}

- (void)testInvalidPostUrl {
    NSString *url = @"https://www.gougle.fi/";
    USRVWebRequest *request = [[USRVWebRequest alloc] initWithUrl:url requestType:@"POST" headers:NULL connectTimeout:30000];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    __block NSData *data = [[NSData alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    dispatch_async(queue, ^{
        data = [request makeRequest];
        [expectation fulfill];
    });
    
    __block BOOL success = true;
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            success = false;
            XCTAssertTrue(success, "Did not complete");
        }
    }];
    
    XCTAssertNotNil(request.error, "Error should not be null");
    NSString *message = [request.error.userInfo objectForKey:@"message"];
    XCTAssertTrue([message containsString:@"A server with the specified hostname could not be found."], "Error message should contain 'A server with the specified hostname could not be found.'");
    XCTAssertTrue(data.length == 0, "Data length should be zero");
    
}

- (void)testResolveHost {
    USRVResolve *resolve = [[USRVResolve alloc] initWithHostName:@"google-public-dns-a.google.com"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_async(queue, ^{
        [resolve resolve];
        [expectation fulfill];
    });
    
    __block BOOL success = true;
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            success = false;
            XCTAssertTrue(success, "Did not complete");
        }
    }];

    XCTAssertNil(resolve.error, "Error should be null");
    XCTAssertEqualObjects(@"google-public-dns-a.google.com", resolve.hostName, @"Hosname should still be the same");
    XCTAssertEqualObjects(@"8.8.8.8", resolve.address, @"Address should've resolved to 8.8.8.8");
}

@end
