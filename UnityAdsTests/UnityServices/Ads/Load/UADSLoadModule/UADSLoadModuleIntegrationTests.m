
#import <XCTest/XCTest.h>
#import "UnityAds.h"
#import "USRVWebViewAppMock.h"
#import "UnityAdsLoadDelegateMock.h"
#import "USRVSdkProperties.h"
#import "UADSLoadModule.h"
#import "USRVInitializationNotificationCenter.h"

static NSString * const kUADSLoadModuleTestsPlacementID = @"kUADSLoadModuleTestsPlacementID";
static NSString * const kSDKInitFailedMessage = @"kSDKInitFailedMessage";
#define DEFAULT_TEST_WAIT_TIME 10.0
#define DEFAULT_SLEEP_TIME 2

@interface UADSLoadModuleIntegrationTests : XCTestCase
@property (nonatomic, strong) USRVWebViewAppMock *webAppMock;
@property (nonatomic, strong) UnityAdsLoadDelegateMock* loadDelegateMock;
@end


@implementation UADSLoadModuleIntegrationTests

-(UADSLoadModule *)moduleToTest {
    return UADSLoadModule.sharedInstance;
}

-(USRVInitializationNotificationCenter *)notificationCenter {
    return USRVInitializationNotificationCenter.sharedInstance;
}

- (void)setUp {
    _webAppMock = [USRVWebViewAppMock new];
    [USRVWebViewApp setCurrentApp:_webAppMock];
    self.loadDelegateMock = [UnityAdsLoadDelegateMock new];
}

- (void)tearDown {
    _webAppMock = nil;
    _loadDelegateMock = nil;
    [USRVWebViewApp setCurrentApp: nil];
    [UADSLoadModule setConfiguration: [USRVConfiguration new]];
}


-(void)test_load_after_SDK_is_initialized_calls_web_view {
    [self emulateSDKInitialized: INITIALIZED_SUCCESSFULLY];
    [self emulateLoadCallWithPlacementID: kUADSLoadModuleTestsPlacementID];
    [self waitForTimeInterval: DEFAULT_SLEEP_TIME];
    XCTAssertEqual(_webAppMock.returnedParams.count, 1);
}


-(void)test_load_after_SDK_is_initialized {
    [self initializeCommonFlowWithSDKInitialized: INITIALIZED_SUCCESSFULLY];
    [self emulateInvokerSuccessResponse];
    [self emulateSendLoadedForTheLastListener];
    [self waitForExpectations:@[_loadDelegateMock.expectation] timeout: DEFAULT_TEST_WAIT_TIME];
    XCTAssertEqual(_loadDelegateMock.succeedPlacements.count, 1);
    XCTAssertEqual(_loadDelegateMock.failedPlacements.count, 0);
    XCTAssertEqual(_webAppMock.returnedParams.count, 1);
}


-(void)test_load_error_for_empty_placementID{
    [self setExpectationInDelegate];
    [self emulateSDKInitialized: INITIALIZED_SUCCESSFULLY];
    [self emulateLoadCallWithPlacementID: nil];
    [self waitForExpectations:@[_loadDelegateMock.expectation] timeout: DEFAULT_TEST_WAIT_TIME];
    XCTAssertEqual(_loadDelegateMock.succeedPlacements.count, 0);
    XCTAssertEqual(_loadDelegateMock.failedPlacements.count, 1);
    XCTAssertEqual(_webAppMock.returnedParams.count, 0);
    XCTAssertEqualObjects(_loadDelegateMock.errorCodes.lastObject, @(kUnityAdsLoadErrorInvalidArgument));
}

-(void)test_load_after_SDK_is_initialized_with_web_view_timeout{
    [self initializeCommonFlowWithSDKInitialized: INITIALIZED_SUCCESSFULLY];
    [self waitForExpectations:@[_loadDelegateMock.expectation] timeout: DEFAULT_TEST_WAIT_TIME];
    XCTAssertEqual(_loadDelegateMock.succeedPlacements.count, 0);
    XCTAssertEqual(_loadDelegateMock.failedPlacements.count, 1);
    XCTAssertEqual(_webAppMock.returnedParams.count, 1);
}

