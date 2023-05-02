#import <XCTest/XCTest.h>
#import <WebKit/WebKit.h>
#import "UnityAdsTests-Bridging-Header.h"
#import "UnityAdsInitializationDelegateMock.h"
#import "USRVInitializeStateLoadConfigFile.h"
#import "USRVInitializeStateReset.h"
#import "USRVInitializeStateForceReset.h"
#import "USRVInitializeStateInitModules.h"
#import "USRVInitializeStateLoadCache.h"
#import "USRVInitializeStateCreate.h"
#import "USRVInitializeStateLoadWeb.h"
#import "USRVInitializeStateComplete.h"
#import "USRVInitializeStateError.h"
#import "USRVInitializeStateNetworkError.h"
#import "USRVInitializeStateRetry.h"
#import "USRVInitializeStateLoadCacheConfigAndWebView.h"
#import "USRVInitializeStateCheckForUpdatedWebView.h"
#import "USRVInitializeStateCleanCache.h"
#import "USRVInitializeStateUpdateCache.h"
#import "USRVInitializeStateCheckForCachedWebViewUpdate.h"
#import "USRVInitializeStateDownloadLatestWebView.h"
#import "UADSTokenStorage.h"
#import "XCTestCase+Convenience.h"
static NSString *const kUnityAdsWebViewMockURL = @"https://webview.unityads.unity3d.com/webview/fix/skadnetwork-patch-versions/release/index.html";

@interface InitializeTests : XCTestCase
@end

@implementation InitializeTests

- (void)setUp {
    UADSServiceProviderContainer.sharedInstance.serviceProvider = [UADSServiceProvider new];
    [self cleanupCache];
    [super setUp];
}

- (void)tearDown {
    [self cleanupCache];
    [super tearDown];
}

- (void)cleanupCache {
    [[NSFileManager defaultManager] removeItemAtPath: [USRVSdkProperties getLocalWebViewFile]
                                               error: NULL];
    [[NSFileManager defaultManager] removeItemAtPath: [USRVSdkProperties getLocalConfigFilepath]
                                               error: NULL];
    
    [USRVSdkProperties setLatestConfiguration: nil];
    [USRVSdkProperties setInitializationState: NOT_INITIALIZED];
    [USRVSdkProperties setInitialized: false];
}

- (void)testInitializeStateLoadConfigFile {
    USRVConfiguration *localConfiguration = [[USRVConfiguration alloc] init];

    [localConfiguration setWebViewUrl: @"fake-url"];
    [localConfiguration setSdkVersion: [USRVSdkProperties getVersionName]];
    [[localConfiguration toJson] writeToFile: [USRVSdkProperties getLocalConfigFilepath]
                                  atomically: YES];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalConfigFilepath]], @"Local Configuration file does not exist at path");

    USRVConfiguration *config = [[USRVConfiguration alloc] init];
    USRVInitializeStateLoadConfigFile *loadConfigFileState = [[USRVInitializeStateLoadConfigFile alloc] initWithConfiguration: config];
    __block id nextState = NULL;

    XCTestExpectation *expectation = [self expectationWithDescription: @"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue, ^{
        nextState = [loadConfigFileState execute];
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout: 1
                                 handler: ^(NSError *_Nullable error) {
                                 }];

    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateReset class]], @"Next state should be 'Reset'");
    USRVInitializeStateReset *state = (USRVInitializeStateReset *)nextState;

    XCTAssertNotNil([[state configuration] webViewUrl], @"Webview URL should be non-nil");
} /* testInitializeStateLoadConfigFile */

- (void)testInitializeStateLoadConfigFileNoConfigExists {
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalConfigFilepath]], @"Local Configuration file does not exist at path");
    USRVConfiguration *config = [[USRVConfiguration alloc] init];
    USRVInitializeStateLoadConfigFile *loadConfigFileState = [[USRVInitializeStateLoadConfigFile alloc] initWithConfiguration: config];

    __block id nextState = NULL;

    XCTestExpectation *expectation = [self expectationWithDescription: @"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue, ^{
        nextState = [loadConfigFileState execute];
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout: 1
                                 handler: ^(NSError *_Nullable error) {
                                 }];

    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateReset class]], @"Next state should be 'Reset'");
} /* testInitializeStateLoadConfigFileNoConfigExists */

