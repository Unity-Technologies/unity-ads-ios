#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface WebAppTestWebView : UIWebView
@property (nonatomic, assign) BOOL jsInvoked;
@property (nonatomic, strong) NSString *jsCall;
@property (nonatomic, strong) XCTestExpectation *expectation;
@end

@implementation WebAppTestWebView

@synthesize jsInvoked = _jsInvoked;
@synthesize jsCall = _jsCall;
@synthesize expectation = _expectation;

- (id)init {
    self = [super init];
    if (self) {
        [self setJsInvoked:false];
        [self setJsCall:NULL];
        [self setExpectation:NULL];
    }
    
    return self;
}

- (nullable NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script {
    self.jsInvoked = true;
    self.jsCall = script;
    
    if (self.expectation) {
        [self.expectation fulfill];
        self.expectation = NULL;
    }
    
    return NULL;
}

@end

@interface WebAppTestWebApp : USRVWebViewApp
@end

@implementation WebAppTestWebApp

- (id)init {
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (BOOL)invokeCallback:(USRVInvocation *)invocation {
    return true;
}

@end

@interface WebAppTests : XCTestCase
    @property (nonatomic, strong) NSCondition *blockCondition;
@end

@implementation WebAppTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    nativeCallbackMethodInvoked = false;
    [USRVWebViewApp setCurrentApp:NULL];
    [super tearDown];
}

// TESTS

static BOOL nativeCallbackMethodInvoked = false;

+ (void)nativeCallbackMethod {
    nativeCallbackMethodInvoked = true;
}

- (void)testCreate {
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    USRVConfiguration *config = [[USRVConfiguration alloc] initWithConfigUrl:@"http://localhost/"];
    __block BOOL success = true;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        [USRVWebViewApp create:config];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        if (error) {
            success = false;
        }
    }];
    
    XCTAssertTrue(success, @"Expectation failed");
    XCTAssertNotNil([USRVWebViewApp getCurrentApp], "Current WebView app should not be NULL after create");
}

- (void)testAddCallback {
    USRVWebViewApp *webViewApp = [[USRVWebViewApp alloc] init];
    [USRVWebViewApp setCurrentApp:webViewApp];
    WebAppTestWebView *webView = [[WebAppTestWebView alloc] init];
    [[USRVWebViewApp getCurrentApp] setWebView:webView];
    [[USRVWebViewApp getCurrentApp] setWebAppLoaded:true];
    [[USRVWebViewApp getCurrentApp] setWebAppInitialized:true];
    
    USRVNativeCallback *localNativeCallback = [[USRVNativeCallback alloc] initWithCallback:@"nativeCallbackMethod:" receiverClass:@"WebAppTests"];
    
    [[USRVWebViewApp getCurrentApp] addCallback:localNativeCallback];
    USRVNativeCallback *remoteNativeCallback = [[USRVWebViewApp getCurrentApp] getCallbackWithId:[localNativeCallback callbackId]];
    
    XCTAssertNotNil(remoteNativeCallback, @"The WebApp stored callback should not be NULL");
    XCTAssertEqualObjects(localNativeCallback, remoteNativeCallback, @"The local and the WebApp stored callback should be the same object");
    XCTAssertEqual([localNativeCallback callbackId], [remoteNativeCallback callbackId], @"The local and the WebApp stored callback should have the same ID");
}

- (void)testRemoveCallback {
    USRVWebViewApp *webViewApp = [[USRVWebViewApp alloc] init];
    [USRVWebViewApp setCurrentApp:webViewApp];
    WebAppTestWebView *webView = [[WebAppTestWebView alloc] init];
    [[USRVWebViewApp getCurrentApp] setWebView:webView];
    [[USRVWebViewApp getCurrentApp] setWebAppLoaded:true];
    [[USRVWebViewApp getCurrentApp] setWebAppInitialized:true];
    
    USRVNativeCallback *localNativeCallback = [[USRVNativeCallback alloc] initWithCallback:@"nativeCallbackMethod:" receiverClass:@"WebAppTests"];
    
    [[USRVWebViewApp getCurrentApp] addCallback:localNativeCallback];
    USRVNativeCallback *remoteNativeCallback = [[USRVWebViewApp getCurrentApp] getCallbackWithId:[localNativeCallback callbackId]];
    
    XCTAssertNotNil(remoteNativeCallback, @"The WebApp stored callback should not be NULL");
    
    [[USRVWebViewApp getCurrentApp] removeCallback:localNativeCallback];
    remoteNativeCallback = [[USRVWebViewApp getCurrentApp] getCallbackWithId:[localNativeCallback callbackId]];
    
    XCTAssertNil(remoteNativeCallback, @"The WebApp stored callback should be NULL");

}

