#import <XCTest/XCTest.h>
#import "USRVInitializationDelegate.h"
#import "USRVInitializationNotificationCenter.h"

@interface USRVInitializationMock : NSObject <USRVInitializationDelegate>

@property(nonatomic, copy) void (^initializeBlock)(void);
@property(nonatomic, copy) void (^failBlock)(NSError *error);

@end

@implementation USRVInitializationMock

-(void)sdkDidInitialize {
    if (self.initializeBlock) {
        self.initializeBlock();
    }
}

-(void)sdkInitializeFailed:(NSError *)error {
    if (self.failBlock) {
        self.failBlock(error);
    }
}

@end

@interface USRVInitializationDelegateWrapper : NSObject

@property(nonatomic, weak) NSObject <USRVInitializationDelegate> *delegate;

-(instancetype)initWithDelegate:(__weak NSObject <USRVInitializationDelegate> *)delegate;

@end

@interface USRVInitializationNotificationCenterTests : XCTestCase

@property(nonatomic, strong) USRVInitializationNotificationCenter *initializationNotificationCenter;

@end

@implementation USRVInitializationNotificationCenterTests

-(void)setUp {
    [super setUp];
    self.initializationNotificationCenter = [[USRVInitializationNotificationCenter alloc] init];
}

-(void)testAddDelegate {
    USRVInitializationMock *mock = [[USRVInitializationMock alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAddDelegate"];
    mock.initializeBlock = ^() {
        [expectation fulfill];
    };
    [self.initializationNotificationCenter addDelegate:mock];
    [self.initializationNotificationCenter triggerSdkDidInitialize];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
    }];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"testAddDelegate2"];
    mock.initializeBlock = ^(){
        [expectation2 fulfill];
    };
    [self.initializationNotificationCenter triggerSdkDidInitialize];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
    }];
}

-(void)testRemoveDelegate {
    USRVInitializationMock *mock = [[USRVInitializationMock alloc] init];
    USRVInitializationMock *mock2 = [[USRVInitializationMock alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"testRemoveDelegate"];
    mock.initializeBlock = ^() {
        XCTFail(@"mock initializeBlock should not be called");
    };
    mock2.initializeBlock = ^() {
        [expectation fulfill];
    };
    [self.initializationNotificationCenter addDelegate:mock];
    [self.initializationNotificationCenter addDelegate:mock2];
    [self.initializationNotificationCenter removeDelegate:mock];
    [self.initializationNotificationCenter triggerSdkDidInitialize];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
    }];
}

-(void)testCleanupOfWeakDelegate {
    USRVInitializationMock *mock = [[USRVInitializationMock alloc] init];
    USRVInitializationMock *mock2 = [[USRVInitializationMock alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"testCleanupOfWeakDelegate"];
    mock.initializeBlock = ^() {
        [expectation fulfill];
    };
    [self.initializationNotificationCenter addDelegate:mock];
    [self.initializationNotificationCenter addDelegate:mock2];
    [self.initializationNotificationCenter triggerSdkDidInitialize];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
    }];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"testCleanupOfWeakDelegate2"];
    mock.initializeBlock = ^() {
        XCTFail(@"mock initializeBlock should not be called");
    };
    mock2.initializeBlock = ^() {
        [expectation2 fulfill];
    };
    mock = nil;
    [self.initializationNotificationCenter triggerSdkDidInitialize];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
    }];
}

-(void)testCleanupOfWeakDelegateForFailedInit {
    USRVInitializationMock *mock = [[USRVInitializationMock alloc] init];
    mock.failBlock = ^(NSError *error) {
        XCTFail(@"mock failBlock should not be called");
    };
    USRVInitializationMock *mock2 = [[USRVInitializationMock alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"testCleanupOfWeakDelegateForFailedInit"];
    mock2.failBlock = ^(NSError *error){
        [expectation fulfill];
    };

    [self.initializationNotificationCenter addDelegate:mock];
    [self.initializationNotificationCenter addDelegate:mock2];
    mock = nil;

    [self.initializationNotificationCenter triggerSdkInitializeDidFail:@"test" code:0];

    [self waitForExpectationsWithTimeout:1 handler:nil];
}

-(void)testAddDelegateTwice {
    USRVInitializationMock *mock = [[USRVInitializationMock alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"testAddDelegateTwice"];
    __block int count = 0;
    mock.initializeBlock = ^() {
        count++;
        [expectation fulfill];
    };
    [self.initializationNotificationCenter addDelegate:mock];
    [self.initializationNotificationCenter addDelegate:mock];
    [self.initializationNotificationCenter triggerSdkDidInitialize];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
    }];
    XCTAssertEqual(1, count);
}

-(void)testTriggerSdkDidInitialize {
    USRVInitializationMock *mock = [[USRVInitializationMock alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"testTriggerSdkDidInitialize"];
    mock.initializeBlock = ^() {
        [expectation fulfill];
    };
    [self.initializationNotificationCenter addDelegate:mock];
    [self.initializationNotificationCenter triggerSdkDidInitialize];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
    }];
}

-(void)testTriggerSdkDidInitializeMultipleDelegates {
    USRVInitializationMock *mock = [[USRVInitializationMock alloc] init];
    USRVInitializationMock *mock2 = [[USRVInitializationMock alloc] init];
    USRVInitializationMock *mock3 = [[USRVInitializationMock alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"testTriggerSdkDidInitialize1"];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"testTriggerSdkDidInitialize2"];
    XCTestExpectation *expectation3 = [self expectationWithDescription:@"testTriggerSdkDidInitialize3"];
    mock.initializeBlock = ^() {
        [expectation fulfill];
    };
    mock2.initializeBlock = ^() {
        [expectation2 fulfill];
    };
    mock3.initializeBlock = ^() {
        [expectation3 fulfill];
    };
    [self.initializationNotificationCenter addDelegate:mock];
    [self.initializationNotificationCenter addDelegate:mock2];
    [self.initializationNotificationCenter addDelegate:mock3];
    [self.initializationNotificationCenter triggerSdkDidInitialize];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
    }];
}

-(void)testTriggerSdkInitializeDidFail {
    USRVInitializationMock *mock = [[USRVInitializationMock alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"testTriggerSdkInitializeDidFail"];
    mock.failBlock = ^(NSError *error) {
        XCTAssertEqualObjects(@"USRVInitializationNotificationCenter", error.domain);
        XCTAssertEqual(@"test fail", [error.userInfo valueForKey:@"message"]);
        XCTAssertEqual(0, [error code]);
        [expectation fulfill];
    };
    [self.initializationNotificationCenter addDelegate:mock];
    [self.initializationNotificationCenter triggerSdkInitializeDidFail:@"test fail" code:0];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError *error) {
    }];
}

-(void)testDelegateWrapperMemory {
    USRVInitializationDelegateWrapper *initializationDelegateWrapper = [[USRVInitializationDelegateWrapper alloc] initWithDelegate:[[USRVInitializationMock alloc] init]];
    XCTAssertNil(initializationDelegateWrapper.delegate);
}

@end