- (void)testInitializeStateReset {
    USRVWebViewApp *webViewApp = [[USRVWebViewApp alloc] init];
    WKWebView *webView = [[WKWebView alloc] init];

    [USRVWebViewApp setCurrentApp: webViewApp];
    [[USRVWebViewApp getCurrentApp] setWebView: webView];
    [[USRVWebViewApp getCurrentApp] setWebAppLoaded: true];
    [USRVSdkProperties setInitialized: true];

    USRVConfiguration *config = [[USRVConfiguration alloc] init];
    USRVInitializeStateReset *resetState = [[USRVInitializeStateReset alloc] initWithConfiguration: config];

    __block id nextState = NULL;

    XCTestExpectation *expectation = [self expectationWithDescription: @"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue, ^{
        nextState = [resetState execute];
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout: 60
                                 handler: ^(NSError *_Nullable error) {
                                 }];

    XCTAssertFalse([USRVSdkProperties isInitialized], @"SDK is initialized after SDK was reset");
    XCTAssertFalse([[USRVWebViewApp getCurrentApp] webAppLoaded], @"WebApp is loaded after SDK was reset");
    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateInitModules class]], @"Next state should be 'Config'");
} /* testInitializeStateReset */

- (void)testInitializeStateLoadCache {
    USRVConfiguration *config = [[USRVConfiguration alloc] initWithConfigUrl: [USRVSdkProperties getConfigUrl]];

    [config setWebViewUrl: @"fragile-test-setup.com"];
    [config setWebViewHash: @"12345"];

    USRVInitializeStateLoadCache *loadCacheState = [[USRVInitializeStateLoadCache alloc] initWithConfiguration: config];

    __block id nextState = NULL;

    XCTestExpectation *expectation = [self expectationWithDescription: @"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue, ^{
        nextState = [loadCacheState execute];
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout: 60
                                 handler: ^(NSError *_Nullable error) {
                                 }];

    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateLoadWeb class]], @"Next state should be 'Load Web' because we tried to load from cache with bogus config");
    XCTAssertNotNil([config webViewUrl], @"WebViewUrl should not be nil");
    XCTAssertNotNil([config webViewHash], @"WebViewHash should not be nil");
} /* testInitializeStateLoadCache */

- (void)testInitializeStateLoadWebMalformedUrl {
    USRVConfiguration *config = [[USRVConfiguration alloc] initWithConfigUrl: [USRVSdkProperties getConfigUrl]];

    [config setWebViewUrl: @"bad-url"];

    USRVInitializeStateLoadWeb *loadWebState = [[USRVInitializeStateLoadWeb alloc] initWithConfiguration: config];

    __block id nextState = NULL;

    XCTestExpectation *expectation = [self expectationWithDescription: @"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue, ^{
        nextState = [loadWebState execute];
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout: 60
                                 handler: ^(NSError *_Nullable error) {
                                 }];

    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateError class]], @"Next state should be Error State due to malformed URL");
} /* testInitializeStateLoadWebMalformedUrl */

- (void)testInitializeStateLoadWebInvalidHash {
    USRVConfiguration *config = [[USRVConfiguration alloc] initWithConfigUrl: [USRVSdkProperties getConfigUrl]];

    [config setWebViewUrl: kUnityAdsWebViewMockURL];
    [config setWebViewHash: @"invalidHash"];


    USRVInitializeStateLoadWeb *loadWebState = [[USRVInitializeStateLoadWeb alloc] initWithConfiguration: config];

    __block id nextState = NULL;

    XCTestExpectation *expectation = [self expectationWithDescription: @"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue, ^{
        nextState = [loadWebState execute];
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout: 60
                                 handler: ^(NSError *_Nullable error) {
                                 }];

    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateError class]], @"Next state should be Error State due to invalid hash");
} /* testInitializeStateLoadWebInvalidHash */

