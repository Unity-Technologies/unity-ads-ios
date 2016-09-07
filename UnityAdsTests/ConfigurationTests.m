#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface ConfigurationTests : XCTestCase
@end

@implementation ConfigurationTests

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSetWebAppApiClassList {
    UADSConfiguration *confClass = [[UADSConfiguration alloc] init];
    NSArray *classes = @[@"hello", @"world"];
    [confClass setWebAppApiClassList:classes];
    NSArray *tmpClasses = @[@"hello", @"world"];
    
    XCTAssertEqualObjects([confClass webAppApiClassList], tmpClasses, "Contents of webAppApiClassList not what was expected");
}

- (void)testSetWebViewUrl {
    UADSConfiguration *confClass = [[UADSConfiguration alloc] init];
    NSString *url = @"url world";
    [confClass setWebViewUrl:url];
    XCTAssertEqualObjects([confClass webViewUrl], @"url world", "Contents of webViewUrl not what was expected");
}

- (void)testSetWebViewHash {
    UADSConfiguration *confClass = [[UADSConfiguration alloc] init];
    NSString *hash = @"hash world";
    [confClass setWebViewHash:hash];
    XCTAssertEqualObjects([confClass webViewHash], @"hash world", "Contents of webViewHash not what was expected");
}

- (void)testSetWebViewData {
    UADSConfiguration *confClass = [[UADSConfiguration alloc] init];
    NSString *data = @"data world";
    [confClass setWebViewData:data];
    XCTAssertEqualObjects([confClass webViewData], @"data world", "Contents of webViewData not what was expected");
}

- (void)testSetConfigUrl {
    UADSConfiguration *confClass = [[UADSConfiguration alloc] init];
    NSString *confurl = @"confurl world";
    [confClass setConfigUrl:confurl];
    XCTAssertEqualObjects([confClass configUrl], @"confurl world", "Contents of webViewData not what was expected");
}

- (void)testMakeRequest {
    UADSConfiguration *configuration = [[UADSConfiguration alloc] initWithConfigUrl:[UADSSdkProperties getConfigUrl]];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];

    __block BOOL success = true;

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [configuration makeRequest];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        if (error) {
            success = false;
        }
    }];
    
    XCTAssertTrue(success, "Request should have succeeded");
    XCTAssertNotNil([configuration webViewUrl], "Web view url shouldn't be nil");
    XCTAssertNil([configuration error], "Error should be nil");
}

- (void)testMakeRequestNotValidUrl {
    UADSConfiguration *configuration = [[UADSConfiguration alloc] initWithConfigUrl:@"https://cdn.unityadsssss.unity3d.com/webview/master/release/config.json"];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    
    __block BOOL success = true;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [configuration makeRequest];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        if (error) {
            success = false;
        }
    }];
    
    XCTAssertTrue(success, "Request should have succeeded");
    XCTAssertNotNil([configuration error], "Error should not be null");
    XCTAssertEqualObjects(@"ERROR_REQUESTING_CONFIG", [configuration error], "Error message should be equal to 'ERROR_REQUESTING_CONFIG'");
}

@end