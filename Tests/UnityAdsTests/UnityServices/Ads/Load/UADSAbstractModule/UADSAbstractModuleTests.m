#import "UnityAdsShowError.h"
#import "NSArray+Convenience.h"
#import "UADSAbstractTestModule.h"
#import "UADSErrorHandlerMock.h"
#import "UADSAbstractModule.h"
#import "UADSWebViewInvokerMock.h"
#import "UADSAbstractModuleDelegateMock.h"

static NSString *const kUADStDefaultPlacementID = @"UADSShowModuleTestDefaultPlacementID";
static NSString *const kUADSListenerID = @"kUADSListenerID";
static NSString *const kUADSTestDefaultMessage = @"kUADSTestDefaultMessage";


#define DEFAULT_TEST_WAIT_TIME 5.0


@interface UADSAbstractModuleTests : XCTestCase
@property (nonatomic, strong) UADSWebViewInvokerMock *invokerMock;
@property (nonatomic, strong) UADSAbstractModuleDelegateMock *delegateMock;
@property (nonatomic, strong) UADSAbstractModule *moduleToTest;
@property (nonatomic, strong) UADSErrorHandlerMock *errorHandlerMock;
@end


@implementation UADSAbstractModuleTests

- (void)setUp {
    self.delegateMock = [UADSAbstractModuleDelegateMock new];
    self.invokerMock = [UADSWebViewInvokerMock new];
    self.errorHandlerMock = [UADSErrorHandlerMock new];
    self.moduleToTest = [UADSAbstractTestModule newWithInvoker: _invokerMock
                                               andErrorHandler: _errorHandlerMock];
}

- (void)tearDown {
    _delegateMock = nil;
    _invokerMock = nil;
    _moduleToTest = nil;
    _errorHandlerMock = nil;
}

- (UADSAbstractTestModule *)module {
    return (UADSAbstractTestModule *)_moduleToTest;
}

- (void)test_show_falls_into_error_flow_doesnt_call_sender {
    [self setEmptyStateResponse];
    [self setDefaultExecutionError];
    [self emulateDefaultExecuteMethodCallWait: false];
    [self validateInvokerIsCalledNumberOfTimes: 0];
    [self validateDelegateIsCalledWithDefaultError];
    [self validateErrorHandlerIsCalledOnce];
}

- (void)test_show_calls_stateSender {
    [self setEmptyStateResponse];
    [self emulateDefaultExecuteMethodCall];
    [self validateInvokerIsCalledNumberOfTimes: 1];
    [self validateInvokerIsCalledWithDefaultIDs];
}

- (void)test_show_calls_delegate_fail_method_if_sender_fails {
    [self setEmptyStateResponse];
    [self emulateDefaultExecuteMethodCall];
    [self setExpectationInDelegate];
    [self emulateSenderDefaultErrorResponse];
    [self await];
    [self validateInvokerIsCalledNumberOfTimes: 1];
    [self validateInvokerIsCalledWithDefaultIDs];
    [self validateDelegateIsCalledWithDefaultError];
    [self validateErrorHandlerIsCalledOnce];
    XCTAssertEqual(1, _delegateMock.errors.count);
    XCTAssertEqualObjects(self.defaultInvokerError, _errorHandlerMock.errors.lastObject);
}

- (void)test_if_operation_expires_error_is_sent_to_delegate {
    [self setEmptyStateResponse];
    [self emulateDefaultExecuteMethodCall];
    [self emulateOperationTTL];
    [self waitForTimeInterval: 0.5];
    [self validateInvokerIsCalledNumberOfTimes: 1];
    [self validateInvokerIsCalledWithDefaultIDs];
    [self validateDelegateIsCalledNumberOfTimes: 1];
    [self validateErrorHandlerIsCalledOnce];
    XCTAssertEqual(1, _delegateMock.errors.count);
    XCTAssertEqualObjects(self.defaultExpectedExpirationError, _errorHandlerMock.errors.lastObject);
}

- (void)test_operation_expiration_removes_operation_from_the_storage {
    [self setEmptyStateResponse];
    [self emulateDefaultExecuteMethodCall];
    [self emulateOperationTTL];
    [self emulateOperationTTL];
    [self waitForTimeInterval: 0.5];
    [self validateInvokerIsCalledNumberOfTimes: 1];
    [self validateInvokerIsCalledWithDefaultIDs];
    [self validateDelegateIsCalledNumberOfTimes: 1];
    [self validateErrorHandlerIsCalledOnce];
    XCTAssertEqual(1, _delegateMock.errors.count);
}

- (void)test_invocation_failure_removes_operation_from_the_storage {
    [self setEmptyStateResponse];
    [self emulateDefaultExecuteMethodCall];
    [self emulateSenderDefaultErrorResponse];
    [self emulateSenderDefaultErrorResponse];
    [self waitForTimeInterval: 0.5];
    [self validateInvokerIsCalledNumberOfTimes: 1];
    [self validateInvokerIsCalledWithDefaultIDs];
    [self validateDelegateIsCalledWithDefaultError];
    [self validateErrorHandlerIsCalledOnce];
    [self validateDelegateIsCalledNumberOfTimes: 1];
}