- (void)testInitializeStateLoadWebNullHash {
    USRVConfiguration *config = [[USRVConfiguration alloc] initWithConfigUrl: [USRVSdkProperties getConfigUrl]];

    [config setWebViewUrl: kUnityAdsWebViewMockURL];
    [config setWebViewHash: nil];

    USRVInitializeStateLoadWeb *loadWebState = [[USRVInitializeStateLoadWeb alloc] initWithConfiguration: config];

    __block id nextState = NULL;

    XCTestExpectation *expectation = [self expectationWithDescription: @"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue, ^{
        nextState = [loadWebState execute];
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout: 60
                                 handler: ^(NSError *_Nullable error) {
                                 }];

    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateCreate class]], @"Next state should be Create State due to null hash");
} /* testInitializeStateLoadWebNullHash */

- (void)testInitializeStateLoadWebHappyPath {
    USRVConfiguration *config = [[USRVConfiguration alloc] initWithConfigUrl: [USRVSdkProperties getConfigUrl]];

    [config setWebViewUrl: kUnityAdsWebViewMockURL];
    [config setWebViewHash: @"7783e0aaf52a770d7addc8edac39eb4048999666ba5a0b04fe009ee75058c14e"];

    USRVInitializeStateLoadWeb *loadWebState = [[USRVInitializeStateLoadWeb alloc] initWithConfiguration: config];

    __block id nextState = NULL;

    XCTestExpectation *expectation = [self expectationWithDescription: @"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue, ^{
        nextState = [loadWebState execute];
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout: 60
                                 handler: ^(NSError *_Nullable error) {
                                 }];

    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateCreate class]], @"Next state should be Create State due to valid hash");
} /* testInitializeStateLoadWebHappyPath */

- (void)testInitializeStateCreate {
    NSString *url = @"https://www.example.com/handlecallback.html";
    NSString *data = @"<script>window.webkit.messageHandlers.handleInvocation.postMessage(JSON.stringify([[\"USRVApiSdk\",\"initComplete\", [], \"1\"]]));</script>";
    NSString *hash = [data uads_sha256];

    [data writeToFile: [USRVSdkProperties getLocalWebViewFile]
           atomically: YES
             encoding: NSUTF8StringEncoding
                error: nil];

    USRVConfiguration *config = [[USRVConfiguration alloc] init];

    [config setWebViewUrl: url];
    [config setWebViewHash: hash];
    [config setWebViewData: data];

    __block id nextState = NULL;

    USRVInitializeStateCreate *createState = [[USRVInitializeStateCreate alloc] initWithConfiguration: config
                                                                                          webViewData: data];

    XCTestExpectation *expectation = [self expectationWithDescription: @"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue, ^{
        nextState = [createState execute];
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout: 60
                                 handler: ^(NSError *_Nullable error) {
                                 }];

    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateComplete class]], @"Next state should be 'Complete'");
} /* testInitializeStateCreate */

- (void)testInitializeStateCreateFailed {
    NSString *url = @"https://www.example.com/handlecallback.html";
    NSString *data = @"<script>window.webkit.messageHandlers.handleInvocation.postMessage(JSON.stringify([[\"USRVApiSdk\",\"initError\", ['error', 1], \"0\"]]));</script>";
    NSString *hash = [data uads_sha256];

    [data writeToFile: [USRVSdkProperties getLocalWebViewFile]
           atomically: YES
             encoding: NSUTF8StringEncoding
                error: nil];

    USRVConfiguration *config = [[USRVConfiguration alloc] init];

    [config setWebViewUrl: url];
    [config setWebViewHash: hash];
    [config setWebViewData: data];

    __block id nextState = NULL;

    [USRVWebViewApp setCurrentApp: nil];
    USRVInitializeStateCreate *createState = [[USRVInitializeStateCreate alloc] initWithConfiguration: config
                                                                                          webViewData: data];

    XCTestExpectation *expectation = [self expectationWithDescription: @"expectation"];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue, ^{
        nextState = [createState execute];
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout: 500
                                 handler: ^(NSError *_Nullable error) {
                                 }];

    XCTAssertFalse([[USRVWebViewApp getCurrentApp] isWebAppInitialized]);
    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateError class]], @"Next state should be 'Error'");
} /* testInitializeStateCreateFailed */

