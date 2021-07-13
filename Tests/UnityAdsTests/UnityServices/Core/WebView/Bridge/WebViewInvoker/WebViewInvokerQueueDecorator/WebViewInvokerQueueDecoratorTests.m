#import <XCTest/XCTest.h>
#import "WebViewInvokerQueueDecorator.h"
#import "UADSWebViewInvokerMock.h"
#import "USRVInitializationNotificationCenter.h"
#import "USRVSdkProperties.h"

static NSString *const MOCK_ERROR_MESSAGE = @"FAILED";
static NSString *const MOCK_STRING_KEY = @"MOCK_STRING_KEY";
static NSString *const MOCK_STRING_VALUE = @"MOCK_STRING_VALUE";
static NSString *const MOCK_METHOD_NAME = @"MOCK_METHOD_NAME";
static NSString *const NOT_INITIALIZED_FAILURE_MESSAGE = @"SHOULD NOT FALL HERE WHEN SDK IS NOT INITIALIZED";


@interface WebViewInvokerMockOperation : NSObject<UADSWebViewInvokerOperation>
@property (nonatomic, copy) NSString *stringArgument;
@end

@implementation WebViewInvokerMockOperation
@synthesize stringArgument;


- (NSString *)methodName {
    return MOCK_METHOD_NAME;
}

- (NSDictionary *)dictionary {
    return @{
        MOCK_STRING_KEY: self.stringArgument
    };
}

@end

@interface WebViewInvokerQueueDecoratorTests : XCTestCase
@property (nonatomic, strong) WebViewInvokerQueueDecorator *decoratorToTest;
@property (nonatomic, strong) UADSWebViewInvokerMock *decoratedMock;
@property (nonatomic, strong) USRVInitializationNotificationCenter *notificationCenter;
@end

@implementation WebViewInvokerQueueDecoratorTests

- (void)setUp {
    self.decoratedMock = [[UADSWebViewInvokerMock alloc] init];
    self.notificationCenter = [[USRVInitializationNotificationCenter alloc] init];
    self.decoratorToTest = [WebViewInvokerQueueDecorator newWithDecorated: _decoratedMock
                                                    andNotificationCenter    : _notificationCenter];
}

- (void)tearDown {
    self.decoratedMock = nil;
    self.notificationCenter = nil;
    self.decoratorToTest = nil;
}

- (void)test_when_not_initialized_no_invocations_sent {
    [self emulateSDKInitializedState: NOT_INITIALIZED];
    [self emulateInvokeCallWithCompletion: ^{
        XCTFail();
    }
                       andErrorCompletion: ^(UADSInternalError *_Nullable error) {
                           XCTFail();
                       }];
    [self emulateSuccessResponseFromInvocationAsync: false];
    XCTAssertEqual(_decoratedMock.invokerCalledNumberOfTimes, 0);
}

- (void)test_if_sdk_initial_state_is_failed_the_error_is_returned {
    [self emulateSDKInitializedState: INITIALIZED_FAILED];
    XCTestExpectation *exp = self.defaultExpectation;

    [self emulateInvokeCallWithErrorCheck: exp];
    [self emulateFailureResponseFromInvocationAsync: false];
    [self await: exp];
    XCTAssertEqual(_decoratedMock.invokerCalledNumberOfTimes, 0);
}

- (void)test_when_initializing_no_invocations_sent {
    [self emulateSDKInitializedState: INITIALIZING];
    [self emulateInvokeCallWithCompletion: ^{
        XCTFail();
    }
                       andErrorCompletion: ^(UADSInternalError *_Nullable error) {
                           XCTFail();
                       }];
    [self emulateSuccessResponseFromInvocationAsync: false];
    XCTAssertEqual(_decoratedMock.invokerCalledNumberOfTimes, 0);
}

- (void)test_when_initialized_should_send_invocations {
    [self emulateSDKInitializedState: INITIALIZED_SUCCESSFULLY];
    XCTestExpectation *exp = self.defaultExpectation;

    [self emulateInvokeCallWithSuccessCheck: exp];
    [self emulateSuccessResponseFromInvocationAsync: true];
    [self await: exp];
    XCTAssertEqual(_decoratedMock.invokerCalledNumberOfTimes, 1);
}

- (void)test_notification_triggers_send_invocation {
    [self emulateSDKInitializedState: NOT_INITIALIZED];
    XCTestExpectation *exp = self.defaultExpectation;

    [self emulateInvokeCallWithSuccessCheck: exp];
    [self emulateSDKInitializeSuccessNotification];
    [self emulateSuccessResponseFromInvocationAsync: true];
    [self await: exp];
    XCTAssertEqual(_decoratedMock.invokerCalledNumberOfTimes, 1);
}

- (void)test_if_invocation_fails_the_error_is_returned {
    [self emulateSDKInitializedState: INITIALIZED_SUCCESSFULLY];
    XCTestExpectation *exp = self.defaultExpectation;

    [self emulateInvokeCallWithErrorCheck: exp];
    [self emulateFailureResponseFromInvocationAsync: true];
    [self await: exp];
    XCTAssertEqual(_decoratedMock.invokerCalledNumberOfTimes, 1);
}

- (void)test_if_invocation_fails_after_sdk_initialized_an_error_is_returned {
    [self emulateSDKInitializedState: NOT_INITIALIZED];
    XCTestExpectation *exp = self.defaultExpectation;

    [self emulateInvokeCallWithErrorCheck: exp];
    [self emulateSDKInitializeSuccessNotification];
    [self emulateFailureResponseFromInvocationAsync: true];
    [self await: exp];
    XCTAssertEqual(_decoratedMock.invokerCalledNumberOfTimes, 1);
}

