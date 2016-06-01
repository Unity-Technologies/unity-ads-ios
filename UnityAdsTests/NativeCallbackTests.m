#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface NativeCallbackTestsCallbacks : NSObject
@end

@implementation NativeCallbackTestsCallbacks

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

@interface NativeCallbackTests : XCTestCase
@property (nonatomic, strong) NSCondition *blockCondition;
@end

@implementation NativeCallbackTests

- (void)setUp {
    [super setUp];
    
    UADSConfiguration *config = [[UADSConfiguration alloc] initWithConfigUrl:@"http://localhost/"];
    [config setWebAppApiClassList:@[@"NativeCallbackTestsCallbacks"]];
    XCTestExpectation *expectation = [self expectationWithDescription:@"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        [UADSWebViewApp create:config];
        [[UADSWebViewApp getCurrentApp] setWebAppLoaded:true];
        [[UADSWebViewApp getCurrentApp] setWebAppInitialized:true];
        [expectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:60 handler:^(NSError * _Nullable error) {
    }];
}

- (void)tearDown {
    [super tearDown];
    [UADSWebViewApp setCurrentApp:NULL];
}

- (void)testNullCallback {
    UADSNativeCallback *nativeCallback = NULL;
    NSException *receivedException;
    
    @try {
        nativeCallback = [[UADSNativeCallback alloc] initWithCallback:NULL receiverClass:@"test"];
    }
    @catch (NSException *exception) {
        receivedException = exception;
    }
    
    XCTAssertEqualObjects(@"NullPointerException", [receivedException name], "Should have receiver NullPointerException because callback name was NULL");
}

- (void)testNullReceiverClass {
    UADSNativeCallback *nativeCallback = NULL;
    NSException *receivedException;
    
    @try {
        nativeCallback = [[UADSNativeCallback alloc] initWithCallback:@"test" receiverClass:NULL];
    }
    @catch (NSException *exception) {
        receivedException = exception;
    }
    
    XCTAssertEqualObjects(@"NullPointerException", [receivedException name], "Should have receiver NullPointerException because receiver class name was NULL");
}

- (void)testInvalidMethodParamsSignatureOK {
    UADSNativeCallback *nativeCallback = NULL;
    NSException *receivedException;
    
    @try {
        nativeCallback = [[UADSNativeCallback alloc] initWithCallback:@"invalidResponseMethod:" receiverClass:@"NativeCallbackTestsCallbacks"];
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
    UADSNativeCallback *nativeCallback = NULL;
    NSException *receivedException;
    
    @try {
        nativeCallback = [[UADSNativeCallback alloc] initWithCallback:@"invalidResponseMethod" receiverClass:@"NativeCallbackTestsCallbacks"];
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
    UADSNativeCallback *nativeCallback = NULL;
    nativeCallback = [[UADSNativeCallback alloc] initWithCallback:@"validResponseMethod:" receiverClass:@"NativeCallbackTestsCallbacks"];
    [nativeCallback invokeWithStatus:@"OK" params:@[@"We are okay"]];
    
    XCTAssertTrue(nativeCallbackInvoked, @"Native callback should have been invoked");
    XCTAssertEqualObjects([nativeCallbackParams objectAtIndex:0], @"OK", @"Callback status should be OK");
    XCTAssertEqualObjects([nativeCallbackParams objectAtIndex:1], @"We are okay", @"Value should be 'We are okay'");
}

- (void)testValidMethodERROR {
    UADSNativeCallback *nativeCallback = NULL;
    nativeCallback = [[UADSNativeCallback alloc] initWithCallback:@"validResponseMethod:" receiverClass:@"NativeCallbackTestsCallbacks"];
    [nativeCallback invokeWithStatus:@"ERROR" params:@[@"We are broken"]];
    
    XCTAssertTrue(nativeCallbackInvoked, @"Native callback should have been invoked");
    XCTAssertEqualObjects([nativeCallbackParams objectAtIndex:0], @"ERROR", @"Callback status should be ERROR");
    XCTAssertEqualObjects([nativeCallbackParams objectAtIndex:1], @"We are broken", @"Value should be 'We are broken'");
}

@end