-(void)test_load_after_SDK_is_initialized_with_web_view_failed{
    [self initializeCommonFlowWithSDKInitialized: INITIALIZED_SUCCESSFULLY];
    [self emulateInvokerFailedResponse];
    [self waitForExpectations:@[_loadDelegateMock.expectation] timeout: DEFAULT_TEST_WAIT_TIME];
    XCTAssertEqual(_loadDelegateMock.succeedPlacements.count, 0);
    XCTAssertEqual(_loadDelegateMock.failedPlacements.count, 1);
    XCTAssertEqual(_webAppMock.returnedParams.count, 1);
}


-(void)test_load_after_SDK_is_initialized_with_web_view_failed_returns_internal_error {
    [self initializeCommonFlowWithSDKInitialized: INITIALIZED_SUCCESSFULLY];
    [self emulateInvokerFailedResponse];
    [self waitForExpectations:@[_loadDelegateMock.expectation] timeout: DEFAULT_TEST_WAIT_TIME];
    XCTAssertEqualObjects(_loadDelegateMock.errorCodes.lastObject, @(kUnityAdsLoadErrorInternal));
}

-(void)test_load_after_SDK_is_initialized_listener_cleanup {
    [self initializeCommonFlowWithSDKInitialized: INITIALIZED_SUCCESSFULLY];
    [self emulateInvokerSuccessResponse];
    [self emulateSendLoadedForTheLastListener];
    [self emulateSendLoadedForTheLastListener];
    [self waitForExpectations:@[_loadDelegateMock.expectation] timeout: DEFAULT_TEST_WAIT_TIME];
    XCTAssertEqual(_loadDelegateMock.succeedPlacements.count, 1);
    XCTAssertEqual(_loadDelegateMock.failedPlacements.count, 0);
    XCTAssertEqual(_webAppMock.returnedParams.count, 1);
 }

-(void)test_load_before_SDK_is_initialized_doesnt_call_web_view {
    [self emulateSDKInitialized: NOT_INITIALIZED];
    [self emulateLoadCallWithPlacementID: kUADSLoadModuleTestsPlacementID];
    [self waitForTimeInterval: DEFAULT_SLEEP_TIME];
    XCTAssertEqual(_webAppMock.returnedParams.count, 0);
 }

-(void)test_load_before_SDK_is_initialized {
    [self emulateSDKInitialized: NOT_INITIALIZED];
    [self setExpectationInDelegate];
    [self emulateLoadCallWithPlacementID: kUADSLoadModuleTestsPlacementID];
    [self waitForTimeInterval: DEFAULT_SLEEP_TIME];
    [self.notificationCenter triggerSdkDidInitialize];
    [self waitForTimeInterval: DEFAULT_SLEEP_TIME];
    [self emulateInvokerSuccessResponse];
    [self emulateSendLoadedForTheLastListener];
    [self waitForExpectations:@[_loadDelegateMock.expectation] timeout: DEFAULT_TEST_WAIT_TIME];
    XCTAssertEqual(_loadDelegateMock.succeedPlacements.count, 1);
    XCTAssertEqual(_loadDelegateMock.failedPlacements.count, 0);
    XCTAssertEqual(_webAppMock.returnedParams.count, 1);
 }


