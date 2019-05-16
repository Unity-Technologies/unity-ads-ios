#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface InvocationTestsWebView : UIWebView
@property (nonatomic, assign) BOOL jsInvoked;
@property (nonatomic, strong) NSString *jsCall;
@property (nonatomic, strong) XCTestExpectation *expectation;
@end

@implementation InvocationTestsWebView

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
    }
    
    return NULL;
}

@end

@interface InvocationTests : XCTestCase
@end

@implementation InvocationTests

static int INVOKE_COUNT = 0;
static NSMutableDictionary *VALUES;
static NSMutableArray *CALLBACKS;

+ (void)WebViewExposed_apiTestMethod:(NSString *)value callback:(USRVWebViewCallback *)callback {
    INVOKE_COUNT++;
    [VALUES setObject:value forKey:[callback callbackId]];
    [CALLBACKS addObject:callback];
    
}

+ (void)WebViewExposed_apiTestMethodNoParams:(USRVWebViewCallback *)callback {
    INVOKE_COUNT++;
    [CALLBACKS addObject:callback];
}

- (void)setUp {
    [super setUp];
    
    USRVWebViewApp *webViewApp = [[USRVWebViewApp alloc] init];
    [USRVWebViewApp setCurrentApp:webViewApp];
    InvocationTestsWebView *webView = [[InvocationTestsWebView alloc] init];
    [[USRVWebViewApp getCurrentApp] setWebView:webView];
    [[USRVWebViewApp getCurrentApp] setWebAppLoaded:true];
    [[USRVWebViewApp getCurrentApp] setWebAppInitialized:true];
    
    INVOKE_COUNT = 0;
    VALUES = [[NSMutableDictionary alloc] init];
    CALLBACKS = [[NSMutableArray alloc] init];
    
    NSArray *classList = @[
                           @"InvocationTests",
                           ];
    
    [USRVInvocation setClassTable:classList];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testBasicInvocation {
    USRVInvocation *invocation = [[USRVInvocation alloc] init];
    USRVWebViewCallback *cb1 = [[USRVWebViewCallback alloc] initWithCallbackId:@"CALLBACK_01" invocationId:[invocation invocationId]];
    [invocation addInvocation:@"InvocationTests" methodName:@"apiTestMethod" parameters:@[@"test1"] callback:cb1];
    USRVWebViewCallback *cb2 = [[USRVWebViewCallback alloc] initWithCallbackId:@"CALLBACK_02" invocationId:[invocation invocationId]];
    [invocation addInvocation:@"InvocationTests" methodName:@"apiTestMethod" parameters:@[@"test2"] callback:cb2];
    USRVWebViewCallback *cb3 = [[USRVWebViewCallback alloc] initWithCallbackId:@"CALLBACK_03" invocationId:[invocation invocationId]];
    [invocation addInvocation:@"InvocationTests" methodName:@"apiTestMethod" parameters:@[@"test3"] callback:cb3];
    USRVWebViewCallback *cb4 = [[USRVWebViewCallback alloc] initWithCallbackId:@"CALLBACK_04" invocationId:[invocation invocationId]];
    [invocation addInvocation:@"InvocationTests" methodName:@"apiTestMethod" parameters:@[@"test4"] callback:cb4];

    [invocation nextInvocation];
    [invocation nextInvocation];
    [invocation nextInvocation];
    [invocation nextInvocation];

    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        [invocation sendInvocationCallback];
        [(InvocationTestsWebView *)[[USRVWebViewApp getCurrentApp] webView] setExpectation:expectation];
        [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        }];
    });

    XCTAssertEqual(INVOKE_COUNT, 4, "Invoke count should be the same as added invocations, but wasn't");

    XCTAssertEqualObjects([VALUES objectForKey:@"CALLBACK_01"], @"test1", @"sent and received values should be the same");
    XCTAssertEqualObjects([VALUES objectForKey:@"CALLBACK_02"], @"test2", @"sent and received values should be the same");
    XCTAssertEqualObjects([VALUES objectForKey:@"CALLBACK_03"], @"test3", @"sent and received values should be the same");
    XCTAssertEqualObjects([VALUES objectForKey:@"CALLBACK_04"], @"test4", @"sent and received values should be the same");

    XCTAssertEqualObjects([CALLBACKS objectAtIndex:0], cb1, @"sent and stored callbacks should be the same");
    XCTAssertEqualObjects([CALLBACKS objectAtIndex:1], cb2, @"sent and stored callbacks should be the same");
    XCTAssertEqualObjects([CALLBACKS objectAtIndex:2], cb3, @"sent and stored callbacks should be the same");
    XCTAssertEqualObjects([CALLBACKS objectAtIndex:3], cb4, @"sent and stored callbacks should be the same");

    XCTAssertTrue([(InvocationTestsWebView *)[[USRVWebViewApp getCurrentApp] webView] jsInvoked], @"WebView invokeJavascript should've been invoked but was not");
}


