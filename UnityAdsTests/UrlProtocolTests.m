#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface WebViewBridgeTestApi : NSObject
@end

@implementation WebViewBridgeTestApi

static BOOL apiInvoked = false;
static NSString *apiValue = NULL;
static UADSWebViewCallback *apiCallback = NULL;
static int apiCallbackCount = 0;

+ (void)WebViewExposed_apiTestMethod:(NSString *)value callback:(UADSWebViewCallback *)callback {
    apiInvoked = true;
    apiValue = value;
    apiCallback = callback;
    apiCallbackCount++;
    
    [callback invoke:value, nil];
}

+ (void)WebViewExposed_apiTestMethodNoParams:(UADSWebViewCallback *)callback {
    apiInvoked = true;
    apiValue = NULL;
    apiCallback = callback;
    apiCallbackCount++;
    
    [callback invoke:nil];
}

@end

@interface UrlProtocolTestsCallbacks : NSObject
@end

@implementation UrlProtocolTestsCallbacks

static BOOL nativeCallbackInvoked = false;
static NSString *nativeCallbackStatus = NULL;
static NSString *nativeCallbackValue = NULL;

+ (void)staticTestHandleCallback:(NSArray *)params {
    nativeCallbackInvoked = true;
    nativeCallbackStatus = [params objectAtIndex:0];
}

+ (void)staticTestHandleCallbackStringParam:(NSArray *)params {
    nativeCallbackInvoked = true;
    nativeCallbackStatus = [params objectAtIndex:0];
    nativeCallbackValue = [params objectAtIndex:1];
}

- (void)instanceTestHandleCallback:(NSArray *)params {
    nativeCallbackInvoked = true;
    nativeCallbackStatus = [params objectAtIndex:0];
}

@end

@interface UrlProtocolMockWebView : UIWebView
@property (nonatomic, strong) XCTestExpectation *expectation;
@property (nonatomic, strong) NSString *lastJSString;
@end

@implementation UrlProtocolMockWebView
@synthesize expectation = _expectation;
@synthesize lastJSString = _lastJSString;

- (nullable NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script {
    if (self.expectation) {
        [self.expectation fulfill];
    }
    
    [self setLastJSString:script];
    return NULL;
}
@end

@interface UrlProtocolTests : XCTestCase
@end

@implementation UrlProtocolTests

- (void)setUp {
    [super setUp];
    UADSConfiguration *config = [[UADSConfiguration alloc] initWithConfigUrl:@"http://localhost/"];
    [config setWebAppApiClassList:@[@"WebViewBridgeTestApi"]];
    UrlProtocolMockWebView *mockWebView = [[UrlProtocolMockWebView alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [UADSWebViewApp create:config];
        [[UADSWebViewApp getCurrentApp] setWebAppLoaded:true];
        [[UADSWebViewApp getCurrentApp] setWebAppInitialized:true];
        [[UADSWebViewApp getCurrentApp] setWebView:mockWebView];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
    }];
}

- (void)tearDown {
    [super tearDown];
    nativeCallbackInvoked = false;
    nativeCallbackStatus = NULL;
    nativeCallbackValue = NULL;
    
    apiInvoked = false;
    apiValue = NULL;
    apiCallback = NULL;
    apiCallbackCount = 0;
    
    [UADSWebViewApp setCurrentApp:NULL];
}

- (void)testHandleInvocationShouldFailParametersNull {
    UADSURLProtocol *protocol = [[UADSURLProtocol alloc] init];
    NSString *jsonString = @"[[\"WebViewBridgeTestApi\", \"apiTestMethodNoParams\", null, \"CALLBACK_01\"]]";
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSException *receivedException;

    @try {
        [protocol actOnJSONResults:jsonData invocationType:@"handleInvocation"];
    }
    @catch (NSException *exception) {
        receivedException = exception;
    }
    
    XCTAssertEqualObjects(@"InvalidInvocationException", [receivedException name], "Should have received InvalidInvocationException because parameters were null");
}

- (void)testHandleInvocationShouldFailParametersEmpty {
    UADSURLProtocol *protocol = [[UADSURLProtocol alloc] init];
    NSString *jsonString = @"[[\"WebViewBridgeTestApi\", \"apiTestMethodNoParams\", \"\", \"CALLBACK_01\"]]";
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSException *receivedException;
    
    @try {
        [protocol actOnJSONResults:jsonData invocationType:@"handleInvocation"];
    }
    @catch (NSException *exception) {
        receivedException = exception;
    }
    
    XCTAssertEqualObjects(@"InvalidInvocationException", [receivedException name], "Should have received InvalidInvocationException because parameters were null");
}

- (void)testHandleInvocationShouldFailInvalidSelector {
    UADSURLProtocol *protocol = [[UADSURLProtocol alloc] init];
    NSString *jsonString = @"[[\"WebViewBridgeTestApi\", \"apiTestMethodNoParamz\", [], \"CALLBACK_01\"]]";
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSException *receivedException;
    
    @try {
        [protocol actOnJSONResults:jsonData invocationType:@"handleInvocation"];
    }
    @catch (NSException *exception) {
        receivedException = exception;
    }
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    [(UrlProtocolMockWebView *)[[UADSWebViewApp getCurrentApp] webView] setExpectation:expectation];
    __block BOOL success = true;
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            success = false;
        }
    }];
    
    NSString *jsString = [(UrlProtocolMockWebView *)[[UADSWebViewApp getCurrentApp] webView] lastJSString];
    XCTAssertTrue([jsString rangeOfString:@"ERROR"].location != NSNotFound, @"Last JSString should contain 'ERROR'");
    XCTAssertTrue([jsString rangeOfString:@"InvalidInvocationException"].location != NSNotFound, @"Last JSString should contain 'InvalidInvocationException'");
}