- (void)testSetWebView {
    WebAppTestWebView *webView;
    USRVWebViewApp *webViewApp = [[USRVWebViewApp alloc] init];
    [USRVWebViewApp setCurrentApp:webViewApp];
    webView = [[WebAppTestWebView alloc] init];
    [[USRVWebViewApp getCurrentApp] setWebView:webView];
    [[USRVWebViewApp getCurrentApp] setWebAppLoaded:true];
    [[USRVWebViewApp getCurrentApp] setWebAppInitialized:true];

    XCTAssertNotNil([[USRVWebViewApp getCurrentApp] webView], @"Current WebApps WebView should not be null because it was set");
    XCTAssertEqualObjects(webView, [[USRVWebViewApp getCurrentApp] webView], @"Local and WebApps WebView should be the same object");
}

- (void)testSetConfiguration {
    WebAppTestWebView *webView;
    USRVWebViewApp *webViewApp = [[USRVWebViewApp alloc] init];
    [USRVWebViewApp setCurrentApp:webViewApp];
    webView = [[WebAppTestWebView alloc] init];
    [[USRVWebViewApp getCurrentApp] setWebView:webView];
    [[USRVWebViewApp getCurrentApp] setWebAppLoaded:true];
    [[USRVWebViewApp getCurrentApp] setWebAppInitialized:true];
    
    USRVConfiguration *config = [[USRVConfiguration alloc] initWithConfigUrl:@"http://localhost/"];
    [[USRVWebViewApp getCurrentApp] setConfiguration:config];
    
    XCTAssertNotNil([[USRVWebViewApp getCurrentApp] configuration], @"Current WebApp configuration should not be null");
    XCTAssertEqualObjects(config, [[USRVWebViewApp getCurrentApp] configuration], @"Local configuration and current WebApp configuration should be the same object");
}

- (void)testSetWebAppLoaded {
    WebAppTestWebView *webView;
    USRVWebViewApp *webViewApp = [[USRVWebViewApp alloc] init];
    [USRVWebViewApp setCurrentApp:webViewApp];
    webView = [[WebAppTestWebView alloc] init];
    [[USRVWebViewApp getCurrentApp] setWebView:webView];
    [[USRVWebViewApp getCurrentApp] setWebAppInitialized:true];

    XCTAssertFalse([[USRVWebViewApp getCurrentApp] webAppLoaded], @"WebApp should not be loaded. It was just created");
    
    [[USRVWebViewApp getCurrentApp] setWebAppLoaded:true];

    XCTAssertTrue([[USRVWebViewApp getCurrentApp] webAppLoaded], @"WebApp should now be \"loaded\". We set the status to true");
}

- (void)testSendEventShouldFail {
    WebAppTestWebView *webView;
    USRVWebViewApp *webViewApp = [[USRVWebViewApp alloc] init];
    [USRVWebViewApp setCurrentApp:webViewApp];
    webView = [[WebAppTestWebView alloc] init];
    [[USRVWebViewApp getCurrentApp] setWebView:webView];
    [[USRVWebViewApp getCurrentApp] setWebAppInitialized:true];
    
    BOOL success = [[USRVWebViewApp getCurrentApp] sendEvent:@"TEST_EVENT_1" category:@"TEST_CATEGORY_1" params:@[]];
    
    XCTAssertFalse(success, @"sendEvent should've failed since webApp is still unloaded");
    XCTAssertFalse([(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] jsInvoked], @"WebView invokeJavascript should've not been invoked but was (webviewapp is not loaded so no call should have occured)");
    XCTAssertNil([(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] jsCall], @"The invoked JavaScript string should be null (webviewapp is not loaded so no call should have occured)");
}

