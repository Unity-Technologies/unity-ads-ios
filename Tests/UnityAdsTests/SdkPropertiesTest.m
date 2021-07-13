#import <XCTest/XCTest.h>

#import "UnityAdsTests-Bridging-Header.h"
#import "UnityAdsInitializationDelegateMock.h"

@interface SdkPropertiesTest : XCTestCase

@end

@implementation SdkPropertiesTest

- (void)setUp {
    [super setUp];
    [UnityAds resetForTest];
}

- (void)tearDown {
    [super tearDown];
    [UnityAds resetForTest];
}

- (void)testSetInitialized {
    XCTAssertFalse([USRVSdkProperties isInitialized], @"SDK shouldn't be initialized");

    [USRVSdkProperties setInitialized: YES];

    XCTAssertTrue([USRVSdkProperties isInitialized], @"Method isInitialized should have returned true");
}

- (void)testSetTestMode {
    [USRVSdkProperties setTestMode: NO];

    XCTAssertFalse([USRVSdkProperties isTestMode], @"Method isInitialized should have returned false");

    [USRVSdkProperties setTestMode: YES];

    XCTAssertTrue([USRVSdkProperties isTestMode], @"Method isInitialized should have returned true");
}

- (void)testGetVersionCode {
    XCTAssertTrue([USRVSdkProperties getVersionCode] >= 2000, @"Version code should be over 2000");
}

- (void)testGetVersionName {
    XCTAssertNotNil([USRVSdkProperties getVersionName], @"Version name shouldn't be null");
}

- (void)testGetCacheDirectory {
    XCTAssertNotNil([USRVSdkProperties getCacheDirectory], @"Cache directory shouldn't be null");
}

- (void)testGetCacheFilePrefix {
    XCTAssertTrue([@"UnityAdsCache-" isEqualToString: [USRVSdkProperties getCacheFilePrefix]], @"Cache file prefix should be equal to 'UnityAdsCache-'");
}

- (void)testGetLocalStorageFilePrefix {
    XCTAssertTrue([@"UnityAdsStorage-" isEqualToString: [USRVSdkProperties getLocalStorageFilePrefix]], @"Local storage file prefix should be equal to 'UnityAdsStorage-'");
}

- (void)testGetLocalWebViewFile {
    NSString *fileName = [USRVSdkProperties getCacheDirectory];

    fileName = [fileName stringByAppendingString: @"/UnityAdsWebApp.html"];

    XCTAssertTrue([fileName isEqualToString: [USRVSdkProperties getLocalWebViewFile]], @"Local web view file should be equal to %@", fileName);
}

- (void)testIsChinaLocale {
    XCTAssertTrue([USRVSdkProperties isChinaLocale: @"cn"], @"Should return true with a china iso alpha 2 code");
    XCTAssertTrue([USRVSdkProperties isChinaLocale: @"chn" ], @"Should return true with a china iso alpha 3 code");
    XCTAssertTrue([USRVSdkProperties isChinaLocale: @"CN"], @"Should return true with an uppercase china iso alpha 2 code");
    XCTAssertTrue([USRVSdkProperties isChinaLocale: @"CHN"], @"Should return true with an uppercase china iso alpha 3 code");
    XCTAssertTrue([USRVSdkProperties isChinaLocale: @"ChN"], @"Should return true with a mixture of upper and lowercase china iso alpha 2 code characters");

    XCTAssertFalse([USRVSdkProperties isChinaLocale: @"us"], @"Should return false with a US iso code");
}

- (void)testGetInitializationDelegatesWhenEmpty {
    XCTAssertEqual(0, [[USRVSdkProperties getInitializationDelegates] count]);
}

- (void)testAddInitializationDelegateAndGetInitializationDelegates {
    UnityAdsInitializationDelegateMock *initializationDelegate = [[UnityAdsInitializationDelegateMock alloc] init];

    [USRVSdkProperties addInitializationDelegate: initializationDelegate];

    XCTAssertEqual(1, [[USRVSdkProperties getInitializationDelegates] count]);
    XCTAssertTrue([[USRVSdkProperties getInitializationDelegates] containsObject: initializationDelegate]);
}

- (void)testAddMultipleInitializationDelegatesAndGetInitializationDelegates {
    UnityAdsInitializationDelegateMock *initializationDelegate1 = [[UnityAdsInitializationDelegateMock alloc] init];
    UnityAdsInitializationDelegateMock *initializationDelegate2 = [[UnityAdsInitializationDelegateMock alloc] init];
    UnityAdsInitializationDelegateMock *initializationDelegate3 = [[UnityAdsInitializationDelegateMock alloc] init];

    [USRVSdkProperties addInitializationDelegate: initializationDelegate1];
    [USRVSdkProperties addInitializationDelegate: initializationDelegate2];
    [USRVSdkProperties addInitializationDelegate: initializationDelegate3];

    NSMutableArray *delegates = [USRVSdkProperties getInitializationDelegates];

    XCTAssertEqual(3, [[USRVSdkProperties getInitializationDelegates] count]);
    XCTAssertEqual(initializationDelegate1, [delegates objectAtIndex: 0]);
    XCTAssertEqual(initializationDelegate2, [delegates objectAtIndex: 1]);
    XCTAssertEqual(initializationDelegate3, [delegates objectAtIndex: 2]);
}