-(void)test_load_before_SDK_is_initialized_failed {
    [self emulateSDKInitialized: NOT_INITIALIZED];
    [self setExpectationInDelegate];
    [self emulateLoadCallWithPlacementID: kUADSLoadModuleTestsPlacementID];
    [self waitForTimeInterval: DEFAULT_SLEEP_TIME];
    [self.notificationCenter triggerSdkInitializeDidFail:kSDKInitFailedMessage code:@-1];
    [self waitForTimeInterval: DEFAULT_SLEEP_TIME];
    [self waitForExpectations:@[_loadDelegateMock.expectation] timeout: DEFAULT_TEST_WAIT_TIME];
    XCTAssertEqual(_loadDelegateMock.succeedPlacements.count, 0);
    XCTAssertEqual(_loadDelegateMock.failedPlacements.count, 1);
    XCTAssertEqual(_webAppMock.returnedParams.count, 0);
    XCTAssertEqualObjects(_loadDelegateMock.errorCodes.lastObject, @(kUnityAdsLoadErrorInitializeFailed));
 }

-(void)test_timeout_when_delegate_is_not_notified_from_the_web_view {
    [self setShorterOperationTTL];
    [self initializeCommonFlowWithSDKInitialized: INITIALIZED_SUCCESSFULLY];
    [self emulateInvokerSuccessResponse];
    [self waitForExpectations:@[_loadDelegateMock.expectation] timeout: DEFAULT_TEST_WAIT_TIME];
    XCTAssertEqual(_loadDelegateMock.succeedPlacements.count, 0);
    XCTAssertEqual(_loadDelegateMock.failedPlacements.count, 1);
    XCTAssertEqual(_webAppMock.returnedParams.count, 1);
    XCTAssertEqualObjects(_loadDelegateMock.errorCodes.lastObject, @(kUnityAdsLoadErrorTimeout));
}

- (void)waitForTimeInterval: (NSTimeInterval)waitTime {
    XCTestExpectation *expectation = [self expectationWithDescription: @"wait.expectations"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, waitTime * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectations: @[expectation] timeout: waitTime + 10];
}

- (void)emulateLoadCallWithPlacementID: (NSString*)placementID {
    [self.moduleToTest loadForPlacementID: placementID options: [UADSLoadOptions new] loadDelegate: _loadDelegateMock];
}

- (void)emulateSendLoadedForTheLastListener {
    NSArray *passedArguments = _webAppMock.returnedParams.lastObject;
    NSDictionary *params = passedArguments.firstObject;
    NSString *listenerID = params[kUADSListenerIDKey];
    [self.moduleToTest sendAdLoadedForPlacementID: kUADSLoadModuleTestsPlacementID andListenerID:listenerID];
}

-(void)await {
    [self waitForExpectationsWithTimeout: DEFAULT_TEST_WAIT_TIME
                                 handler: nil];
}

-(void)setShorterOperationTTL {
    USRVConfiguration *config = [USRVConfiguration new];
    config.loadTimeout = 2000;
    [UADSLoadModule setConfiguration: config];
}

-(void)setExpectationInDelegate {
    _loadDelegateMock.expectation = self.defaultExpectation;
}

-(void)emulateInvokerSuccessResponse {
    [_webAppMock emulateResponseWithParams: @[@"OK"]];
}

-(void)emulateInvokerFailedResponse {
    [_webAppMock emulateResponseWithParams: @[]];
}

-(XCTestExpectation *)defaultExpectation {
    return [self expectationWithDescription: @"UADSLoadModuleIntegrationTests.Expectation"];
}

- (void)emulateSDKInitialized: (InitializationState)state {
    // Its not obvious why we need to set up.
    // However WebViewInvokerQueueDecorator calls USRVSdkProperties.isInitialized inside its implementation
    // To test the flow we need to setUp the flag explicitly
    [USRVSdkProperties setInitializationState: state];
}

-(void)setWebViewExpectation {
    self.webAppMock.expectation =  [self expectationWithDescription: @"WebViewMock_Expectation"];
}

-(void)initializeCommonFlowWithSDKInitialized: (InitializationState)state {
    [self setExpectationInDelegate];
    [self setWebViewExpectation];
    [self emulateSDKInitialized: state];
    [self emulateLoadCallWithPlacementID: kUADSLoadModuleTestsPlacementID];
    [self waitForExpectations:@[_webAppMock.expectation] timeout:DEFAULT_TEST_WAIT_TIME];
}

@end
