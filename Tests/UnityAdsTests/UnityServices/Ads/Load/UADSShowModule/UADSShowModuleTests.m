#import <XCTest/XCTest.h>
#import "UADSShowModule.h"
#import "UADSWebViewInvokerMock.h"
#import "UnityAdsShowDelegateMock.h"
#import "USRVSdkProperties.h"
#import "UADSErrorHandlerMock.h"
static NSString *const kUADSShowModuleTestsPlacementID = @"kUADSShowModuleTestsPlacementID";
static NSString *const kUADSShowModuleTestsErrorMSG = @"kUADSShowModuleTestsErrorMSG";

#define DEFAULT_TEST_WAIT_TIME 10.0
#define DEFAULT_ERROR          kUnityShowErrorNoConnection
#define DEFAULT_COMPLETE_STATE kUnityShowCompletionStateCompleted
#define DEFAULT_SLEEP_TIME     0.5
typedef void (^VoidCompletion)(void);

@interface UADSShowModuleTests : XCTestCase
@property (nonatomic, strong) UADSWebViewInvokerMock *invokerMock;
@property (nonatomic, strong) UnityAdsShowDelegateMock *showDelegateMock;
@property (nonatomic, strong) UADSShowModule *moduleToTest;
@property (nonatomic, strong) UADSErrorHandlerMock *errorHandlerMock;
@end

@implementation UADSShowModuleTests

- (void)setUp {
    self.showDelegateMock = [UnityAdsShowDelegateMock new];
    self.invokerMock = [UADSWebViewInvokerMock new];
    self.errorHandlerMock = [UADSErrorHandlerMock new];
    self.moduleToTest = [UADSShowModule newWithInvoker: _invokerMock
                                       andErrorHandler: _errorHandlerMock];
}

- (void)test_calls_invoker_if_sdk_initialized {
    [self executeTestFlowToTestEvent: true
                        andTestEvent: ^{
                            [self emulateSendStartEvent];
                        }];
    XCTAssertEqual(_invokerMock.invokerCalledNumberOfTimes, 1);
    XCTAssertEqual(_showDelegateMock.startedPlacements.count, 1);
    XCTAssertEqualObjects(_showDelegateMock.startedPlacements.lastObject, kUADSShowModuleTestsPlacementID);
    XCTAssertEqual(_showDelegateMock.failedPlacements.count, 0);
    XCTAssertEqual(_showDelegateMock.completedPlacements.count, 0);
    XCTAssertEqual(_showDelegateMock.clickedPlacements.count, 0);
}

- (void)test_null_placementID_returns_error {
    [self executeTestFlowToTestEvent: true
                     withPlacementID: nil
                        andTestEvent: ^{}];
    XCTAssertEqual(_invokerMock.invokerCalledNumberOfTimes, 0);
    XCTAssertEqual(_showDelegateMock.startedPlacements.count, 0);
    XCTAssertEqual(_showDelegateMock.failedPlacements.count, 1);
    XCTAssertEqualObjects(_showDelegateMock.failedReasons.lastObject, @(kUnityShowErrorInvalidArgument));
    XCTAssertEqual(_showDelegateMock.completedPlacements.count, 0);
    XCTAssertEqual(_showDelegateMock.clickedPlacements.count, 0);
}

- (void)test_should_not_call_invoker_if_sdk_not_initialized {
    [self executeTestFlowToTestEvent: false
                        andTestEvent: ^{
                            [self emulateSendStartEvent];
                        }];
    XCTAssertEqual(_invokerMock.invokerCalledNumberOfTimes, 0);
    XCTAssertEqual(_showDelegateMock.startedPlacements.count, 0);
    XCTAssertEqual(_showDelegateMock.failedPlacements.count, 1);
    XCTAssertEqualObjects(_showDelegateMock.failedPlacements.lastObject, kUADSShowModuleTestsPlacementID);
    XCTAssertEqual(_showDelegateMock.completedPlacements.count, 0);
    XCTAssertEqual(_showDelegateMock.clickedPlacements.count, 0);
    XCTAssertEqualObjects(_showDelegateMock.failedReasons.lastObject, @(kUnityShowErrorNotInitialized));
}