- (void)testInitializeStateNetworkError {
    USRVConfiguration *config = [[USRVConfiguration alloc] init];
    long oneHalfSecond = 500;

    [config setNetworkErrorTimeout: oneHalfSecond];
    USRVInitializeStateNetworkError *networkErrorState = [[USRVInitializeStateNetworkError alloc] initWithConfiguration: config
                                                                                                           erroredState: NULL
                                                                                                                   code: kUADSErrorStateInvalidHash
                                                                                                                message: @"this is just a test"];


    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();

    __block id nextState = NULL;
    XCTestExpectation *expectation = [self expectationWithDescription: @"expectation"];

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue, ^{
        nextState = [networkErrorState execute];
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout: 3
                                 handler: ^(NSError *_Nullable error) {
                                 }];

    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime diffInSeconds = endTime - startTime;

    NSLog(@"NetworkErrorState Time difference: %f", diffInSeconds);

    XCTAssertTrue(diffInSeconds > .5, @"Difference is less than one half second");
    XCTAssertTrue(diffInSeconds < 1, @"Difference is more than one second");
} /* testInitializeStateNetworkError */

- (void)testInitializeStateComplete {
    __block id nextState = NULL;

    USRVConfiguration *config = [[USRVConfiguration alloc] init];
    USRVInitializeStateComplete *completeState = [[USRVInitializeStateComplete alloc] initWithConfiguration: config];

    XCTestExpectation *expectation = [self expectationWithDescription: @"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue, ^{
        nextState = [completeState execute];
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout: 60
                                 handler: ^(NSError *_Nullable error) {
                                 }];

    XCTAssertNil(nextState, @"Next state should be NULL");
}

- (void)testInitializeStateRetry {
    USRVConfiguration *config = [[USRVConfiguration alloc] init];
    USRVInitializeStateComplete *completeState = [[USRVInitializeStateComplete alloc] initWithConfiguration: config];
    USRVInitializeStateRetry *retryState = [[USRVInitializeStateRetry alloc] initWithConfiguration: config
                                                                                        retryState: completeState
                                                                                        retryDelay: 5000];

    __block id nextState = NULL;

    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();

    XCTestExpectation *expectation = [self expectationWithDescription: @"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue, ^{
        nextState = [retryState execute];
        [expectation fulfill];
    });

    [self waitForExpectationsWithTimeout: 60
                                 handler: ^(NSError *_Nullable error) {
                                 }];

    CFAbsoluteTime endTime = CFAbsoluteTimeGetCurrent();
    CFAbsoluteTime diff = endTime - startTime;

    NSLog(@"DIFF: %f", diff);
    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateComplete class]], @"Next state should be 'Complete'");
    XCTAssertFalse(diff <= 4, @"Difference is less than four seconds (should be 5 secs)");
    XCTAssertFalse(diff >= 6, @"Difference is more than six seconds (should be 5 secs)");
} /* testInitializeStateRetry */

- (void)testInitializeStateCompleteTriggerInitializeComplete {
    UnityAdsInitializationDelegateMock *initializationDelegate = [[UnityAdsInitializationDelegateMock alloc] init];

    [USRVSdkProperties addInitializationDelegate: initializationDelegate];
    __block id nextState = NULL;

    USRVConfiguration *config = [[USRVConfiguration alloc] init];
    USRVInitializeStateComplete *completeState = [[USRVInitializeStateComplete alloc] initWithConfiguration: config];

    XCTestExpectation *expectation1 = [self expectationWithDescription: @"expectation"];
    XCTestExpectation *expectation2 = [self expectationWithDescription: @"delegate call"];

    initializationDelegate.expectation = expectation2;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue, ^{
        nextState = [completeState execute];
        [expectation1 fulfill];
    });
    [self waitForExpectationsWithTimeout: 60
                                 handler: ^(NSError *_Nullable error) {
                                 }];

    XCTAssertTrue(initializationDelegate.didInitializeSuccessfully);
} /* testInitializeStateCompleteTriggerInitializeComplete */

