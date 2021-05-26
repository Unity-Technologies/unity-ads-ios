#import <XCTest/XCTest.h>
#import "UnityAds.h"
#import "USRVWebViewAppMock.h"
#import "UnityAdsShowDelegateMock.h"
#import "USRVSdkProperties.h"
#import "USRVInitializationNotificationCenter.h"
#import "UADSShowModule.h"
#import "UIViewControllerMock.h"
#import "UnityAdsShowCompletionState.h"

static NSString * const kUADSLoadModuleTestsPlacementID = @"kUADSLoadModuleTestsPlacementID";
static NSString * const kSDKInitFailedMessage = @"kSDKInitFailedMessage";
#define DEFAULT_TEST_WAIT_TIME 10
#define DEFAULT_SLEEP_TIME 3


@interface UADSShowModuleIntegrationTests : XCTestCase
@property (nonatomic, strong) USRVWebViewAppMock *webAppMock;
@property (nonatomic, strong) UnityAdsShowDelegateMock* showDelegateMock;
@end


@implementation UADSShowModuleIntegrationTests

- (void)setUp {
    _webAppMock = [USRVWebViewAppMock new];
    [USRVWebViewApp setCurrentApp:_webAppMock];
    [self setConfigurationWithShorterTimeouts];
    self.showDelegateMock = [UnityAdsShowDelegateMock new];
}

- (void)tearDown {
    [self emulateInvokerSuccessResponse];
    _webAppMock = nil;
    _showDelegateMock = nil;
    [self emulateSDKInitialized: false];
    [USRVWebViewApp setCurrentApp: nil];
    [UADSShowModule setConfiguration: [USRVConfiguration new]];
}

-(UADSShowModule *)moduleToTest {
    return UADSShowModule.sharedInstance;
}


- (void)test_sends_failure_to_the_delegate_if_sdk_is_not_initialized {
    [self setExpectationInDelegate];
    [self emulateSDKInitialized: false];
    [self emulateShowCallWithPlacementID: kUADSLoadModuleTestsPlacementID];

    [self waitForDelegateExpectationFulfill];
    
    XCTAssertEqual(kUADSLoadModuleTestsPlacementID, _showDelegateMock.failedPlacements.lastObject);
    [self validateDelegateHasFailedPlacements:1
                          completedPlacements:0
                            clickedPlacements:0
                            startedPlacements:0];
    [self validateShowFailedForAReason: kUnityShowErrorNotInitialized];
}


- (void)test_sends_web_view_call_if_sdk_initialized {
    [self setExpectationInDelegate];
    [self initializeCommonFlowWithSDKInitialized: true
                                 withPlacementID: kUADSLoadModuleTestsPlacementID];
    [self emulateInvokerSuccessResponse];
    [self.moduleToTest sendShowCompleteEvent: kUADSLoadModuleTestsPlacementID
                                  listenerID: self.lastListenerID
                                       state: kUnityShowCompletionStateCompleted];
    
    [self waitForDelegateExpectationFulfill];
    
    XCTAssertEqual(kUADSLoadModuleTestsPlacementID, _showDelegateMock.completedPlacements.lastObject);
    [self validateDelegateHasFailedPlacements:0
                          completedPlacements:1
                            clickedPlacements:0
                            startedPlacements:0];
}

- (void)test_sends_show_internal_timeout_if_no_method_called_on_the_delegate {
    [self setExpectationInDelegate];
    [self initializeCommonFlowWithSDKInitialized: true
                                 withPlacementID: kUADSLoadModuleTestsPlacementID];
    [self emulateInvokerSuccessResponse];
    [self waitForDelegateExpectationFulfill];
    
    [self validateDelegateHasFailedPlacements: 1
                          completedPlacements: 0
                            clickedPlacements: 0
                            startedPlacements: 0];
    [self validateShowFailedForAReason: kUnityShowErrorInternalError];
}

- (void)test_sends_show_internal_timeout_if_web_view_timeout {
    [self setExpectationInDelegate];
    [self initializeCommonFlowWithSDKInitialized: true
                                 withPlacementID: kUADSLoadModuleTestsPlacementID];
    [self waitForDelegateExpectationFulfill];
  
    XCTAssertEqual(kUADSLoadModuleTestsPlacementID, _showDelegateMock.failedPlacements.lastObject);
    [self validateDelegateHasFailedPlacements: 1
                          completedPlacements: 0
                            clickedPlacements: 0
                            startedPlacements: 0];
    [self validateShowFailedForAReason: kUnityShowErrorInternalError];
}

