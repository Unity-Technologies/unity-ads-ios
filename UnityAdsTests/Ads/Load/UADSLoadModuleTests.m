#import <XCTest/XCTest.h>
#import "UADSLoadModule.h"
#import "USRVSdkProperties.h"
#import "USRVInitializationNotificationCenter.h"
#import "USRVWebViewApp.h"
#import "UADSLoadOptions.h"

@interface UnityAdsLoadDelegateMock : NSObject<UnityAdsLoadDelegate>
@property (strong) NSMutableArray* adLoaded;
@property (strong) NSMutableArray* adFailedToLoad;
@property (nonatomic, strong) XCTestExpectation *expectation;

- (void)unityAdsAdLoaded:(NSString *)placementId;
- (void)unityAdsAdFailedToLoad:(NSString *)placementId;
@end

@implementation UnityAdsLoadDelegateMock

- (instancetype)init {
    if (self = [super init]) {
        self.adLoaded = [[NSMutableArray alloc] init];
        self.adFailedToLoad = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)unityAdsAdLoaded:(NSString *)placementId {
    [self.adLoaded addObject:placementId];
    [self.expectation fulfill];
}
- (void)unityAdsAdFailedToLoad:(NSString *)placementId {
    [self.adFailedToLoad addObject:placementId];
    [self.expectation fulfill];
}

@end

@interface MockLoadWebViewApp : USRVWebViewApp {
    NSString* receiverClass;
    NSString* callback;
    NSArray* params;
}
@property (nonatomic, strong) XCTestExpectation *loadCallExpectation;
@property (strong) UADSLoadModule* loadModule;
@property NSArray *params;

- (void)simulateLoadCall;
- (void)simulateFailedLoadCall;
- (void)simulateLoadCallTimeout;

@end

@implementation MockLoadWebViewApp

@synthesize params;

- (instancetype)initWithLoadModule:(UADSLoadModule*)loadModule {
    if (self = [super init]) {
        self.loadModule = loadModule;
    }
    return self;
}

- (BOOL)invokeMethod:(NSString *)methodName className:(NSString *)className receiverClass:(NSString *)receiverClass callback:(NSString *)callback params:(NSArray *)params {
    
    self->receiverClass = receiverClass;
    self->callback = callback;
    self.params = params;
    
    [_loadCallExpectation fulfill];
    return YES;
}

- (void)simulateLoadCall {
    Class class = NSClassFromString(self->receiverClass);
    SEL selector = NSSelectorFromString(self->callback);

    NSMethodSignature *signature = [class methodSignatureForSelector:selector];
    NSInvocation *invocation;

    invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;
    invocation.target = class;
    
    NSArray* arg = @[@"OK"];

    [invocation setArgument:&arg atIndex:2];
    [invocation retainArguments];
    [invocation invoke];
    
    NSDictionary* dict = self.params[0];
    
    [_loadModule sendAdLoaded:[dict objectForKey:@"placementId"] listenerId:[dict objectForKey:@"listenerId"]];
}

- (void)simulateFailedLoadCall {
    Class class = NSClassFromString(self->receiverClass);
    SEL selector = NSSelectorFromString(self->callback);

    NSMethodSignature *signature = [class methodSignatureForSelector:selector];
    NSInvocation *invocation;

    invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;
    invocation.target = class;
    
    NSArray* arg = @[@"NOT_OK"];

    [invocation setArgument:&arg atIndex:2];
    [invocation retainArguments];
    [invocation invoke];
}

- (void)simulateLoadCallTimeout {
    Class class = NSClassFromString(self->receiverClass);
    SEL selector = NSSelectorFromString(self->callback);

    NSMethodSignature *signature = [class methodSignatureForSelector:selector];
    NSInvocation *invocation;

    invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.selector = selector;
    invocation.target = class;
    
    NSArray* arg = @[@"OK"];

    [invocation setArgument:&arg atIndex:2];
    [invocation retainArguments];
    [invocation invoke];
}

@end

@interface UADSLoadModule (Test)

-(instancetype)initWithNotificationCenter:(NSObject <USRVInitializationNotificationCenterProtocol> *)initializeNotificationCenter;

@end

@interface UADSLoadModuleTests : XCTestCase

@property(nonatomic, strong) USRVInitializationNotificationCenter *initializationNotificationCenterTest;
@property(nonatomic, strong) UADSLoadModule *loadModule;

@end

@implementation UADSLoadModuleTests

-(void)setUp {
    [super setUp];
    self.initializationNotificationCenterTest = [[USRVInitializationNotificationCenter alloc] init];
    self.loadModule = [[UADSLoadModule alloc] initWithNotificationCenter:self.initializationNotificationCenterTest];
}

-(void)testLoadAfterInitialized {
    MockLoadWebViewApp* mock = [[MockLoadWebViewApp alloc] initWithLoadModule:_loadModule];
    [USRVWebViewApp setCurrentApp:mock];
    
    [USRVSdkProperties setInitialized:YES];
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"load call"];
    mock.loadCallExpectation = expectation;
    
    UnityAdsLoadDelegateMock* delegate = [[UnityAdsLoadDelegateMock alloc] init];
    
    [self.loadModule load:@"test" options:[UADSLoadOptions new] loadDelegate:delegate];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    expectation = [self expectationWithDescription:@"event call"];
    delegate.expectation = expectation;

    [mock simulateLoadCall];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    XCTAssertEqual(1, delegate.adLoaded.count);
    XCTAssertEqualObjects(@[@"test"], delegate.adLoaded);
    
    XCTAssertEqual(0, delegate.adFailedToLoad.count);
}