- (void)testInitializeStateErrorTriggerInitializeFailed {
    [[UADSTokenStorage sharedInstance] setInitToken: @"token_from_tsi_config_call"];
    XCTAssertNotNil([[UADSTokenStorage sharedInstance] getToken]);
    UnityAdsInitializationDelegateMock *initializationDelegate = [[UnityAdsInitializationDelegateMock alloc] init];

    [USRVSdkProperties addInitializationDelegate: initializationDelegate];

    USRVConfiguration *config = [[USRVConfiguration alloc] init];
    USRVInitializeStateError *errorState = [[USRVInitializeStateError alloc] initWithConfiguration: config
                                                                                      erroredState: @"create"
                                                                                              code: kUADSErrorStateNetworkConfigRequest
                                                                                           message: @"not found"];

    XCTestExpectation *expectation1 = [self expectationWithDescription: @"expectation"];
    XCTestExpectation *expectation2 = [self expectationWithDescription: @"delegate call"];

    initializationDelegate.expectation = expectation2;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue, ^{
        [errorState execute];
        [expectation1 fulfill];
    });
    [self waitForExpectationsWithTimeout: 60
                                 handler: ^(NSError *_Nullable error) {
                                 }];

    XCTAssertEqual(1, initializationDelegate.didInitializeFailedErrorMessage.count);
    XCTAssertEqual(kUnityInitializationErrorInternalError, initializationDelegate.didInitializeFailedError);
    XCTAssertEqualObjects(@[@"Unity Ads failed to initialize due to internal error"], initializationDelegate.didInitializeFailedErrorMessage);
    XCTAssertNil([[UADSTokenStorage sharedInstance] getToken], @"Token should be nil if initialization fails");
} /* testInitializeStateErrorTriggerInitializeFailed */

- (void)testInitializeStateCreateFailedAndTriggerCorrectErrorMessageFromWebView {
    UnityAdsInitializationDelegateMock *initializationDelegate = [[UnityAdsInitializationDelegateMock alloc] init];

    [USRVSdkProperties addInitializationDelegate: initializationDelegate];

    NSString *url = @"https://www.example.com/handlecallback.html";
    NSString *data = @"<script>window.webkit.messageHandlers.handleInvocation.postMessage(JSON.stringify([[\"USRVApiSdk\",\"initError\", ['error from webview', 1], \"0\"]]));</script>";
    NSString *hash = [data uads_sha256];

    [data writeToFile: [USRVSdkProperties getLocalWebViewFile]
           atomically: YES
             encoding: NSUTF8StringEncoding
                error: nil];

    USRVConfiguration *config = [[USRVConfiguration alloc] init];

    [config setWebViewUrl: url];
    [config setWebViewHash: hash];
    [config setWebViewData: data];

    __block id nextState = NULL;
    __block id finalState;

    [USRVWebViewApp setCurrentApp: nil];
    USRVInitializeStateCreate *createState = [[USRVInitializeStateCreate alloc] initWithConfiguration: config
                                                                                          webViewData: data];

    XCTestExpectation *expectation1 = [self expectationWithDescription: @"expectation"];
    XCTestExpectation *expectation2 = [self expectationWithDescription: @"delegate call"];

    initializationDelegate.expectation = expectation2;

    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue, ^{
        nextState = [createState execute];
        finalState = [nextState execute];
        [expectation1 fulfill];
    });

    [self waitForExpectationsWithTimeout: 60
                                 handler: ^(NSError *_Nullable error) {
                                 }];

    XCTAssertFalse([[USRVWebViewApp getCurrentApp] isWebAppInitialized]);
    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateError class]], @"Next state should be 'Error'");
    XCTAssertNil(finalState, @"Final state should be NULL");

    XCTAssertEqual(1, initializationDelegate.didInitializeFailedErrorMessage.count);
    XCTAssertEqual(kUnityInitializationErrorInternalError, initializationDelegate.didInitializeFailedError);
    XCTAssertEqualObjects(@[@"error from webview"], initializationDelegate.didInitializeFailedErrorMessage);
} /* testInitializeStateCreateFailedAndTriggerCorrectErrorMessageFromWebView */