- (void)testAddMultipleSameInitializationDelegatesAndGetInitializationDelegates {
    UnityAdsInitializationDelegateMock *initializationDelegate = [[UnityAdsInitializationDelegateMock alloc] init];

    [USRVSdkProperties addInitializationDelegate: initializationDelegate];
    [USRVSdkProperties addInitializationDelegate: initializationDelegate];

    XCTAssertEqual(1, [[USRVSdkProperties getInitializationDelegates] count]);
}

- (void)testResetInitializationDelegatesAndGetInitializationDelegates {
    UnityAdsInitializationDelegateMock *initializationDelegate1 = [[UnityAdsInitializationDelegateMock alloc] init];
    UnityAdsInitializationDelegateMock *initializationDelegate2 = [[UnityAdsInitializationDelegateMock alloc] init];
    UnityAdsInitializationDelegateMock *initializationDelegate3 = [[UnityAdsInitializationDelegateMock alloc] init];

    [USRVSdkProperties addInitializationDelegate: initializationDelegate1];
    [USRVSdkProperties addInitializationDelegate: initializationDelegate2];
    [USRVSdkProperties addInitializationDelegate: initializationDelegate3];

    XCTAssertEqual(3, [[USRVSdkProperties getInitializationDelegates] count]);

    [USRVSdkProperties resetInitializationDelegates];

    XCTAssertEqual(0, [[USRVSdkProperties getInitializationDelegates] count]);
}

- (void)testAddInitializationDelegateAfterResetInitializationDelegatesAndGetInitializationDelegates {
    UnityAdsInitializationDelegateMock *initializationDelegate = [[UnityAdsInitializationDelegateMock alloc] init];

    [USRVSdkProperties addInitializationDelegate: initializationDelegate];

    XCTAssertEqual(1, [[USRVSdkProperties getInitializationDelegates] count]);

    [USRVSdkProperties resetInitializationDelegates];

    XCTAssertEqual(0, [[USRVSdkProperties getInitializationDelegates] count]);

    [USRVSdkProperties addInitializationDelegate: initializationDelegate];

    XCTAssertEqual(1, [[USRVSdkProperties getInitializationDelegates] count]);
    XCTAssertTrue([[USRVSdkProperties getInitializationDelegates] containsObject: initializationDelegate]);
}

- (void)testNotifyInitializationCallbackAndSetInitializeStateWhenInitializeSuccessfully {
    UnityAdsInitializationDelegateMock *initializationDelegate = [[UnityAdsInitializationDelegateMock alloc] init];

    [USRVSdkProperties addInitializationDelegate: initializationDelegate];

    XCTAssertEqual(1, [[USRVSdkProperties getInitializationDelegates] count]);

    XCTestExpectation *expectation1 = [self expectationWithDescription: @"expectation"];
    XCTestExpectation *expectation2 = [self expectationWithDescription: @"delegate call"];

    initializationDelegate.expectation = expectation2;

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue, ^{
        [USRVSdkProperties notifyInitializationComplete];
        [expectation1 fulfill];
    });
    [self waitForExpectationsWithTimeout: 2
                                 handler: ^(NSError *_Nullable error) {
                                 }];

    XCTAssertEqual(INITIALIZED_SUCCESSFULLY, [USRVSdkProperties getCurrentInitializationState]);
    XCTAssertTrue(initializationDelegate.didInitializeSuccessfully);
} /* testNotifyInitializationCallbackAndSetInitializeStateWhenInitializeSuccessfully */

- (void)testNotifyInitializationCallbackAndSetInitializeStateWhenInitializeFailed {
    UnityAdsInitializationDelegateMock *initializationDelegate = [[UnityAdsInitializationDelegateMock alloc] init];

    [USRVSdkProperties addInitializationDelegate: initializationDelegate];

    XCTAssertEqual(1, [[USRVSdkProperties getInitializationDelegates] count]);

    XCTestExpectation *expectation1 = [self expectationWithDescription: @"expectation"];
    XCTestExpectation *expectation2 = [self expectationWithDescription: @"delegate call"];

    initializationDelegate.expectation = expectation2;

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue, ^{
        [USRVSdkProperties notifyInitializationFailed: kUnityInitializationErrorInternalError
                                     withErrorMessage: @"SDK failed to initialize"];
        [expectation1 fulfill];
    });
    [self waitForExpectationsWithTimeout: 2
                                 handler: ^(NSError *_Nullable error) {
                                 }];

    XCTAssertEqual(INITIALIZED_FAILED, [USRVSdkProperties getCurrentInitializationState]);
    XCTAssertEqual(kUnityInitializationErrorInternalError, initializationDelegate.didInitializeFailedError);
    XCTAssertEqualObjects(@[@"SDK failed to initialize"], initializationDelegate.didInitializeFailedErrorMessage);
} /* testNotifyInitializationCallbackAndSetInitializeStateWhenInitializeFailed */

@end