-(void)testLoadAfterInitialized_WithWebViewTimeout {
    MockLoadWebViewApp* mock = [[MockLoadWebViewApp alloc] initWithLoadModule:_loadModule];
    [USRVWebViewApp setCurrentApp:mock];
    
    [USRVSdkProperties setInitialized:YES];
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"load call"];
    mock.loadCallExpectation = expectation;
    
    UnityAdsLoadDelegateMock* delegate = [[UnityAdsLoadDelegateMock alloc] init];
    
    [self.loadModule load:@"test" options:[UADSLoadOptions new] loadDelegate:delegate];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    expectation = [self expectationWithDescription:@"event call"];
    delegate.expectation = expectation;
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
    
    XCTAssertEqual(0, delegate.adLoaded.count);
    
    XCTAssertEqual(1, delegate.adFailedToLoad.count);
    XCTAssertEqualObjects(@[@"test"], delegate.adFailedToLoad);
}

-(void)testLoadAfterInitialized_WithFailedInvocation {
    MockLoadWebViewApp* mock = [[MockLoadWebViewApp alloc] initWithLoadModule:_loadModule];
    [USRVWebViewApp setCurrentApp:mock];
    
    [USRVSdkProperties setInitialized:YES];
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"load call"];
    mock.loadCallExpectation = expectation;
    
    UnityAdsLoadDelegateMock* delegate = [[UnityAdsLoadDelegateMock alloc] init];
    
    [self.loadModule load:@"test" options:[UADSLoadOptions new] loadDelegate:delegate];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    expectation = [self expectationWithDescription:@"event call"];
    delegate.expectation = expectation;

    [mock simulateFailedLoadCall];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
    
    XCTAssertEqual(0, delegate.adLoaded.count);
    
    XCTAssertEqual(1, delegate.adFailedToLoad.count);
    XCTAssertEqualObjects(@[@"test"], delegate.adFailedToLoad);
}

-(void)testLoadAfterInitialized_ListenerCleanup {
    MockLoadWebViewApp* mock = [[MockLoadWebViewApp alloc] initWithLoadModule:_loadModule];
    [USRVWebViewApp setCurrentApp:mock];
    
    [USRVSdkProperties setInitialized:YES];
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"load call"];
    mock.loadCallExpectation = expectation;
    
    UnityAdsLoadDelegateMock* delegate = [[UnityAdsLoadDelegateMock alloc] init];
    
    [self.loadModule load:@"test" options:[UADSLoadOptions new] loadDelegate:delegate];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    expectation = [self expectationWithDescription:@"event call"];
    delegate.expectation = expectation;

    [mock simulateLoadCall];
    [mock simulateLoadCall];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    XCTAssertEqual(1, delegate.adLoaded.count);
    XCTAssertEqualObjects(@[@"test"], delegate.adLoaded);
    
    XCTAssertEqual(0, delegate.adFailedToLoad.count);
}