- (void)test_passes_failure_to_a_delegate {
    [self executeTestFlowToTestEvent: true
                        andTestEvent: ^{
                            [self emulateSendFailure];
                        }];
    XCTAssertEqual(_invokerMock.invokerCalledNumberOfTimes, 1);
    XCTAssertEqual(_showDelegateMock.startedPlacements.count, 0);
    XCTAssertEqual(_showDelegateMock.failedPlacements.count, 1);
    XCTAssertEqualObjects(_showDelegateMock.failedPlacements.lastObject, kUADSShowModuleTestsPlacementID);
    XCTAssertEqual(_showDelegateMock.completedPlacements.count, 0);
    XCTAssertEqual(_showDelegateMock.clickedPlacements.count, 0);
    XCTAssertEqualObjects(_showDelegateMock.failedReasons.lastObject, @(DEFAULT_ERROR));
}

- (void)test_sends_click_event_to_a_delegate {
    [self executeTestFlowToTestEvent: true
                        andTestEvent: ^{
                            [self emulateSendComplete];
                        }];
    XCTAssertEqual(_invokerMock.invokerCalledNumberOfTimes, 1);
    XCTAssertEqual(_showDelegateMock.startedPlacements.count, 0);
    XCTAssertEqual(_showDelegateMock.failedPlacements.count, 0);
    XCTAssertEqualObjects(_showDelegateMock.completedPlacements.lastObject,
                          kUADSShowModuleTestsPlacementID);
    XCTAssertEqual(_showDelegateMock.completedPlacements.count, 1);
    XCTAssertEqual(_showDelegateMock.clickedPlacements.count, 0);
}

- (void)test_sends_complete_event_to_a_delegate {
    [self executeTestFlowToTestEvent: true
                        andTestEvent: ^{
                            [self emulateSendClick];
                        }];
}

- (void)executeTestFlowToTestEvent: (BOOL)initialized
                      andTestEvent: (NS_NOESCAPE VoidCompletion)testEvent {
    [self executeTestFlowToTestEvent: initialized
                     withPlacementID: kUADSShowModuleTestsPlacementID
                        andTestEvent: testEvent];
}

- (void)executeTestFlowToTestEvent: (BOOL)initialized
                   withPlacementID: (NSString *)placementID
                      andTestEvent: (NS_NOESCAPE VoidCompletion)testEvent {
    [self setDefaultConfiguration];
    [self setExpectationInDelegate];
    [self setInitialized: initialized];
    [self emulateShowCallWithPlacementID: placementID];
    testEvent();
    [self await];
}

- (void)setInitialized: (BOOL)isInitialized {
    [USRVSdkProperties setInitialized: isInitialized];
}

- (void)emulateShowCallWithPlacementID: (NSString *)placementID {
    [_moduleToTest showAdForPlacementID: placementID
                            withOptions: [UADSShowOptions new]
                        andShowDelegate: _showDelegateMock];

    [self waitForTimeInterval: DEFAULT_SLEEP_TIME];
}

- (void)emulateSendFailure {
    [_moduleToTest sendShowFailedEvent: kUADSShowModuleTestsPlacementID
                            listenerID: self.lastParamsInInvoker.id
                               message: kUADSShowModuleTestsErrorMSG
                                 error: DEFAULT_ERROR];
}

#warning should avoid using global states, the object should depend on the configuration reader
- (void)setDefaultConfiguration {
    USRVConfiguration *config = [USRVConfiguration new];

    config.showTimeout = 1000;
    [UADSAbstractModule setConfiguration: config];
}

- (void)emulateSendComplete {
    [_moduleToTest sendShowCompleteEvent: kUADSShowModuleTestsPlacementID
                              listenerID: self.lastParamsInInvoker.id
                                   state: DEFAULT_COMPLETE_STATE];
}

- (void)emulateSendClick {
    [_moduleToTest sendShowClickEvent: kUADSShowModuleTestsPlacementID
                           listenerID: self.lastParamsInInvoker.id];
}

- (void)await {
    [self waitForExpectationsWithTimeout: DEFAULT_TEST_WAIT_TIME
                                 handler: nil];
}

- (void)setExpectationInDelegate {
    _showDelegateMock.expectation = self.defaultExpectation;
}

- (void)emulateSendStartEvent {
    [_moduleToTest sendShowStartEvent: kUADSShowModuleTestsPlacementID
                           listenerID: self.lastParamsInInvoker.id];
}

- (id<UADSAbstractModuleOperationObject>)lastParamsInInvoker {
    return (id<UADSAbstractModuleOperationObject>)_invokerMock.operations.lastObject;
}

- (XCTestExpectation *)defaultExpectation {
    return [self expectationWithDescription: @"UADSLoadModuleTests.Expectation"];
}

- (void)waitForTimeInterval: (NSTimeInterval)waitTime {
    XCTestExpectation *expectation = [self expectationWithDescription: @"wait.expectations"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, waitTime * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectations: @[expectation]
                      timeout: waitTime + 10];
}

@end