- (void)testSendEventShouldSucceed {
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    WebAppTestWebView *webView;
    USRVWebViewApp *webViewApp = [[USRVWebViewApp alloc] init];
    [USRVWebViewApp setCurrentApp:webViewApp];
    webView = [[WebAppTestWebView alloc] init];
    [[USRVWebViewApp getCurrentApp] setWebView:webView];
    [[USRVWebViewApp getCurrentApp] setWebAppLoaded:true];
    [[USRVWebViewApp getCurrentApp] setWebAppInitialized:true];
    
    __block BOOL success = false;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        success = [[USRVWebViewApp getCurrentApp] sendEvent:@"TEST_EVENT_1" category:@"TEST_CATEGORY_1" params:@[]];
        [(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] setExpectation:expectation];
        [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        }];
    });
    
    XCTAssertTrue(success, @"sendEvent should've succeeded");
    XCTAssertTrue([(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] jsInvoked], @"WebView invokeJavascript should've been invoked but was not");
    XCTAssertNotNil([(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] jsCall], @"The invoked JavaScript string should not be null");
}

- (void)testSendEventWithParamsShouldSucceed_VA_LIST {
    WebAppTestWebView *webView;
    USRVWebViewApp *webViewApp = [[USRVWebViewApp alloc] init];
    [USRVWebViewApp setCurrentApp:webViewApp];
    webView = [[WebAppTestWebView alloc] init];
    [[USRVWebViewApp getCurrentApp] setWebView:webView];
    [[USRVWebViewApp getCurrentApp] setWebAppLoaded:true];
    [[USRVWebViewApp getCurrentApp] setWebAppInitialized:true];
    
    __block BOOL success = false;
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        success = [[USRVWebViewApp getCurrentApp] sendEvent:@"TEST_EVENT_1" category:@"TEST_CATEGORY_1"
                                                          param1:@"Test", [NSNumber numberWithInt:1], [NSNumber numberWithBool:true], nil];
        [(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] setExpectation:expectation];
        [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        }];
    });
    
    XCTAssertTrue(success, @"sendEvent should've succeeded");
    XCTAssertTrue([(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] jsInvoked], @"WebView invokeJavascript should've been invoked but was not");
    XCTAssertNotNil([(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] jsCall], @"The invoked JavaScript string should not be null");
}

- (void)testSendEventWithParamsShouldSucceed_ARRAY {
    WebAppTestWebView *webView;
    USRVWebViewApp *webViewApp = [[USRVWebViewApp alloc] init];
    [USRVWebViewApp setCurrentApp:webViewApp];
    webView = [[WebAppTestWebView alloc] init];
    [[USRVWebViewApp getCurrentApp] setWebView:webView];
    [[USRVWebViewApp getCurrentApp] setWebAppLoaded:true];
    [[USRVWebViewApp getCurrentApp] setWebAppInitialized:true];
    
    __block BOOL success = false;
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        NSArray *params = [[NSArray alloc] initWithObjects:@"Test", [NSNumber numberWithInt:1], [NSNumber numberWithBool:true], nil];
        success = [[USRVWebViewApp getCurrentApp] sendEvent:@"TEST_EVENT_1" category:@"TEST_CATEGORY_1" params:params];
        [(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] setExpectation:expectation];
        [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        }];
    });

    XCTAssertTrue(success, @"sendEvent should've succeeded");
    XCTAssertTrue([(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] jsInvoked], @"WebView invokeJavascript should've been invoked but was not");
    XCTAssertNotNil([(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] jsCall], @"The invoked JavaScript string should not be null");
}

- (void)testInvokeMethodShouldFailWebAppNotLoaded {
    WebAppTestWebView *webView;
    USRVWebViewApp *webViewApp = [[USRVWebViewApp alloc] init];
    [USRVWebViewApp setCurrentApp:webViewApp];
    webView = [[WebAppTestWebView alloc] init];
    [[USRVWebViewApp getCurrentApp] setWebView:webView];
    [[USRVWebViewApp getCurrentApp] setWebAppInitialized:true];
    
    BOOL success = false;
    success = [[USRVWebViewApp getCurrentApp] invokeMethod:@"testMethod" className:@"TestClass" receiverClass:@"WebAppTests" callback:@"nativeCallbackMethod:" params:@[]];
    //[(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] setExpectation:expectation];
    
    XCTAssertFalse(success, @"invokeMethod -method should've returned false because webApp is not loaded");
    XCTAssertFalse([(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] jsInvoked], @"WebView invokeJavascript should've not been invoked but was (webviewapp is not loaded so no call should have occured)");
    XCTAssertNil([(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] jsCall], @"The invoked JavaScript string should be null (webviewapp is not loaded so no call should have occured)");
}