- (void)testBatchInvocationOneInvalidMethod {
    USRVInvocation *invocation = [[USRVInvocation alloc] init];
    USRVWebViewCallback *cb1 = [[USRVWebViewCallback alloc] initWithCallbackId:@"CALLBACK_01" invocationId:[invocation invocationId]];
    NSException *receivedException;

    @try {
        [invocation addInvocation:@"InvocationTests" methodName:@"apiTestMethodNonExistent" parameters:@[@"test1"] callback:cb1];
    }
    @catch (NSException *e) {
        receivedException = e;
    }

    XCTAssertNotNil(receivedException, "Received exception for the first addInvocation should not be null");
    XCTAssertEqualObjects(receivedException.name, @"InvalidInvocationException", "Exception should be InvalidInvocationException");

    USRVWebViewCallback *cb2 = [[USRVWebViewCallback alloc] initWithCallbackId:@"CALLBACK_02" invocationId:[invocation invocationId]];
    [invocation addInvocation:@"InvocationTests" methodName:@"apiTestMethod" parameters:@[@"test2"] callback:cb2];
    USRVWebViewCallback *cb3 = [[USRVWebViewCallback alloc] initWithCallbackId:@"CALLBACK_03" invocationId:[invocation invocationId]];
    [invocation addInvocation:@"InvocationTests" methodName:@"apiTestMethod" parameters:@[@"test3"] callback:cb3];
    USRVWebViewCallback *cb4 = [[USRVWebViewCallback alloc] initWithCallbackId:@"CALLBACK_04" invocationId:[invocation invocationId]];
    [invocation addInvocation:@"InvocationTests" methodName:@"apiTestMethod" parameters:@[@"test4"] callback:cb4];

    [invocation nextInvocation];
    [invocation nextInvocation];
    [invocation nextInvocation];
    [invocation nextInvocation];

    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_sync(queue, ^{
        [invocation sendInvocationCallback];
        [(InvocationTestsWebView *)[[USRVWebViewApp getCurrentApp] webView] setExpectation:expectation];
        [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
        }];
    });

    XCTAssertEqual(INVOKE_COUNT, 3, "Invoke count should be the same as added invocations, but wasn't");

    XCTAssertEqualObjects([VALUES objectForKey:@"CALLBACK_02"], @"test2", @"sent and received values should be the same");
    XCTAssertEqualObjects([VALUES objectForKey:@"CALLBACK_03"], @"test3", @"sent and received values should be the same");
    XCTAssertEqualObjects([VALUES objectForKey:@"CALLBACK_04"], @"test4", @"sent and received values should be the same");

    XCTAssertEqualObjects([CALLBACKS objectAtIndex:0], cb2, @"sent and stored callbacks should be the same");
    XCTAssertEqualObjects([CALLBACKS objectAtIndex:1], cb3, @"sent and stored callbacks should be the same");
    XCTAssertEqualObjects([CALLBACKS objectAtIndex:2], cb4, @"sent and stored callbacks should be the same");

    XCTAssertTrue([(InvocationTestsWebView *)[[USRVWebViewApp getCurrentApp] webView] jsInvoked], @"WebView invokeJavascript should've been invoked but was not");
}

@end
