#import <XCTest/XCTest.h>
#import "USRVConfiguration.h"
#import "USRVSdkProperties.h"

@interface ConfigurationTests : XCTestCase
@end

@implementation ConfigurationTests

- (void)setUp {
    [super setUp];

}

- (void)tearDown {
    [super tearDown];
}

- (void)testMakeRequest {
    NSString *configUrl = [USRVSdkProperties getConfigUrl];
    USRVConfiguration *configuration = [[USRVConfiguration alloc] initWithConfigUrl:configUrl];

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
    XCTAssertNotNil([configuration webViewUrl], @"Config url : %@ : Web view url shouldn't be nil", configUrl);
    XCTAssertNil([configuration error], "Error should be nil");
}

- (void)testMakeRequestNotValidUrl {
    USRVConfiguration *configuration = [[USRVConfiguration alloc] initWithConfigUrl:@"https://cdn.unityadsssss.unity3d.com/webview/master/release/config.json"];

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
