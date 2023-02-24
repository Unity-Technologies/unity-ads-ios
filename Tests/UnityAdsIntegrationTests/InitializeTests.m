#import <XCTest/XCTest.h>
#import "USRVConfiguration.h"
#import "USRVSdkProperties.h"
#import "USRVInitialize.h"
#import "USRVInitializeStateConfig.h"
#import "USRVInitializeStateLoadCache.h"
#import "USRVInitializeStateLoadWeb.h"
#import "USRVInitializeStateCreate.h"
#import "XCTestCase+Convenience.h"

@interface InitializeTests : XCTestCase
@end

@implementation InitializeTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInitializeStateConfig {
    USRVConfiguration *config = [[USRVConfiguration alloc] initWithConfigUrl: [USRVSdkProperties getConfigUrl]];

    USRVInitializeStateConfig *initializeState = [[USRVInitializeStateConfig alloc] initWithConfiguration: config retries:0 retryDelay:0];

    __block id nextState = NULL;

    XCTestExpectation *expectation = [self expectationWithDescription: @"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue, ^{
        nextState = [initializeState execute];
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout: 60
                                 handler: ^(NSError *_Nullable error) {
                                 }];

    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateLoadCache class]], @"Next state should be 'Load Cache'");
    XCTAssertNotNil([initializeState.configuration webViewUrl], @"WebViewUrl should not be nil");
    XCTAssertNotNil([initializeState.configuration webViewHash], @"WebViewHash should not be nil");
} /* testInitializeStateConfig */

- (void)testInitializeStateLoadWeb {
    USRVConfiguration *config = [[USRVConfiguration alloc] initWithConfigUrl: [USRVSdkProperties getConfigUrl]];

    __block id nextState = NULL;

    XCTestExpectation *expectation = [self expectationWithDescription: @"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue, ^{
        [config makeRequest];
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout: 60
                                 handler: ^(NSError *_Nullable error) {
                                 }];

    USRVInitializeStateLoadWeb *loadWebState = [[USRVInitializeStateLoadWeb alloc] initWithConfiguration: config];

    XCTestExpectation *expectation2 = [self expectationWithDescription: @"expectation2"];

    dispatch_async(queue, ^{
        nextState = [loadWebState execute];
        [expectation2 fulfill];
    });

    [self waitForExpectationsWithTimeout: 60
                                 handler: ^(NSError *_Nullable error) {
                                 }];

    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateCreate class]], @"Next state should be 'Create'");
    XCTAssertNotNil([config webViewUrl], @"WebViewUrl should not be nil");
    XCTAssertNotNil([config webViewHash], @"WebViewHash should not be nil");
} /* testInitializeStateLoadWeb */

@end
