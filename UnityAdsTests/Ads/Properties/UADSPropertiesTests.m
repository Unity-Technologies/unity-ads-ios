#import <XCTest/XCTest.h>
#import "UADSProperties.h"
#import "UnityAds.h"
#import "UnityAdsDelegateMock.h"
#import "USRVSdkProperties.h"

@interface UADSPropertiesTests: XCTestCase
@end

@implementation UADSPropertiesTests

- (void)setUp {
    [super setUp];
    // reset UADSProperties object
    for (id<UnityAdsDelegate> delegate in [UADSProperties getDelegates]) {
        [UADSProperties removeDelegate:delegate];
    }
}

- (void)tearDown {
    [super tearDown];
    // reset UADSProperties object
    for (id<UnityAdsDelegate> delegate in [UADSProperties getDelegates]) {
        [UADSProperties removeDelegate:delegate];
    }
    //set Initialize State as INITIALIZING so it will not actually go down to initialize
    //and interfere other tests
    [USRVSdkProperties setInitializationState:INITIALIZING];
}

- (void)testSetDelegate {
    UnityAdsDelegateMock *delegate = [[UnityAdsDelegateMock alloc] init];

    [UADSProperties setDelegate:delegate];

    // test get
    XCTAssertEqual(delegate, [UADSProperties getDelegate]);
    // test getDelegates includes setDelegate
    XCTAssertTrue([[UADSProperties getDelegates] containsObject:delegate]);
    XCTAssertEqual(1, [[UADSProperties getDelegates] count]);
}

- (void)testGetDelegate {
    XCTAssertNil([UADSProperties getDelegate]);
}

- (void)testAddDelegate {
    UnityAdsDelegateMock *delegate = [[UnityAdsDelegateMock alloc] init];

    XCTAssertEqual(0, [[UADSProperties getDelegates] count]);

    [UADSProperties addDelegate:delegate];

    XCTAssertEqual(1, [[UADSProperties getDelegates] count]);
    XCTAssertEqual(delegate, [[UADSProperties getDelegates] firstObject]);

    [UADSProperties removeDelegate:delegate];

    XCTAssertEqual(0, [[UADSProperties getDelegates] count]);
}

- (void)testRemoveDelegate {
    UnityAdsDelegateMock *delegate = [[UnityAdsDelegateMock alloc] init];

    XCTAssertEqual(0, [[UADSProperties getDelegates] count]);

    [UADSProperties addDelegate:delegate];

    XCTAssertEqual(1, [[UADSProperties getDelegates] count]);
    XCTAssertEqual(delegate, [[UADSProperties getDelegates] firstObject]);

    [UADSProperties removeDelegate:delegate];

    XCTAssertEqual(0, [[UADSProperties getDelegates] count]);
}

- (void)testRemoveDuringIteration {
    UnityAdsDelegateMock *delegate1 = [[UnityAdsDelegateMock alloc] init];
    UnityAdsDelegateMock *delegate2 = [[UnityAdsDelegateMock alloc] init];

    [UADSProperties addDelegate:delegate1];
    [UADSProperties addDelegate:delegate2];

    NSOrderedSet *orderedSet = [UADSProperties getDelegates];
    @try {
        for (id <UnityAdsDelegate>delegate in orderedSet) {
            [UADSProperties removeDelegate:delegate];
        }
        XCTAssertTrue(true);
    } @catch (NSException *exception) {
        XCTFail(@"Exception was thrown");
    }
}

- (void)testAddMultipleDelegates {
    UnityAdsDelegateMock *delegate1 = [[UnityAdsDelegateMock alloc] init];
    UnityAdsDelegateMock *delegate2 = [[UnityAdsDelegateMock alloc] init];

    [UADSProperties addDelegate:delegate1];
    [UADSProperties addDelegate:delegate2];

    XCTAssertEqual(2, [[UADSProperties getDelegates] count]);
    XCTAssertTrue([[UADSProperties getDelegates] containsObject:delegate1]);
    XCTAssertTrue([[UADSProperties getDelegates] containsObject:delegate2]);

    [UADSProperties removeDelegate:delegate1];
    [UADSProperties removeDelegate:delegate2];

    XCTAssertEqual(0, [[UADSProperties getDelegates] count]);
}

- (void)testInitializeMultipleListeners {
    UnityAdsDelegateMock *delegate1 = [[UnityAdsDelegateMock alloc] init];
    UnityAdsDelegateMock *delegate2 = [[UnityAdsDelegateMock alloc] init];

    [UnityAds initialize:@"14850" delegate:delegate1];
    [UnityAds initialize:@"14850" delegate:delegate2];

    XCTAssertEqual(2, [[UADSProperties getDelegates] count]);
    XCTAssertTrue([[UADSProperties getDelegates] containsObject:delegate1]);
    XCTAssertTrue([[UADSProperties getDelegates] containsObject:delegate2]);
    XCTAssertEqual(delegate1, [UADSProperties getDelegate]);
}