- (void)testHandleInvocationShouldFailInvalidClass {
    UADSURLProtocol *protocol = [[UADSURLProtocol alloc] init];
    NSString *jsonString = @"[[\"WebViewBridgeTestApiz\", \"apiTestMethodNoParams\", [], \"CALLBACK_01\"]]";
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSException *receivedException;
    
    @try {
        [protocol actOnJSONResults:jsonData invocationType:@"handleInvocation"];
    }
    @catch (NSException *exception) {
        receivedException = exception;
    }
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    [(UrlProtocolMockWebView *)[[UADSWebViewApp getCurrentApp] webView] setExpectation:expectation];
    __block BOOL success = true;
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        if (error) {
            success = false;
        }
    }];
    
    NSString *jsString = [(UrlProtocolMockWebView *)[[UADSWebViewApp getCurrentApp] webView] lastJSString];
    XCTAssertTrue([jsString rangeOfString:@"ERROR"].location != NSNotFound, @"Last JSString should contain 'ERROR'");
    XCTAssertTrue([jsString rangeOfString:@"InvalidInvocationException"].location != NSNotFound, @"Last JSString should contain 'InvalidInvocationException'");
}

- (void)testHandleInvocationShouldSucceed {
    UADSURLProtocol *protocol = [[UADSURLProtocol alloc] init];
    NSString *jsonString = @"[[\"WebViewBridgeTestApi\", \"apiTestMethodNoParams\", [], \"CALLBACK_01\"]]";
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSException *receivedException;
    
    @try {
        [protocol actOnJSONResults:jsonData invocationType:@"handleInvocation"];
    }
    @catch (NSException *exception) {
        receivedException = exception;
    }
    
    XCTAssertNil(receivedException, @"No exception should've received");
    XCTAssertTrue(apiInvoked, @"API selector should've been invoked");
    XCTAssertEqualObjects(@"CALLBACK_01", [apiCallback callbackId], @"Callback ID's should match!");
}

- (void)testHandleInvocationWithParamsShouldSucceed {
    UADSURLProtocol *protocol = [[UADSURLProtocol alloc] init];
    NSString *jsonString = @"[[\"WebViewBridgeTestApi\", \"apiTestMethod\", [\"test\"], \"CALLBACK_01\"]]";
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSException *receivedException;
    
    @try {
        [protocol actOnJSONResults:jsonData invocationType:@"handleInvocation"];
    }
    @catch (NSException *exception) {
        receivedException = exception;
    }
    
    XCTAssertNil(receivedException, @"No exception should've received");
    XCTAssertTrue(apiInvoked, @"API selector should've been invoked");
    XCTAssertEqualObjects(@"CALLBACK_01", [apiCallback callbackId], @"Callback ID's should match!");
    XCTAssertEqualObjects(@"test", apiValue, @"Parameter values do not match");
}

- (void)testHandleCallbackShouldFailParametersNull {
    UADSURLProtocol *protocol = [[UADSURLProtocol alloc] init];
    NSString *jsonString = @"{\"id\":1,\"status\":\"OK\",\"parameters\":null}";
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSException *receivedException;
    
    @try {
        [protocol actOnJSONResults:jsonData invocationType:@"handleCallback"];
    }
    @catch (NSException *exception) {
        receivedException = exception;
    }
    
    XCTAssertEqualObjects(@"InvalidArgumentException", [receivedException name], "Should have received InvalidArgumentException because parameters were null");
}

