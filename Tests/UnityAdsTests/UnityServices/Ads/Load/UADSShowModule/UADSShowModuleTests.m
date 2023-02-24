#import <XCTest/XCTest.h>
#import "UADSShowModule.h"
#import "UADSWebViewInvokerMock.h"
#import "UnityAdsShowDelegateMock.h"
#import "USRVSdkProperties.h"
#import "UADSEventHandlerMock.h"
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
@property (nonatomic, strong) UADSEventHandlerMock *eventHandlerMock;
@end

@implementation UADSShowModuleTests

- (void)setUp {
    self.showDelegateMock = [UnityAdsShowDelegateMock new];
    self.invokerMock = [UADSWebViewInvokerMock new];
    self.eventHandlerMock = [UADSEventHandlerMock new];
    self.moduleToTest = [UADSShowModule newWithInvoker: _invokerMock
                                       andEventHandler: _eventHandlerMock
                                          timerFactory: [UADSTimerFactoryBase new]];
}

- (void)test_calls_invoker_if_sdk_initialized {
    [self executeTestFlowToTestEvent: true
                 andFulfillmentCount: 2
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
                 andFulfillmentCount: 1
                        andTestEvent: ^{}];
    [self validateEventHandlerIsCalledOnceWithError];
    XCTAssertEqual(_invokerMock.invokerCalledNumberOfTimes, 0);
    XCTAssertEqual(_showDelegateMock.startedPlacements.count, 0);
    XCTAssertEqual(_showDelegateMock.failedPlacements.count, 1);
    XCTAssertEqualObjects(_showDelegateMock.failedReasons.lastObject, @(kUnityShowErrorInvalidArgument));
    XCTAssertEqual(_showDelegateMock.completedPlacements.count, 0);
    XCTAssertEqual(_showDelegateMock.clickedPlacements.count, 0);
}

- (void)test_should_not_call_invoker_if_sdk_not_initialized {
    [self executeTestFlowToTestEvent: false
                 andFulfillmentCount: 1
                        andTestEvent: ^{
                            [self emulateSendStartEvent];
                        }];
    [self validateEventHandlerIsCalledOnceWithError];
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
                 andFulfillmentCount: 2
                        andTestEvent: ^{
                            [self emulateSendFailure];
                        }];
    [self validateEventHandlerIsCalledOnceWithError];
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
                 andFulfillmentCount: 2
                        andTestEvent: ^{
                            [self emulateSendComplete];
                        }];
    [self validateEventHandlerIsCalledOnceWithSuccess];
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
                 andFulfillmentCount: 2
                        andTestEvent: ^{
                            [self emulateSendClick];
                        }];
}

- (void)test_calls_event_handler_for_multiple_successful_loads {
    [self setDefaultConfiguration];
    [self setInitialized: YES];
    NSString *op1Id = [self emulateShowCallAndStartWithPlacementId: @"placement1"];
    NSString *op2Id = [self emulateShowCallAndStartWithPlacementId: @"placement2"];

    [self emulateSendCompleteWithPlacementId: @"placement1"
                                 operationId: op1Id];
    [self emulateSendCompleteWithPlacementId: @"placement2"
                                 operationId: op2Id];

    [self validateEventHandlerIsCalledOnceWithSuccessForIds: @[op1Id, op2Id]];
}

- (void)test_calls_event_handler_for_multiple_failed_loads {
    [self setDefaultConfiguration];
    [self setInitialized: YES];

    NSString *op1Id = [self emulateShowCallAndStartWithPlacementId: @"placement1"];
    NSString *op2Id = [self emulateShowCallAndStartWithPlacementId: @"placement2"];

    [self emulateSendFailureWithPlacementId: @"placement1"
                                operationId: op1Id];
    [self emulateSendFailureWithPlacementId: @"placement2"
                                operationId: op2Id];

    [self validateEventHandlerIsCalledOnceWithErrorForIds: @[op1Id, op2Id]];
}

- (void)executeTestFlowToTestEvent: (BOOL)initialized
               andFulfillmentCount: (NSInteger)fulfillmentCount
                      andTestEvent: (NS_NOESCAPE VoidCompletion)testEvent {
    [self executeTestFlowToTestEvent: initialized
                     withPlacementID: kUADSShowModuleTestsPlacementID
                 andFulfillmentCount: fulfillmentCount
                        andTestEvent: testEvent];
}