- (void)testWrappingFirstListener {
    UnityAdsDelegateMock *delegate1 = [[UnityAdsDelegateMock alloc] init];
    UnityAdsDelegateMock *delegate2 = [[UnityAdsDelegateMock alloc] init];
    UnityAdsDelegateMock *delegate3 = [[UnityAdsDelegateMock alloc] init];

    // Initialize with first listener
    [UnityAds initialize:@"14851" delegate:delegate1];

    XCTAssertEqual(1, [[UADSProperties getDelegates] count]);
    XCTAssertEqual(delegate1, [UADSProperties getDelegate]);

    // Replace listener from initialize
    [UnityAds setDelegate:delegate2];

    XCTAssertEqual(1, [[UADSProperties getDelegates] count]);
    XCTAssertEqual(delegate2, [UADSProperties getDelegate]);
    XCTAssertTrue([[UADSProperties getDelegates] containsObject:delegate2]);
    XCTAssertFalse([[UADSProperties getDelegates] containsObject:delegate1]);

    // Add another listener that should only be added
    [UnityAds addDelegate:delegate3];

    XCTAssertEqual(delegate2, [UADSProperties getDelegate]);
    XCTAssertEqual(2, [[UADSProperties getDelegates] count]);
    XCTAssertFalse([[UADSProperties getDelegates] containsObject:delegate1]);
    XCTAssertTrue([[UADSProperties getDelegates] containsObject:delegate2]);
    XCTAssertTrue([[UADSProperties getDelegates] containsObject:delegate3]);
}

- (void)testSetOverwriteInit {
    UnityAdsDelegateMock *delegate1 = [[UnityAdsDelegateMock alloc] init];
    UnityAdsDelegateMock *delegate2 = [[UnityAdsDelegateMock alloc] init];
    UnityAdsDelegateMock *delegate3 = [[UnityAdsDelegateMock alloc] init];

    [UnityAds initialize:@"14851" delegate:delegate1];
    [UnityAds setDelegate:delegate2];
    [UnityAds initialize:@"14851" delegate:delegate3];

    XCTAssertEqual(2, [[UADSProperties getDelegates] count]);
    XCTAssertEqual(delegate2, [UADSProperties getDelegate]);
    XCTAssertFalse([[UADSProperties getDelegates] containsObject:delegate1]);
    XCTAssertTrue([[UADSProperties getDelegates] containsObject:delegate2]);
    XCTAssertTrue([[UADSProperties getDelegates] containsObject:delegate3]);
}

- (void)testMultipleThreadsAddRemoveDelegates {
    XCTestExpectation *expectationThread1 = [self expectationWithDescription:@"expectation1"];
    XCTestExpectation *expectationThread2 = [self expectationWithDescription:@"expectation2"];
    XCTestExpectation *expectationThread3 = [self expectationWithDescription:@"expectation3"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            for (int x=0; x<1000; x++) {
                UnityAdsDelegateMock *delegate = [[UnityAdsDelegateMock alloc] init];
                [UADSProperties addDelegate:delegate];
                [UADSProperties getDelegates];
                [UADSProperties removeDelegate:delegate];
            }
            [expectationThread1 fulfill];
        }
        @catch (NSException *exception) {
            NSLog(@"CRASH: %@", exception);
            NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
        }
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            for (int x=0; x<1000; x++) {
                UnityAdsDelegateMock *delegate = [[UnityAdsDelegateMock alloc] init];
                [UADSProperties addDelegate:delegate];
                [UADSProperties getDelegates];
                [UADSProperties removeDelegate:delegate];
            }
            [expectationThread2 fulfill];
        }
        @catch (NSException *exception) {
            NSLog(@"CRASH: %@", exception);
            NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
        }
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @try {
            for (int x=0; x<1000; x++) {
                UnityAdsDelegateMock *delegate = [[UnityAdsDelegateMock alloc] init];
                [UADSProperties addDelegate:delegate];
                [UADSProperties getDelegates];
                [UADSProperties removeDelegate:delegate];
            }
            [expectationThread3 fulfill];
        }
        @catch (NSException *exception) {
            NSLog(@"CRASH: %@", exception);
            NSLog(@"Stack Trace: %@", [exception callStackSymbols]);
        }
    });
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if (error) {
            XCTFail("race condition found");
        }
    }];
}

@end