- (void)testInvokeMethodShouldSucceedMethodAndClassNull {
    WebAppTestWebView *webView;
    USRVWebViewApp *webViewApp = [[USRVWebViewApp alloc] init];
    [USRVWebViewApp setCurrentApp:webViewApp];
    webView = [[WebAppTestWebView alloc] init];
    [[USRVWebViewApp getCurrentApp] setWebView:webView];
    [[USRVWebViewApp getCurrentApp] setWebAppLoaded:true];
    [[USRVWebViewApp getCurrentApp] setWebAppInitialized:true];
    
    __block BOOL success = false;
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        success = [[USRVWebViewApp getCurrentApp] invokeMethod:@"testMethod" className:@"TestClass" receiverClass:NULL callback:NULL params:@[]];
        [(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] setExpectation:expectation];
        [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        }];
    });
    
    XCTAssertTrue(success, @"invokeMethod -method should've returned true");
    XCTAssertTrue([(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] jsInvoked], @"WebView invokeJavascript should've been invoked but was not");
    XCTAssertNotNil([(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] jsCall], @"The invoked JavaScript string should not be null");
}

- (void)testInvokeMethodShouldSucceed {
    WebAppTestWebView *webView;
    USRVWebViewApp *webViewApp = [[USRVWebViewApp alloc] init];
    [USRVWebViewApp setCurrentApp:webViewApp];
    webView = [[WebAppTestWebView alloc] init];
    [[USRVWebViewApp getCurrentApp] setWebView:webView];
    [[USRVWebViewApp getCurrentApp] setWebAppLoaded:true];
    [[USRVWebViewApp getCurrentApp] setWebAppInitialized:true];
    
    __block BOOL success = false;
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        success = [[USRVWebViewApp getCurrentApp] invokeMethod:@"testMethod" className:@"TestClass" receiverClass:@"WebAppTests" callback:@"nativeCallbackMethod:" params:@[]];
        [(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] setExpectation:expectation];
        [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        }];
    });
    
    XCTAssertTrue(success, @"invokeMethod -method should've returned true");
    XCTAssertTrue([(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] jsInvoked], @"WebView invokeJavascript should've been invoked but was not");
    XCTAssertNotNil([(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] jsCall], @"The invoked JavaScript string should not be null");
    //XCTAssertTrue(nativeCallbackMethodInvoked, @"Native callback method should've been invoked but was not");
}

- (void)testInvokeMethodWithParamsShouldSucceed {
    WebAppTestWebView *webView;
    USRVWebViewApp *webViewApp = [[USRVWebViewApp alloc] init];
    [USRVWebViewApp setCurrentApp:webViewApp];
    webView = [[WebAppTestWebView alloc] init];
    [[USRVWebViewApp getCurrentApp] setWebView:webView];
    [[USRVWebViewApp getCurrentApp] setWebAppLoaded:true];
    [[USRVWebViewApp getCurrentApp] setWebAppInitialized:true];
    
    __block BOOL success = false;
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        NSArray *params = [[NSArray alloc] initWithObjects:@"Test", [NSNumber numberWithInt:1], [NSNumber numberWithBool:true], nil];
        success = [[USRVWebViewApp getCurrentApp] invokeMethod:@"testMethod" className:@"TestClass" receiverClass:@"WebAppTests" callback:@"nativeCallbackMethod:" params:params];
        [(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] setExpectation:expectation];
        [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        }];
    });
    
    XCTAssertTrue(success, @"invokeMethod -method should've returned true");
    XCTAssertTrue([(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] jsInvoked], @"WebView invokeJavascript should've been invoked but was not");
    XCTAssertNotNil([(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] jsCall], @"The invoked JavaScript string should not be null");
    //XCTAssertTrue(nativeCallbackMethodInvoked, @"Native callback method should've been invoked but was not");
}