- (void)executeTestFlowToTestEvent: (BOOL)initialized
                   withPlacementID: (NSString *)placementID
               andFulfillmentCount: (NSInteger)fulfillmentCount
                      andTestEvent: (NS_NOESCAPE VoidCompletion)testEvent {
    [self setDefaultConfiguration];
    [self setExpectationInDelegateWithCount: fulfillmentCount];
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

- (NSString *)emulateShowCallAndStartWithPlacementId: (NSString *)placementId {
    [self emulateShowCallWithPlacementID: placementId];
    NSString *opId = self.lastParamsInInvoker.id;

    [_moduleToTest sendShowStartEvent: placementId
                           listenerID: opId];
    return opId;
}

- (void)emulateSendCompleteWithPlacementId: (NSString *)placementId operationId: (NSString *)operationId {
    [_moduleToTest sendShowCompleteEvent: placementId
                              listenerID: operationId
                                   state: DEFAULT_COMPLETE_STATE];
}

- (void)emulateSendFailureWithPlacementId: (NSString *)placementId operationId: (NSString *)operationId {
    [_moduleToTest sendShowFailedEvent: placementId
                            listenerID: operationId
                               message: kUADSShowModuleTestsErrorMSG
                                 error: DEFAULT_ERROR];
}

- (void)emulateSendFailure {
    [self emulateSendFailureWithPlacementId: kUADSShowModuleTestsPlacementID
                                operationId: self.lastParamsInInvoker.id];
}

- (void)emulateSendComplete {
    [self emulateSendCompleteWithPlacementId: kUADSShowModuleTestsPlacementID
                                 operationId: self.lastParamsInInvoker.id];
}

- (void)emulateSendClick {
    [_moduleToTest sendShowClickEvent: kUADSShowModuleTestsPlacementID
                           listenerID: self.lastParamsInInvoker.id];
}

- (void)validateEventHandlerIsCalledOnceWithSuccessForIds: (NSArray *)opIds {
    XCTAssertEqual(_eventHandlerMock.startedCalls.count, opIds.count);
    XCTAssertEqual(_eventHandlerMock.onSuccessCalls.count, opIds.count);

    for (NSString *opId in opIds) {
        XCTAssertEqualObjects(_eventHandlerMock.startedCalls[opId], @(1));
        XCTAssertEqualObjects(_eventHandlerMock.onSuccessCalls[opId], @(1));
    }
}

- (void)validateEventHandlerIsCalledOnceWithErrorForIds: (NSArray *)opIds {
    XCTAssertEqual(_eventHandlerMock.startedCalls.count, opIds.count ? : 1);
    XCTAssertEqual(_eventHandlerMock.errors.count, opIds.count ? : 1);

    for (NSString *opId in opIds) {
        XCTAssertEqualObjects(_eventHandlerMock.startedCalls[opId], @(1));
        XCTAssertEqual(_eventHandlerMock.errors[opId].count, 1);
    }
}

- (void)validateEventHandlerIsCalledOnceWithSuccess {
    [self validateEventHandlerIsCalledOnceWithSuccessForIds: @[self.lastParamsInInvoker.id]];
}

- (void)validateEventHandlerIsCalledOnceWithError {
    [self validateEventHandlerIsCalledOnceWithErrorForIds: self.lastParamsInInvoker.id ? @[self.lastParamsInInvoker.id] : nil];
}

#warning should avoid using global states, the object should depend on the configuration reader
- (void)setDefaultConfiguration {
    USRVConfiguration *config = [USRVConfiguration new];

    config.showTimeout = 1000;
    [UADSAbstractModule setConfiguration: config];
}

- (void)await {
    [self waitForExpectations:@[_showDelegateMock.expectation]
                      timeout: DEFAULT_TEST_WAIT_TIME];
}

- (void)setExpectationInDelegateWithCount: (NSUInteger)count {
    XCTestExpectation *exp = self.defaultExpectation;
    _showDelegateMock.expectation = exp;
    _invokerMock.expectation = exp;
    exp.expectedFulfillmentCount = count;

}

- (void)emulateSendStartEvent {
    [_moduleToTest sendShowStartEvent: kUADSShowModuleTestsPlacementID
                           listenerID: self.lastParamsInInvoker.id];
}

- (id<UADSAbstractModuleOperationObject>)lastParamsInInvoker {
    return (id<UADSAbstractModuleOperationObject>)_invokerMock.operations.lastObject;
}

- (XCTestExpectation *)defaultExpectation {
    return [self expectationWithDescription: @"UADSShowModuleTests.Expectation"];
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