- (void)test_show_complete_removes_delegate_from_the_storage {
    [self setExpectationInDelegate];
    [self initializeCommonFlowWithSDKInitialized: true
                                 withPlacementID: kUADSLoadModuleTestsPlacementID];
    
    [self.moduleToTest sendShowCompleteEvent: kUADSLoadModuleTestsPlacementID
                                  listenerID: self.lastListenerID
                                       state: kUnityShowCompletionStateCompleted];
    
    [self emulateSendClickForStorageRemovingTests];
    
    [self waitForDelegateExpectationFulfill];
  
    XCTAssertEqual(kUADSLoadModuleTestsPlacementID, _showDelegateMock.completedPlacements.lastObject);
    [self validateDelegateHasFailedPlacements: 0
                          completedPlacements: 1
                            clickedPlacements: 0
                            startedPlacements: 0];
  
}

- (void)test_invoker_failure_returns_internal_error {
    [self setExpectationInDelegate];
    [self initializeCommonFlowWithSDKInitialized: true
                                 withPlacementID: kUADSLoadModuleTestsPlacementID];
    [self emulateInvokerFailedResponse];
    [self waitForDelegateExpectationFulfill];
  
    XCTAssertEqual(kUADSLoadModuleTestsPlacementID, _showDelegateMock.failedPlacements.lastObject);
    [self validateDelegateHasFailedPlacements: 1
                          completedPlacements: 0
                            clickedPlacements: 0
                            startedPlacements: 0];
    [self validateShowFailedForAReason: kUnityShowErrorInternalError];
    
}


- (void)test_click_doesnt_remove_delegate_from_the_storage {
    [self initializeCommonFlowWithSDKInitialized: true withPlacementID:kUADSLoadModuleTestsPlacementID];
    [self emulateInvokerSuccessResponse];

    [self setExpectationInDelegate];
    [self emulateSendClickForStorageRemovingTests];
    [self waitForDelegateExpectationFulfill];
    
    [self setExpectationInDelegate];
    [self emulateSendClickForStorageRemovingTests];
    [self waitForDelegateExpectationFulfill];
    
    [self setExpectationInDelegate];
    [self emulateSendClickForStorageRemovingTests];
    [self waitForDelegateExpectationFulfill];
    
    [self setExpectationInDelegate];
    [self emulateSendClickForStorageRemovingTests];
    [self waitForDelegateExpectationFulfill];
    
    [self validateDelegateHasFailedPlacements: 0
                          completedPlacements: 0
                            clickedPlacements: 4
                            startedPlacements: 0];
}


- (void)test_show_consent_doesnt_remove_delegate_from_the_storage {
    [self initializeCommonFlowWithSDKInitialized: true withPlacementID:kUADSLoadModuleTestsPlacementID];
    [self emulateInvokerSuccessResponse];

    
    /**
        since we dont have public API exposed for show Consent, the only way to test that consent doesnt remove the listener is by assuming the next
            - if the listener is not removed than we should be able to send Click event as many times as we want
            - if the listener is removed then the test will fail with the timeout and unfulfilled expectations
     */
    
    [self emulateSendShowConsentForStorageRemovingTests];
    [self waitForTimeInterval: 1];
    [self setExpectationInDelegate];
    [self emulateSendClickForStorageRemovingTests];
    [self waitForDelegateExpectationFulfill];
    
    [self validateDelegateHasFailedPlacements: 0
                          completedPlacements: 0
                            clickedPlacements: 1
                            startedPlacements: 0];
}



- (void)test_show_failed_removes_delegate_from_the_storage {
    [self setExpectationInDelegate];
    [self initializeCommonFlowWithSDKInitialized: true withPlacementID:kUADSLoadModuleTestsPlacementID];
    [self emulateInvokerSuccessResponse];

    
    [self.moduleToTest sendShowFailedEvent: kUADSLoadModuleTestsPlacementID
                                listenerID: self.lastListenerID message:@"ERROR"
                                     error: kUnityShowErrorInternalError];
    
    [self emulateSendClickForStorageRemovingTests];
    
    [self waitForDelegateExpectationFulfill];
  
    XCTAssertEqual(kUADSLoadModuleTestsPlacementID, _showDelegateMock.failedPlacements.lastObject);
    [self validateDelegateHasFailedPlacements: 1
                          completedPlacements: 0
                            clickedPlacements: 0
                            startedPlacements: 0];
    [self validateShowFailedForAReason: kUnityShowErrorInternalError];
  
}