- (void)testInvokeCallbackShouldFailWebAppNotLoaded {
    WebAppTestWebView *webView;
    USRVWebViewApp *webViewApp = [[USRVWebViewApp alloc] init];
    [USRVWebViewApp setCurrentApp:webViewApp];
    webView = [[WebAppTestWebView alloc] init];
    [[USRVWebViewApp getCurrentApp] setWebView:webView];
    [[USRVWebViewApp getCurrentApp] setWebAppInitialized:true];
    
    USRVInvocation *invocation = [[USRVInvocation alloc] init];
    //NSArray *params = @[[NSString stringWithFormat:@"Test"], [NSNumber numberWithInt:1], [NSNumber numberWithBool:true], nil];
    NSMutableArray *params = [[NSMutableArray alloc] init];
    [params addObject:[NSString stringWithFormat:@"Test"]];
    [params addObject:[NSNumber numberWithInt:1]];
    [params addObject:[NSNumber numberWithBool:true]];
    [invocation setInvocationResponseWithStatus:@"OK" error:NULL params:[NSArray arrayWithArray:params]];
    
    __block BOOL success = false;
    success = [[USRVWebViewApp getCurrentApp] invokeCallback:invocation];
    
    XCTAssertFalse(success, @"invokeCallback -method should've returned false because webApp is not loaded");
    XCTAssertFalse([(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] jsInvoked], @"WebView invokeJavascript should've not been invoked but was (webviewapp is not loaded so no call should have occured)");
    XCTAssertNil([(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] jsCall], @"The invoked JavaScript string should be null (webviewapp is not loaded so no call should have occured)");
}

- (void)testInvokeCallbackShouldSucceed {
    WebAppTestWebView *webView;
    USRVWebViewApp *webViewApp = [[USRVWebViewApp alloc] init];
    [USRVWebViewApp setCurrentApp:webViewApp];
    webView = [[WebAppTestWebView alloc] init];
    [[USRVWebViewApp getCurrentApp] setWebView:webView];
    [[USRVWebViewApp getCurrentApp] setWebAppLoaded:true];
    [[USRVWebViewApp getCurrentApp] setWebAppInitialized:true];
    
    USRVInvocation *invocation = [[USRVInvocation alloc] init];
    [invocation setInvocationResponseWithStatus:@"OK" error:NULL params:@[@"Test", @12345, @true]];
    
    __block BOOL success = false;
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        success = [[USRVWebViewApp getCurrentApp] invokeCallback:invocation];
        [(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] setExpectation:expectation];
        [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        }];
    });
    
    XCTAssertTrue(success, @"invokeCallback -method should've succeeded");
    XCTAssertTrue([(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] jsInvoked], @"WebView invokeJavascript should've been invoked but was not");
    XCTAssertNotNil([(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] jsCall], @"The invoked JavaScript string should not be null");
}

- (void)testInvokeCallbackWithErrorShouldSucceed {
    WebAppTestWebView *webView;
    USRVWebViewApp *webViewApp = [[USRVWebViewApp alloc] init];
    [USRVWebViewApp setCurrentApp:webViewApp];
    webView = [[WebAppTestWebView alloc] init];
    [[USRVWebViewApp getCurrentApp] setWebView:webView];
    [[USRVWebViewApp getCurrentApp] setWebAppLoaded:true];
    [[USRVWebViewApp getCurrentApp] setWebAppInitialized:true];
    
    USRVInvocation *invocation = [[USRVInvocation alloc] init];
    [invocation setInvocationResponseWithStatus:@"ERROR" error:@"TEST_ERROR_1" params:@[@"Test", @12345, @true]];
    
    __block BOOL success = false;
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        success = [[USRVWebViewApp getCurrentApp] invokeCallback:invocation];
        [(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] setExpectation:expectation];
        [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        }];
    });
    
    XCTAssertTrue(success, @"invokeCallback -method should've succeeded");
    XCTAssertTrue([(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] jsInvoked], @"WebView invokeJavascript should've been invoked but was not");
    XCTAssertNotNil([(WebAppTestWebView *)[[USRVWebViewApp getCurrentApp] webView] jsCall], @"The invoked JavaScript string should not be null");
}

- (void)testTryRemoving {
    USRVWebViewBackgroundView *backgroundView = [[USRVWebViewBackgroundView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [[[[UIApplication sharedApplication] windows] firstObject] addSubview:backgroundView];
    [backgroundView removeFromSuperview];
    XCTAssertTrue([backgroundView superview], @"Should still have superview");
}

- (void)testTryAccessingSubviews {
    UIView *backgroundView = [[USRVWebViewBackgroundView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
    [backgroundView addSubview:view];
    XCTAssertEqual(0, [[backgroundView subviews] count], @"View count should seem 0");
}

@end
