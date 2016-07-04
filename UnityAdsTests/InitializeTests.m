#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface InitializeTests : XCTestCase
@end

@implementation InitializeTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testInitializeStateReset {
    UADSWebViewApp *webViewApp = [[UADSWebViewApp alloc] init];
    UIWebView *webView = [[UIWebView alloc] init];
    
    [UADSWebViewApp setCurrentApp:webViewApp];
    [[UADSWebViewApp getCurrentApp] setWebView:webView];
    [[UADSWebViewApp getCurrentApp] setWebAppLoaded:true];
    [UADSSdkProperties setInitialized:true];
    
    UADSConfiguration *config = [[UADSConfiguration alloc] init];
    NSArray *classList = @[@"UADSApiSdk"];
    [config setWebAppApiClassList:classList];
    UADSInitializeStateReset *resetState = [[UADSInitializeStateReset alloc] initWithConfiguration:config];
    
    __block id nextState = NULL;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        nextState = [resetState execute];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
    }];

    XCTAssertFalse([UADSSdkProperties isInitialized], @"SDK is initialized after SDK was reset");
    XCTAssertFalse([[UADSWebViewApp getCurrentApp] webAppLoaded], @"WebApp is loaded after SDK was reset");
    XCTAssertTrue([nextState isKindOfClass:[UADSInitializeStateConfig class]], @"Next state should be 'Config'");
}

- (void)testInitializeStateConfig {
    UADSConfiguration *config = [[UADSConfiguration alloc] init];
    [config setConfigUrl:[UADSSdkProperties getConfigUrl]];
    UADSInitializeStateConfig *initializeState = [[UADSInitializeStateConfig alloc] initWithConfiguration:config];
    
    __block id nextState = NULL;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        nextState = [initializeState execute];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
    }];

    XCTAssertTrue([nextState isKindOfClass:[UADSInitializeStateLoadCache class]], @"Next state should be 'Load Cache'");
    XCTAssertNotNil([config webViewUrl], @"WebViewUrl should not be nil");
    XCTAssertNotNil([config webViewHash], @"WebViewHash should not be nil");
}

- (void)testInitializeStateLoadCache {
    UADSConfiguration *config = [[UADSConfiguration alloc] init];
    [config setConfigUrl:[UADSSdkProperties getConfigUrl]];
    NSArray *classList = @[@"UADSApiSdk"];
    [config setWebAppApiClassList:classList];
    [config setWebViewUrl:[UADSSdkProperties getConfigUrl]];
    [config setWebViewHash:@"12345"];

    UADSInitializeStateLoadCache *loadCacheState = [[UADSInitializeStateLoadCache alloc] initWithConfiguration:config];
    
    __block id nextState = NULL;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        nextState = [loadCacheState execute];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
    }];

    XCTAssertTrue([nextState isKindOfClass:[UADSInitializeStateLoadWeb class]], @"Next state should be 'Load Web' because we tried to load from cache with bogus config");
    XCTAssertNotNil([config webViewUrl], @"WebViewUrl should not be nil");
    XCTAssertNotNil([config webViewHash], @"WebViewHash should not be nil");
}

- (void)testInitializeStateLoadWeb {
    UADSConfiguration *config = [[UADSConfiguration alloc] init];
    [config setConfigUrl:[UADSSdkProperties getConfigUrl]];
    
    __block id nextState = NULL;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [config makeRequest];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
    }];

    UADSInitializeStateLoadWeb *loadWebState = [[UADSInitializeStateLoadWeb alloc] initWithConfiguration:config];
    
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"expectation2"];
    dispatch_async(queue, ^{
        nextState = [loadWebState execute];
        [expectation2 fulfill];
    });
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
    }];

    XCTAssertTrue([nextState isKindOfClass:[UADSInitializeStateCreate class]], @"Next state should be 'Create'");
    XCTAssertNotNil([config webViewUrl], @"WebViewUrl should not be nil");
    XCTAssertNotNil([config webViewHash], @"WebViewHash should not be nil");
}

- (void)testInitializeStateCreate {
    NSString *url = @"https://www.example.com/handlecallback.html";
    NSString *data = @"<script>var nativebridge = new Object(); nativebridge.handleCallback = new function() {	webviewbridge.handleInvocation(\"[['com.unity3d.ads.api.Sdk','initComplete', [], 'CALLBACK_01']]\"); }</script>";
    NSString *hash = [data sha256];
    
    UADSConfiguration *config = [[UADSConfiguration alloc] init];
    NSArray *classList = @[@"UADSApiSdk"];
    [config setWebAppApiClassList:classList];
    [config setWebViewUrl:url];
    [config setWebViewHash:hash];
    [config setWebViewData:data];
    
    __block id nextState = NULL;
    
    UADSInitializeStateCreate *createState = [[UADSInitializeStateCreate alloc] initWithConfiguration:config webViewData:data];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        nextState = [createState execute];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
    }];
    
    XCTAssertTrue([nextState isKindOfClass:[UADSInitializeStateComplete class]], @"Next state should be 'Complete'");
}

- (void)testInitializeStateComplete {
    __block id nextState = NULL;
    
    UADSConfiguration *config = [[UADSConfiguration alloc] init];
    NSArray *classList = @[@"UADSApiSdk"];
    [config setWebAppApiClassList:classList];
    UADSInitializeStateComplete *completeState = [[UADSInitializeStateComplete alloc] initWithConfiguration:config];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        nextState = [completeState execute];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
    }];
    
    XCTAssertNil(nextState, @"Next state should be NULL");
}

- (void)testInitializeStateRetry {
    UADSConfiguration *config = [[UADSConfiguration alloc] init];
    NSArray *classList = @[@"UADSApiSdk"];
    [config setWebAppApiClassList:classList];
    UADSInitializeStateComplete *completeState = [[UADSInitializeStateComplete alloc] initWithConfiguration:config];
    UADSInitializeStateRetry *retryState = [[UADSInitializeStateRetry alloc] initWithConfiguration:config retryState:completeState retryDelay:5];

    __block id nextState = NULL;

    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        nextState = [retryState execute];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
    }];
    
    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime diff = endTime - startTime;
    
    NSLog(@"DIFF: %f", diff);
    XCTAssertTrue([nextState isKindOfClass:[UADSInitializeStateComplete class]], @"Next state should be 'Complete'");
    XCTAssertFalse(diff <= 4, @"Difference is less than four seconds (should be 5 secs)");
    XCTAssertFalse(diff >= 6, @"Difference is more than six seconds (should be 5 secs)");
}

@end