- (void)test_if_invocation_fails_after_sdk_initialized_from_initializing_an_error_is_returned {
    [self emulateSDKInitializedState: INITIALIZING];
    XCTestExpectation *exp = self.defaultExpectation;

    [self emulateInvokeCallWithErrorCheck: exp];
    [self emulateSDKInitializeSuccessNotification];
    [self emulateFailureResponseFromInvocationAsync: true];
    [self await: exp];
    XCTAssertEqual(_decoratedMock.invokerCalledNumberOfTimes, 1);
}

- (void)test_if_sdk_initialize_fails_the_error_is_returned {
    [self emulateSDKInitializedState: NOT_INITIALIZED];
    XCTestExpectation *exp = self.defaultExpectation;

    [self emulateInvokeCallWithErrorCheck: exp];
    [self emulateSDKInitializeFailNotification];
    [self await: exp];
    XCTAssertEqual(_decoratedMock.invokerCalledNumberOfTimes, 0);
}

- (void)test_if_the_buffer_clears_after_sdk_intitialized {
    // since its hard to test clearing the buffer.
    // we do a trick here, send the skdInitialized notification twice
    // the second time no calls to decorator mock should be done.
    // if the calls are made more than one time, this will cause the test to crash
    // with multiple calls made to -[XCTestExpectation fulfill]
    [self emulateSDKInitializedState: NOT_INITIALIZED];
    XCTestExpectation *exp = self.defaultExpectation;

    [self emulateInvokeCallWithSuccessCheck: exp];
    [self emulateSDKInitializeSuccessNotification];
    [self emulateSDKInitializeSuccessNotification];
    [self emulateSuccessResponseFromInvocationAsync: true];
    [self await: exp];
    XCTAssertEqual(_decoratedMock.invokerCalledNumberOfTimes, 1);
}

- (void)test_if_the_buffer_clears_after_sdk_intitialize_fails {
    // since its hard to test clearing the buffer.
    // we do a trick here, send the skdInitialized notification twice
    // the second time no calls to decorator mock should be done.
    // if the calls are made more than one time, the assert will show that number of calls is more than 1
    [self emulateSDKInitializedState: NOT_INITIALIZED];
    XCTestExpectation *exp = self.defaultExpectation;

    [self emulateInvokeCallWithErrorCheck: exp];
    [self emulateSDKInitializeFailNotification];
    [self emulateSDKInitializeSuccessNotification];
    [self await: exp];
    XCTAssertEqual(_decoratedMock.invokerCalledNumberOfTimes, 0);
}

// MARK: - Helper Methods

- (XCTestExpectation *)defaultExpectation {
    return [self expectationWithDescription: @"WebViewInvokerQueueDecoratorTests"];
}

- (void)emulateSDKInitializedState: (InitializationState)state {
    // Its not obvious why we need to set up.
    // However WebViewInvokerQueueDecorator calls USRVSdkProperties.isInitialized inside its implementation
    // To test the flow we need to setUp the flag explicitly
    [USRVSdkProperties setInitializationState: state];
}

- (void)emulateInvokeCallWithCompletion: (UADSWebViewInvokerCompletion)completion
                     andErrorCompletion: (UADSWebViewInvokerErrorCompletion)errorCompletion {
    [_decoratorToTest invokeOperation: self.mockOperation
                       withCompletion: completion
                   andErrorCompletion: errorCompletion];
}

- (void)emulateInvokeCallWithSuccessCheck: (XCTestExpectation *)exp {
    [self emulateInvokeCallWithCompletion: ^{
        [exp fulfill];
    }
                       andErrorCompletion: ^(UADSInternalError *_Nullable error) {
                           XCTFail();
                       }];
}

- (void)emulateInvokeCallWithErrorCheck: (XCTestExpectation *)exp {
    [self emulateInvokeCallWithCompletion: ^{
        XCTFail();
    }
                       andErrorCompletion: ^(UADSInternalError *_Nullable error) {
                           [exp fulfill];
                       }];
}

- (void)await: (XCTestExpectation *)exp {
    [self waitForExpectations: @[exp]
                      timeout: 5];
}

- (void)emulateSuccessResponseFromInvocationAsync: (BOOL)async {
    if (async) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.decoratedMock emulateCallSuccess];
        });
    } else {
        [self.decoratedMock emulateCallSuccess];
    }
}

- (void)emulateFailureResponseFromInvocationAsync: (BOOL)async {
    if (async) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.decoratedMock emulateCallFailWithError: self.mockError];
        });
    } else {
        [_decoratedMock emulateCallFailWithError: self.mockError];
    }
}

- (WebViewInvokerMockOperation *)mockOperation {
    WebViewInvokerMockOperation *params = [WebViewInvokerMockOperation new];

    params.stringArgument = MOCK_STRING_VALUE;
    return params;
}

- (void)emulateSDKInitializeSuccessNotification {
    [_notificationCenter triggerSdkDidInitialize];
}

- (void)emulateSDKInitializeFailNotification {
    NSNumber *code = [NSNumber numberWithInteger: self.mockError.errorCode];

    [_notificationCenter triggerSdkInitializeDidFail: self.mockError.errorMessage
                                                code: code];
}

- (UADSInternalError *)mockError {
    return [UADSInternalError newWithErrorCode: -1
                                     andReason: -1
                                    andMessage: MOCK_ERROR_MESSAGE];
}

@end