// MARK: - Helper Methods. Should be extracted into Separate Tester Class

- (UIViewController *)fakeViewController {
    return [UIViewController new];
}

- (id<UADSDictionaryConvertible>)defaultOptions {
    // this is a hack for quick test and not creating a new object
    // Since each module will depend on id<UADSDictionaryConvertible>
    // and has own implementation of state creation
    // we can reuse state here as a fake options
    return self.emptyState;
}

- (void)setEmptyStateResponse {
    self.module.returnedState = self.emptyState;
}

- (void)setDefaultExecutionError {
    self.module.returnedExecutionError = self.defaultInvokerError;
}

- (void)emulateSenderDefaultErrorResponse {
    [_invokerMock emulateCallFailWithError: self.defaultInvokerError];
}

- (void)emulateOperationTTL {
    [self.module.returnedState emulateExpired];
}

- (void)emulateSenderSuccessResponse {
    [_invokerMock emulateCallSuccess];
}

- (UADSAbstractTestModuleState *)emptyState {
    UADSAbstractTestModuleState *state = [UADSAbstractTestModuleState new];

    state.placementID = kUADStDefaultPlacementID;
    state.delegate = _delegateMock;
    state.id = kUADSListenerID;
    return state;
}

- (void)emulateDefaultExecuteMethodCall {
    [self emulateDefaultExecuteMethodCallWait: true];
}

- (void)emulateDefaultExecuteMethodCallWait: (BOOL)wait {
    if (wait) {
        _invokerMock.expectation = self.defaultExpectation;
    }

    [_moduleToTest executeForPlacement: kUADStDefaultPlacementID
                           withOptions: self.defaultOptions
                           andDelegate: self.delegateMock];

    if (wait) {
        [self waitForExpectations: @[_invokerMock.expectation]
                          timeout: DEFAULT_TEST_WAIT_TIME];
    }
}

- (void)emulateDefaultSuccessTestFlow {
    [self setEmptyStateResponse];
    [self emulateDefaultExecuteMethodCall];
    [self setExpectationInDelegate];
    [self emulateSenderSuccessResponse];
}

- (void)setExpectationInDelegate {
    _delegateMock.expectation = self.defaultExpectation;
}

- (XCTestExpectation *)defaultExpectation {
    return [self expectationWithDescription: @"UADSShowModuleTest.Expectation"];
}

- (void)await {
    [self waitForExpectationsWithTimeout: DEFAULT_TEST_WAIT_TIME
                                 handler: nil];
}

- (void)waitForTimeInterval: (NSTimeInterval)waitTime {
    XCTestExpectation *expectation = [self expectationWithDescription: @"wait.expectations"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, waitTime * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectations: @[expectation]
                      timeout: waitTime + 10];
}

// MARK: - Validation methods.

- (void)validateInvokerIsCalledNumberOfTimes: (int)numberOfTimes {
    XCTAssertEqual(numberOfTimes, _invokerMock.completions.count);
}

- (void)validateDelegateIsCalledNumberOfTimes: (int)numberOfTimes {
    XCTAssertEqual(numberOfTimes, _delegateMock.placementIDs.count);
}

- (void)validateInvokerIsCalledWithDefaultIDs {
    XCTAssertEqual(self.emptyState.placementID, self.lastParamsInInvoker.placementID);
    XCTAssertEqual(self.emptyState.id, self.lastParamsInInvoker.id);
}

- (UADSAbstractTestModuleState *)lastParamsInInvoker {
    return (UADSAbstractTestModuleState *)_invokerMock.operations.lastObject;
}

- (void)validateErrorHandlerIsCalledOnce {
    XCTAssertEqual(_errorHandlerMock.errors.count, 1);
}

- (void)validateDelegateIsCalledWithDefaultError {
    XCTAssertEqualObjects(self.defaultInvokerError, _delegateMock.errors.lastObject);
}

- (UADSInternalError *)defaultInvokerError {
    return [UADSInternalError newWithErrorCode: kUADSInternalErrorWebView
                                     andReason: kUADSInternalErrorWebViewInternal
                                    andMessage: kUADSTestDefaultMessage];
}

- (UADSInternalError *)defaultInvokerTimeoutError {
    return [UADSInternalError newWithErrorCode: kUADSInternalErrorWebView
                                     andReason: kUADSInternalErrorWebViewTimeout
                                    andMessage: kUADSTestDefaultMessage];
}

- (UADSInternalError *)defaultExpectedExpirationError {
    return [UADSInternalError newWithErrorCode: kUADSInternalErrorAbstractModule
                                     andReason: kUADSInternalErrorAbstractModuleTimeout
                                    andMessage: kUADSTestDefaultMessage];
}

@end