- (void)testInitializeStateForceResetSetNotInitialized {
    USRVConfiguration *config = [[USRVConfiguration alloc] init];
    USRVInitializeStateForceReset *state = [[USRVInitializeStateForceReset alloc] initWithConfiguration: config];
    __block id nextState = NULL;

    XCTestExpectation *expectation1 = [self expectationWithDescription: @"expectation"];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

    dispatch_async(queue, ^{
        nextState = [state execute];
        [expectation1 fulfill];
    });

    [self waitForExpectationsWithTimeout: 60
                                 handler: ^(NSError *_Nullable error) {
                                 }];

    XCTAssertEqual(NOT_INITIALIZED, [USRVSdkProperties getCurrentInitializationState]);
}

- (void)testInitializeStateLoadCacheConfigAndWebViewNoCachedConfig {
    USRVConfiguration *config = [[USRVConfiguration alloc] init];

    NSString *data = @"<script>window.webkit.messageHandlers.handleInvocation.postMessage(JSON.stringify([[\"USRVApiSdk\",\"initComplete\", [], \"1\"]]));</script>";

    [data writeToFile: [USRVSdkProperties getLocalWebViewFile]
           atomically: YES
             encoding: NSUTF8StringEncoding
                error: nil];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalWebViewFile]], @"WebView data should exist in cache");
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalConfigFilepath]], @"Configuration data should NOT exist in cache");

    USRVInitializeStateLoadCacheConfigAndWebView *loadCachedConfigAndWebView = [[USRVInitializeStateLoadCacheConfigAndWebView alloc] initWithConfiguration: config];
    USRVInitializeState *nextState = [loadCachedConfigAndWebView execute];

    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateCheckForUpdatedWebView class]], @"Next state should be 'Check For Updated WebView'");
}

- (void)testInitializeStateLoadCacheConfigAndWebViewNoCachedWebView {
    USRVConfiguration *config = [[USRVConfiguration alloc] init];

    NSString *data = @"Random config data";

    [data writeToFile: [USRVSdkProperties getLocalConfigFilepath]
           atomically: YES
             encoding: NSUTF8StringEncoding
                error: nil];
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalWebViewFile]], @"WebView data should NOT exist in cache");
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalConfigFilepath]], @"Configuration data should exist in cache");

    USRVInitializeStateLoadCacheConfigAndWebView *loadCachedConfigAndWebView = [[USRVInitializeStateLoadCacheConfigAndWebView alloc] initWithConfiguration: config];
    USRVInitializeState *nextState = [loadCachedConfigAndWebView execute];

    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateCleanCache class]], @"Next state should be 'Clean Cache'");
}

- (void)testInitializeStateLoadCacheConfigAndWebView {
    USRVConfiguration *config = [[USRVConfiguration alloc] init];

    NSString *configData = @"Random config data";
    NSString *webViewData = @"Random webView data";

    [configData writeToFile: [USRVSdkProperties getLocalConfigFilepath]
                 atomically: YES
                   encoding: NSUTF8StringEncoding
                      error: nil];
    [webViewData writeToFile: [USRVSdkProperties getLocalWebViewFile]
                  atomically: YES
                    encoding: NSUTF8StringEncoding
                       error: nil];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalWebViewFile]], @"WebView data should exist in cache");
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalConfigFilepath]], @"Configuration data should exist in cache");

    USRVInitializeStateLoadCacheConfigAndWebView *loadCachedConfigAndWebView = [[USRVInitializeStateLoadCacheConfigAndWebView alloc] initWithConfiguration: config];
    USRVInitializeState *nextState = [loadCachedConfigAndWebView execute];

    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateCheckForUpdatedWebView class]], @"Next state should be 'Check For Updated WebView'");
} /* testInitializeStateLoadCacheConfigAndWebView */