- (void)validateDelegateHasFailedPlacements: (NSInteger)failedPlacementsCount
                          completedPlacements: (NSInteger)completedPlacementsCount
                          clickedPlacements: (NSInteger)clickedPlacementsCount
                          startedPlacements: (NSInteger)startedPlacementsCount {
    XCTAssertEqual(_showDelegateMock.failedPlacements.count, failedPlacementsCount);
    XCTAssertEqual(_showDelegateMock.clickedPlacements.count, clickedPlacementsCount);
    XCTAssertEqual(_showDelegateMock.completedPlacements.count, completedPlacementsCount);
    XCTAssertEqual(_showDelegateMock.startedPlacements.count, startedPlacementsCount);
}
- (void)validateShowFailedForAReason:(UnityAdsShowError)state {
    XCTAssertEqualObjects(_showDelegateMock.failedReasons.lastObject, @(state));
}

- (void)emulateSDKInitialized: (BOOL)state {
    // Its not obvious why we need to set up.
    // However WebViewInvokerQueueDecorator calls USRVSdkProperties.isInitialized inside its implementation
    // To test the flow we need to setUp the flag explicitly
    [USRVSdkProperties setInitialized: state];
}

-(void)setWebViewExpectation {
    self.webAppMock.expectation =  [self expectationWithDescription: @"WebViewMock_Expectation"];
}


-(void)initializeCommonFlowWithSDKInitialized: (BOOL)state withPlacementID: (NSString *)placementID {
    [self setWebViewExpectation];
    [self setConfigurationWithShorterTimeouts];
    [self emulateSDKInitialized: true];
    [self emulateShowCallWithPlacementID: kUADSLoadModuleTestsPlacementID];
    [self waitForExpectations:@[_webAppMock.expectation] timeout:DEFAULT_TEST_WAIT_TIME enforceOrder:true];

}

-(void)setExpectationInDelegate {
    _showDelegateMock.expectation = [self expectationWithDescription: @"UADSShowModuleIntegrationTests.Expectation"];;
}

-(void)emulateInvokerSuccessResponse {
    [_webAppMock emulateResponseWithParams: @[@"OK"]];
    [self waitForTimeInterval: 1];
}

-(void)emulateInvokerFailedResponse {
    [_webAppMock emulateResponseWithParams: @[]];
    [self waitForTimeInterval: 1];
}


-(void)emulateSendClickForStorageRemovingTests {
    [self.moduleToTest sendShowClickEvent: kUADSLoadModuleTestsPlacementID
                               listenerID: self.lastListenerID];
}

-(void)emulateSendShowConsentForStorageRemovingTests {
    [self.moduleToTest sendShowConsentEvent: kUADSLoadModuleTestsPlacementID
                                 listenerID: self.lastListenerID];
}

- (void)waitForTimeInterval: (NSTimeInterval)waitTime {
    XCTestExpectation *expectation = [self expectationWithDescription: @"wait.expectations"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, waitTime * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectations: @[expectation] timeout: waitTime + 10];
}

- (void)emulateShowCallWithPlacementID: (NSString*)placementID {
    [self.moduleToTest showAdForPlacementID: placementID
                                withOptions: [UADSShowOptions new]
                            andShowDelegate: _showDelegateMock];
}

- (void)waitForDelegateExpectationFulfill {
    [self waitForExpectations:@[_showDelegateMock.expectation] timeout:DEFAULT_TEST_WAIT_TIME];
}

-(NSString *)lastListenerID {
    NSArray *passedArguments = _webAppMock.returnedParams.lastObject;
    NSDictionary *params = passedArguments.firstObject;
    return params[kUADSListenerIDKey];
}

-(void)setConfigurationWithShorterTimeouts {
    USRVConfiguration *config = [USRVConfiguration new];
    config.showTimeout = 3000;
    config.webViewTimeout = 2000;
    [UADSShowModule setConfiguration: config];
}

@end
