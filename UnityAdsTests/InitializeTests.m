#import <XCTest/XCTest.h>
#import <WebKit/WebKit.h>
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
    USRVWebViewApp *webViewApp = [[USRVWebViewApp alloc] init];
    WKWebView *webView = [[WKWebView alloc] init];
    
    [USRVWebViewApp setCurrentApp:webViewApp];
    [[USRVWebViewApp getCurrentApp] setWebView:webView];
    [[USRVWebViewApp getCurrentApp] setWebAppLoaded:true];
    [USRVSdkProperties setInitialized:true];
    
    USRVConfiguration *config = [[USRVConfiguration alloc] init];
    USRVInitializeStateReset *resetState = [[USRVInitializeStateReset alloc] initWithConfiguration:config];
    
    __block id nextState = NULL;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        nextState = [resetState execute];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
    }];

    XCTAssertFalse([USRVSdkProperties isInitialized], @"SDK is initialized after SDK was reset");
    XCTAssertFalse([[USRVWebViewApp getCurrentApp] webAppLoaded], @"WebApp is loaded after SDK was reset");
    XCTAssertTrue([nextState isKindOfClass:[USRVInitializeStateInitModules class]], @"Next state should be 'Config'");
}

- (void)testInitializeStateLoadCache {
    USRVConfiguration *config = [[USRVConfiguration alloc] init];
    [config setConfigUrl:[USRVSdkProperties getConfigUrl]];
    [config setWebViewUrl:[USRVSdkProperties getConfigUrl]];
    [config setWebViewHash:@"12345"];

    USRVInitializeStateLoadCache *loadCacheState = [[USRVInitializeStateLoadCache alloc] initWithConfiguration:config];
    
    __block id nextState = NULL;
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        nextState = [loadCacheState execute];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
    }];

    XCTAssertTrue([nextState isKindOfClass:[USRVInitializeStateLoadWeb class]], @"Next state should be 'Load Web' because we tried to load from cache with bogus config");
    XCTAssertNotNil([config webViewUrl], @"WebViewUrl should not be nil");
    XCTAssertNotNil([config webViewHash], @"WebViewHash should not be nil");
}

- (void)testInitializeStateCreate {
    NSString *url = @"https://www.example.com/handlecallback.html";
    NSString *data = @"<script>var nativebridge = new Object(); nativebridge.handleCallback = new function() {	webviewbridge.handleInvocation(\"[['com.unity3d.ads.api.Sdk','initComplete', [], 'CALLBACK_01']]\"); }</script>";
    NSString *hash = [data unityads_sha256];
    
    USRVConfiguration *config = [[USRVConfiguration alloc] init];
    [config setWebViewUrl:url];
    [config setWebViewHash:hash];
    [config setWebViewData:data];
    
    __block id nextState = NULL;
    
    USRVInitializeStateCreate *createState = [[USRVInitializeStateCreate alloc] initWithConfiguration:config webViewData:data];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        nextState = [createState execute];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
    }];
    
    XCTAssertTrue([nextState isKindOfClass:[USRVInitializeStateComplete class]], @"Next state should be 'Complete'");
}

- (void)testInitializeStateComplete {
    __block id nextState = NULL;
    
    USRVConfiguration *config = [[USRVConfiguration alloc] init];
    USRVInitializeStateComplete *completeState = [[USRVInitializeStateComplete alloc] initWithConfiguration:config];
    
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
    USRVConfiguration *config = [[USRVConfiguration alloc] init];
    USRVInitializeStateComplete *completeState = [[USRVInitializeStateComplete alloc] initWithConfiguration:config];
    USRVInitializeStateRetry *retryState = [[USRVInitializeStateRetry alloc] initWithConfiguration:config retryState:completeState retryDelay:5];

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
    XCTAssertTrue([nextState isKindOfClass:[USRVInitializeStateComplete class]], @"Next state should be 'Complete'");
    XCTAssertFalse(diff <= 4, @"Difference is less than four seconds (should be 5 secs)");
    XCTAssertFalse(diff >= 6, @"Difference is more than six seconds (should be 5 secs)");
}

@end