- (void)testInitializeStateCleanCacheNothingInCache {
    USRVConfiguration *config = [[USRVConfiguration alloc] init];

    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalWebViewFile]], @"WebView data should NOT exist in cache");
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalConfigFilepath]], @"Configuration data should NOT exist in cache");

    // USRVInitializeStateComplete
    USRVInitializeStateComplete *completeState = [[USRVInitializeStateComplete alloc] initWithConfiguration: config];
    USRVInitializeStateCleanCache *loadCachedConfigAndWebView = [[USRVInitializeStateCleanCache alloc] initWithConfiguration: config
                                                                                                                   nextState: completeState];
    USRVInitializeState *nextState = [loadCachedConfigAndWebView execute];

    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateComplete class]], @"Next state should be 'Complete'");
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalWebViewFile]], @"WebView data should NOT exist in cache");
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalConfigFilepath]], @"Configuration data should NOT exist in cache");
}

- (void)testInitializeStateCleanCache {
    USRVConfiguration *config = [[USRVConfiguration alloc] init];

    NSString *configData = @"Random config data";
    NSString *webViewData = @"Random webView data";

    [configData writeToFile: [USRVSdkProperties getLocalConfigFilepath]
                 atomically: YES
                   encoding: NSUTF8StringEncoding
                      error: nil];
    [webViewData writeToFile: [USRVSdkProperties getLocalWebViewFile]
                  atomically: YES
                    encoding: NSUTF8StringEncoding
                       error: nil];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalWebViewFile]], @"WebView data should exist in cache");
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalConfigFilepath]], @"Configuration data should exist in cache");

    // USRVInitializeStateComplete
    USRVInitializeStateComplete *completeState = [[USRVInitializeStateComplete alloc] initWithConfiguration: config];
    USRVInitializeStateCleanCache *loadCachedConfigAndWebView = [[USRVInitializeStateCleanCache alloc] initWithConfiguration: config
                                                                                                                   nextState: completeState];
    USRVInitializeState *nextState = [loadCachedConfigAndWebView execute];

    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateComplete class]], @"Next state should be 'Complete'");
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalWebViewFile]], @"WebView data should NOT exist in cache");
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalConfigFilepath]], @"Configuration data should NOT exist in cache");
} /* testInitializeStateCleanCache */

- (void)testInitializeCheckForUpdatedWebViewUpdatedConfig {
    USRVConfiguration *downloadedConfig = [[USRVConfiguration alloc] init];
    USRVConfiguration *localConfig = [[USRVConfiguration alloc] init];

    NSString *webViewData = @"Random webView data";
    NSString *webViewData2 = @"Different webView data";

    [webViewData writeToFile: [USRVSdkProperties getLocalWebViewFile]
                  atomically: YES
                    encoding: NSUTF8StringEncoding
                       error: nil];

    [localConfig setWebViewData: webViewData];
    [localConfig setWebViewHash: [webViewData uads_sha256]];
    [localConfig setSdkVersion: [USRVSdkProperties getVersionName]];

    [downloadedConfig setWebViewData: webViewData2];
    [downloadedConfig setWebViewHash: [webViewData2 uads_sha256]];

    USRVInitializeStateCheckForUpdatedWebView *checkForUpdatedWebView = [[USRVInitializeStateCheckForUpdatedWebView alloc] initWithConfiguration: downloadedConfig
                                                                                                                              localConfiguration: localConfig];
    USRVInitializeState *nextState = [checkForUpdatedWebView execute];

    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateCreate class]], @"Next state should be 'Complete'");
    XCTAssertNotNil([USRVSdkProperties getLatestConfiguration], "latestConfig should match local config");
} /* testInitializeCheckForUpdatedWebViewUpdatedConfig */

- (void)testInitializeCheckForUpdatedWebViewNoUpdate {
    USRVConfiguration *downloadedConfig = [[USRVConfiguration alloc] init];
    USRVConfiguration *localConfig = [[USRVConfiguration alloc] init];

    NSString *webViewData = @"Random webView data";

    [webViewData writeToFile: [USRVSdkProperties getLocalWebViewFile]
                  atomically: YES
                    encoding: NSUTF8StringEncoding
                       error: nil];

    [localConfig setWebViewData: webViewData];
    [localConfig setWebViewHash: [webViewData uads_sha256]];

    [downloadedConfig setWebViewData: webViewData];
    [downloadedConfig setWebViewHash: [webViewData uads_sha256]];

    USRVInitializeStateCheckForUpdatedWebView *checkForUpdatedWebView = [[USRVInitializeStateCheckForUpdatedWebView alloc] initWithConfiguration: downloadedConfig
                                                                                                                              localConfiguration: localConfig];
    USRVInitializeState *nextState = [checkForUpdatedWebView execute];

    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateCreate class]], @"Next state should be 'Complete'");
    XCTAssertNil([USRVSdkProperties getLatestConfiguration], "latestConfig should be null");
} /* testInitializeCheckForUpdatedWebViewNoUpdate */