- (void)testHandleCallbackShouldFailParametersEmpty {
    UADSURLProtocol *protocol = [[UADSURLProtocol alloc] init];
    NSString *jsonString = @"{\"id\":1,\"status\":\"OK\",\"parameters\":\"\"}";
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSException *receivedException;
    
    @try {
        [protocol actOnJSONResults:jsonData invocationType:@"handleCallback"];
    }
    @catch (NSException *exception) {
        receivedException = exception;
    }
    
    XCTAssertEqualObjects(@"InvalidArgumentException", [receivedException name], "Should have received InvalidArgumentException because parametes were empty or in invalid format");
}

- (void)testHandleCallbackShouldFailCallbackNotAdded {
    UADSURLProtocol *protocol = [[UADSURLProtocol alloc] init];
    UADSNativeCallback *nativeCallback = [[UADSNativeCallback alloc] initWithCallback:@"staticTestHandleCallback:" receiverClass:@"UrlProtocolTestsCallbacks"];
    
    NSString *jsonString = [NSString stringWithFormat:@"{\"id\":\"%@\",\"status\":\"OK\",\"parameters\":[]}", [nativeCallback callbackId]];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSException *receivedException;
    
    @try {
        [protocol actOnJSONResults:jsonData invocationType:@"handleCallback"];
    }
    @catch (NSException *exception) {
        receivedException = exception;
    }
    
    XCTAssertEqualObjects(@"NullPointerException", [receivedException name], "Should have received NullPointerException because callback was not registered");
}

- (void)testHandleCallbackShouldFailMethodNotStatic {
    UADSURLProtocol *protocol = [[UADSURLProtocol alloc] init];
    UADSNativeCallback *nativeCallback = [[UADSNativeCallback alloc] initWithCallback:@"instanceTestHandleCallback:" receiverClass:@"UrlProtocolTestsCallbacks"];
    [[UADSWebViewApp getCurrentApp] addCallback:nativeCallback];
    
    NSString *jsonString = [NSString stringWithFormat:@"{\"id\":\"%@\",\"status\":\"OK\",\"parameters\":[]}", [nativeCallback callbackId]];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSException *receivedException;
    
    @try {
        [protocol actOnJSONResults:jsonData invocationType:@"handleCallback"];
    }
    @catch (NSException *exception) {
        receivedException = exception;
    }
    
    XCTAssertEqualObjects(@"NoSignatureException", [receivedException name], "Should have received NoSignatureException because callback selector should be unavailable");
}

- (void)testHandleCallbackShouldSucceed {
    UADSURLProtocol *protocol = [[UADSURLProtocol alloc] init];
    UADSNativeCallback *nativeCallback = [[UADSNativeCallback alloc] initWithCallback:@"staticTestHandleCallback:" receiverClass:@"UrlProtocolTestsCallbacks"];
    [[UADSWebViewApp getCurrentApp] addCallback:nativeCallback];
    
    NSString *jsonString = [NSString stringWithFormat:@"{\"id\":\"%@\",\"status\":\"OK\",\"parameters\":[]}", [nativeCallback callbackId]];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSException *receivedException;
    
    @try {
        [protocol actOnJSONResults:jsonData invocationType:@"handleCallback"];
    }
    @catch (NSException *exception) {
        receivedException = exception;
    }
    
    XCTAssertNil(receivedException, @"No exception should've happened!");
    XCTAssertTrue(nativeCallbackInvoked, @"NativeCallback should've been invoked");
    XCTAssertEqualObjects(nativeCallbackStatus, @"OK", @"NativeCallback status should be OK");
}

- (void)testHandleCallbackWithParamsShouldSucceed {
    UADSURLProtocol *protocol = [[UADSURLProtocol alloc] init];
    UADSNativeCallback *nativeCallback = [[UADSNativeCallback alloc] initWithCallback:@"staticTestHandleCallbackStringParam:" receiverClass:@"UrlProtocolTestsCallbacks"];
    [[UADSWebViewApp getCurrentApp] addCallback:nativeCallback];
    
    NSString *jsonString = [NSString stringWithFormat:@"{\"id\":\"%@\",\"status\":\"OK\",\"parameters\":[\"test\", 1]}", [nativeCallback callbackId]];
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSException *receivedException = NULL;
    
    @try {
        [protocol actOnJSONResults:jsonData invocationType:@"handleCallback"];
    }
    @catch (NSException *exception) {
        receivedException = exception;
    }
    
    XCTAssertNil(receivedException, @"No exception should've happened!");
    XCTAssertTrue(nativeCallbackInvoked, @"NativeCallback should've been invoked");
    XCTAssertEqualObjects(nativeCallbackStatus, @"OK", @"NativeCallback status should be OK");
    XCTAssertEqualObjects(nativeCallbackValue, @"test", @"NativeCallback value wasn't as expected");
}

@end