#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface USRVNativeCallbackTestsCallbacks : NSObject
@end

@implementation USRVNativeCallbackTestsCallbacks

static BOOL nativeCallbackInvoked = false;
static NSArray *nativeCallbackParams = NULL;

+ (void)invalidResponseMethod {
    nativeCallbackInvoked = true;
}

+ (void)validResponseMethod:(NSArray *)params {
    nativeCallbackInvoked = true;
    nativeCallbackParams = params;
}

@end

@interface USRVNativeCallbackTests : XCTestCase
@property (nonatomic, strong) NSCondition *blockCondition;
@end

@implementation USRVNativeCallbackTests

- (void)setUp {
    [super setUp];
    
    USRVConfiguration *config = [[USRVConfiguration alloc] initWithConfigUrl:@"http://localhost/"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [USRVWebViewApp create:config];
        [[USRVWebViewApp getCurrentApp] setWebAppLoaded:true];
        [[USRVWebViewApp getCurrentApp] setWebAppInitialized:true];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
    }];
}

- (void)tearDown {
    [super tearDown];
    [USRVWebViewApp setCurrentApp:NULL];
}

- (void)testNullCallback {
    USRVNativeCallback *nativeCallback = NULL;
    NSException *receivedException;
    
    @try {
        nativeCallback = [[USRVNativeCallback alloc] initWithMethod:NULL receiverClass:@"test"];
    }
    @catch (NSException *exception) {
        receivedException = exception;
    }
    
    XCTAssertEqualObjects(@"NullPointerException", [receivedException name], "Should have receiver NullPointerException because method name was NULL");
}

- (void)testNullReceiverClass {
    USRVNativeCallback *nativeCallback = NULL;
    NSException *receivedException;

    @try {
        nativeCallback = [[USRVNativeCallback alloc] initWithMethod:@"test" receiverClass:NULL];
    }
    @catch (NSException *exception) {
        receivedException = exception;
    }

    XCTAssertEqualObjects(@"NullPointerException", [receivedException name], "Should have receiver NullPointerException because receiver class name was NULL");
}

- (void)testInvalidMethodParamsSignatureOK {
    USRVNativeCallback *nativeCallback = NULL;
    NSException *receivedException;
    
    @try {
        nativeCallback = [[USRVNativeCallback alloc] initWithMethod:@"invalidResponseMethod:" receiverClass:@"USRVNativeCallbackTestsCallbacks"];
        [nativeCallback invokeWithStatus:@"OK" params:@[]];
    }
    @catch (NSException *exception) {
        receivedException = exception;
    }
    
    XCTAssertEqualObjects(@"NoSignatureException", [receivedException name], @"Should have received NoSignatureException");
    XCTAssertFalse(nativeCallbackInvoked, @"Native callback should not have been invoked");
    XCTAssertNil([nativeCallbackParams objectAtIndex:0], @"Callback status should still be NULL");
    XCTAssertNil([nativeCallbackParams objectAtIndex:1], @"Value should still be NULL");
}

- (void)testInvalidMethodOK {
    USRVNativeCallback *nativeCallback = NULL;
    NSException *receivedException;
    
    @try {
        nativeCallback = [[USRVNativeCallback alloc] initWithMethod:@"invalidResponseMethod" receiverClass:@"USRVNativeCallbackTestsCallbacks"];
        [nativeCallback invokeWithStatus:@"OK" params:@[]];
    }
    @catch (NSException *exception) {
        receivedException = exception;
    }
    
    XCTAssertEqualObjects(@"NSInvalidArgumentException", [receivedException name], @"Should have received NSInvalidArgumentException");
    XCTAssertFalse(nativeCallbackInvoked, @"Native callback should not have been invoked");
    XCTAssertNil([nativeCallbackParams objectAtIndex:0], @"Callback status should still be NULL");
    XCTAssertNil([nativeCallbackParams objectAtIndex:1], @"Value should still be NULL");
}

- (void)testValidMethodOK {
    USRVNativeCallback *nativeCallback = NULL;
    nativeCallback = [[USRVNativeCallback alloc] initWithMethod:@"validResponseMethod:" receiverClass:@"USRVNativeCallbackTestsCallbacks"];
    [nativeCallback invokeWithStatus:@"OK" params:@[@"We are okay"]];
    
    XCTAssertTrue(nativeCallbackInvoked, @"Native callback should have been invoked");
    XCTAssertEqualObjects([nativeCallbackParams objectAtIndex:0], @"OK", @"Callback status should be OK");
    XCTAssertEqualObjects([nativeCallbackParams objectAtIndex:1], @"We are okay", @"Value should be 'We are okay'");
}

- (void)testValidMethodERROR {
    USRVNativeCallback *nativeCallback = NULL;
    nativeCallback = [[USRVNativeCallback alloc] initWithMethod:@"validResponseMethod:" receiverClass:@"USRVNativeCallbackTestsCallbacks"];
    [nativeCallback invokeWithStatus:@"ERROR" params:@[@"We are broken"]];
    
    XCTAssertTrue(nativeCallbackInvoked, @"Native callback should have been invoked");
    XCTAssertEqualObjects([nativeCallbackParams objectAtIndex:0], @"ERROR", @"Callback status should be ERROR");
    XCTAssertEqualObjects([nativeCallbackParams objectAtIndex:1], @"We are broken", @"Value should be 'We are broken'");
}

@end