- (void)testInitializeStateUpdateCache {
    USRVConfiguration *localConfig = [[USRVConfiguration alloc] init];

    localConfig.configUrl = @"configUrl";
    localConfig.webViewUrl = @"webViewUrl";
    localConfig.webViewHash = @"hash";
    localConfig.webViewVersion = @"webViewVersion";
    localConfig.delayWebViewUpdate = true;
    NSString *webViewData = @"Random webView data";

    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalWebViewFile]], @"WebView data should NOT exist in cache");
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalConfigFilepath]], @"Configuration data should NOT exist in cache");

    USRVInitializeStateUpdateCache *updateCache = [[USRVInitializeStateUpdateCache alloc] initWithConfiguration: localConfig
                                                                                                    webViewData: webViewData];
    USRVInitializeState *nextState = [updateCache execute];

    XCTAssertNil(nextState, "Next state should be null");
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalWebViewFile]], @"WebView data should exist in cache");
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalConfigFilepath]], @"Configuration data should exist in cache");
} /* testInitializeStateUpdateCache */

- (void)testUSRVInitializeStateCheckForCachedWebViewUpdateUpdateCache {
    USRVConfiguration *localConfig = [[USRVConfiguration alloc] init];

    localConfig.configUrl = @"configUrl";
    localConfig.webViewUrl = @"webViewUrl";
    localConfig.webViewVersion = @"webViewVersion";
    localConfig.delayWebViewUpdate = true;

    NSString *webViewData = @"Random webView data";

    localConfig.webViewHash = [webViewData uads_sha256];
    [webViewData writeToFile: [USRVSdkProperties getLocalWebViewFile]
                  atomically: YES
                    encoding: NSUTF8StringEncoding
                       error: nil];

    USRVInitializeStateCheckForCachedWebViewUpdate *updateCache = [[USRVInitializeStateCheckForCachedWebViewUpdate alloc] initWithConfiguration: localConfig];
    USRVInitializeState *nextState = [updateCache execute];

    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateUpdateCache class]], @"Next state should be 'Update Cache'");
} /* testUSRVInitializeStateCheckForCachedWebViewUpdateUpdateCache */

- (void)testUSRVInitializeStateCheckForCachedWebViewUpdateDownloadUpdate {
    USRVConfiguration *localConfig = [[USRVConfiguration alloc] init];

    localConfig.configUrl = @"configUrl";
    localConfig.webViewUrl = @"webViewUrl";
    localConfig.webViewVersion = @"webViewVersion";
    localConfig.delayWebViewUpdate = true;

    NSString *webViewData = @"Random webView data";

    localConfig.webViewHash = [webViewData uads_sha256];

    USRVInitializeStateCheckForCachedWebViewUpdate *updateCache = [[USRVInitializeStateCheckForCachedWebViewUpdate alloc] initWithConfiguration: localConfig];
    USRVInitializeState *nextState = [updateCache execute];

    XCTAssertTrue([nextState isKindOfClass: [USRVInitializeStateDownloadLatestWebView class]], @"Next state should be 'Download Latest WebView'");
}

//- (void)testUSRVInitializeDownloadLatestWebViewNullQueue {
//    USRVConfiguration *localConfig = [[USRVConfiguration alloc] init];
//
//    [USRVSdkProperties setLatestConfiguration: localConfig];
//
//    USRVDownloadLatestWebViewStatus status = [USRVInitialize downloadLatestWebView];
//
//    XCTAssertEqual(status, kDownloadLatestWebViewStatusInitQueueNull, @"Status should be kDownloadLatestWebViewStatusInitQueueNull");
//}

@end