-(void)testLoadAfterInitialized_WithHardcodedTimeout {
    MockLoadWebViewApp* mock = [[MockLoadWebViewApp alloc] initWithLoadModule:_loadModule];
    [USRVWebViewApp setCurrentApp:mock];
    
    [USRVSdkProperties setInitialized:YES];
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"load call"];
    mock.loadCallExpectation = expectation;
    
    UnityAdsLoadDelegateMock* delegate = [[UnityAdsLoadDelegateMock alloc] init];
    
    [self.loadModule load:@"test" options:[UADSLoadOptions new] loadDelegate:delegate];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    expectation = [self expectationWithDescription:@"event call"];
    delegate.expectation = expectation;

    [mock simulateLoadCallTimeout];
    
    [self waitForExpectationsWithTimeout:35 handler:nil];
    
    XCTAssertEqual(0, delegate.adLoaded.count);
    
    XCTAssertEqual(1, delegate.adFailedToLoad.count);
    XCTAssertEqualObjects(@[@"test"], delegate.adFailedToLoad);
}

-(void)testLoadAfterInitialized_WithCorrectLoadOptions {
    MockLoadWebViewApp* mock = [[MockLoadWebViewApp alloc] initWithLoadModule:_loadModule];
    [USRVWebViewApp setCurrentApp:mock];
    
    [USRVSdkProperties setInitialized:YES];
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"load call"];
    mock.loadCallExpectation = expectation;
    
    UnityAdsLoadDelegateMock* delegate = [[UnityAdsLoadDelegateMock alloc] init];
    UADSLoadOptions* loadOptions = [UADSLoadOptions new];
    [loadOptions setAdMarkup:@"MyAdMarkup"];
    [loadOptions setObjectId:@"MyObjectID"];
    
    [self.loadModule load:@"test" options:loadOptions loadDelegate:delegate];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    expectation = [self expectationWithDescription:@"event call"];
    delegate.expectation = expectation;
    
    [mock simulateLoadCall];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    NSDictionary *options = [[[mock params] objectAtIndex:0] objectForKey:@"options"];
    
    XCTAssertEqual(1, delegate.adLoaded.count);
    XCTAssertEqualObjects(@[@"test"], delegate.adLoaded);
    XCTAssertEqual(0, delegate.adFailedToLoad.count);
    
    XCTAssertEqual(@"MyAdMarkup", [options objectForKey:@"adMarkup"]);
    XCTAssertEqual(@"MyObjectID", [options objectForKey:@"objectId"]);
}

-(void)testLoadBeforeInitialized {
    MockLoadWebViewApp* mock = [[MockLoadWebViewApp alloc] initWithLoadModule:_loadModule];
    [USRVWebViewApp setCurrentApp:mock];
    
    [USRVSdkProperties setInitialized:NO];
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"load call"];
    mock.loadCallExpectation = expectation;
    
    UnityAdsLoadDelegateMock* delegate = [[UnityAdsLoadDelegateMock alloc] init];
    
    [self.loadModule load:@"test" options:[UADSLoadOptions new] loadDelegate:delegate];
    
    [USRVSdkProperties setInitialized:YES];
    [_loadModule sdkDidInitialize];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    expectation = [self expectationWithDescription:@"event call"];
    delegate.expectation = expectation;

    [mock simulateLoadCall];
    
    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    XCTAssertEqual(1, delegate.adLoaded.count);
    XCTAssertEqualObjects(@[@"test"], delegate.adLoaded);
    
    XCTAssertEqual(0, delegate.adFailedToLoad.count);
}

-(void)testLoadBeforeInitialized_InitFailed {
    MockLoadWebViewApp* mock = [[MockLoadWebViewApp alloc] initWithLoadModule:_loadModule];
    [USRVWebViewApp setCurrentApp:mock];
    
    [USRVSdkProperties setInitialized:NO];
    
    UnityAdsLoadDelegateMock* delegate = [[UnityAdsLoadDelegateMock alloc] init];
    
    [self.loadModule load:@"test" options:[UADSLoadOptions new] loadDelegate:delegate];
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"event call"];
    delegate.expectation = expectation;
    
    [USRVSdkProperties setInitialized:YES];
    [_loadModule sdkInitializeFailed:nil];

    [self waitForExpectationsWithTimeout:1 handler:nil];
    
    XCTAssertEqual(0, delegate.adLoaded.count);
    
    XCTAssertEqual(1, delegate.adFailedToLoad.count);
    XCTAssertEqualObjects(@[@"test"], delegate.adFailedToLoad);
}

@end
