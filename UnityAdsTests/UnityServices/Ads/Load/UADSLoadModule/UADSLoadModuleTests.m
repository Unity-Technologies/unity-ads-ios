#import <XCTest/XCTest.h>
#import "UADSLoadModule.h"
#import "UADSWebViewInvokerMock.h"
#import "UnityAdsLoadDelegateMock.h"
#import "UADSErrorHandlerMock.h"

static NSString * const kUADSLoadModuleTestsPlacementID = @"kUADSLoadModuleTestsPlacementID";
#define DEFAULT_TEST_WAIT_TIME 3
#define DEFAULT_TEST_SLEEP_TIME 2

@interface UADSLoadModuleTests : XCTestCase
@property (nonatomic, strong) UADSWebViewInvokerMock* invokerMock;
@property (nonatomic, strong) UnityAdsLoadDelegateMock* loadDelegateMock;
@property (nonatomic, strong) UADSLoadModule *moduleToTest;
@property (nonatomic, strong) UADSErrorHandlerMock *errorLoggerMock;
@end

@implementation UADSLoadModuleTests

- (void)setUp {
    self.loadDelegateMock = [UnityAdsLoadDelegateMock new];
    self.invokerMock = [UADSWebViewInvokerMock new];
    self.errorLoggerMock = [UADSErrorHandlerMock new];
    self.moduleToTest = [UADSLoadModule newWithInvoker: _invokerMock
                                       andErrorHandler: _errorLoggerMock];
    [self setDefaultConfiguration];
}

- (void)tearDown {
    _loadDelegateMock = nil;
    _invokerMock = nil;
    _moduleToTest = nil;
    _errorLoggerMock = nil;
}

- (void)test_calls_invoker_if_placement_id_is_not_empty {
    [self setExpectationInDelegate];
    [self emulateLoadCallWithPlacementID: kUADSLoadModuleTestsPlacementID];
    [self emulateSendLoaded];
    [self await];
    [self waitForTimeInterval: DEFAULT_TEST_SLEEP_TIME];
    XCTAssertEqual(_invokerMock.invokerCalledNumberOfTimes, 1);
    XCTAssertEqual(_loadDelegateMock.failedPlacements.count, 0);
    XCTAssertEqual(_loadDelegateMock.succeedPlacements.count, 1);
}

- (void)test_notifies_delegate_if_placement_is_empty {
    [self setExpectationInDelegate];
    [self emulateLoadCallWithPlacementID: @"" andWait: false];
    [self await];
    [self waitForTimeInterval: DEFAULT_TEST_SLEEP_TIME];
    XCTAssertEqual(_loadDelegateMock.failedPlacements.count, 1);
    XCTAssertEqual(_errorLoggerMock.errors.count, 1);
    XCTAssertEqual(_errorLoggerMock.errors.lastObject.errorCode, kUADSInternalErrorAbstractModule);
    XCTAssertEqual(_errorLoggerMock.errors.lastObject.reasonCode, kUADSInternalErrorAbstractModuleEmptyPlacementID);
    XCTAssertEqual(_loadDelegateMock.succeedPlacements.count, 0);
}

- (void)test_notifies_delegate_once_and_clears_the_states {
    [self setExpectationInDelegate];
    [self emulateLoadCallWithPlacementID: kUADSLoadModuleTestsPlacementID];
    [self emulateSendLoaded];
    [self emulateSendLoaded];
    [self await];
    [self waitForTimeInterval: DEFAULT_TEST_SLEEP_TIME];
    XCTAssertEqual(_invokerMock.invokerCalledNumberOfTimes, 1);
    XCTAssertEqual(_loadDelegateMock.failedPlacements.count, 0);
    XCTAssertEqual(_loadDelegateMock.succeedPlacements.count, 1);
}

- (void)test_sends_fail_event_to_a_delegate {
    [self setExpectationInDelegate];
    [self emulateLoadCallWithPlacementID: kUADSLoadModuleTestsPlacementID];
    [self emulateSendFailed];
    [self await];
    [self waitForTimeInterval: DEFAULT_TEST_SLEEP_TIME];
    XCTAssertEqual(_invokerMock.invokerCalledNumberOfTimes, 1);
    XCTAssertEqual(_loadDelegateMock.failedPlacements.count, 1);
    XCTAssertEqual(_loadDelegateMock.succeedPlacements.count, 0);
}

- (void)test_timeouts_when_delegate_doesnt_receive_any_calls {
    [self setExpectationInDelegate];
    [self emulateLoadCallWithPlacementID: kUADSLoadModuleTestsPlacementID];
    [self await];
    [self waitForTimeInterval: DEFAULT_TEST_SLEEP_TIME];
  
    XCTAssertEqual(_invokerMock.invokerCalledNumberOfTimes, 1);
    XCTAssertEqual(_loadDelegateMock.failedPlacements.count, 1);
    XCTAssertEqual(_loadDelegateMock.succeedPlacements.count, 0);
}

- (void)emulateLoadCallWithPlacementID: (NSString*)placementID {
    [self emulateLoadCallWithPlacementID: placementID andWait: true];
}

- (void)emulateLoadCallWithPlacementID: (NSString*)placementID andWait: (BOOL) wait{
    XCTestExpectation *expectation;
    if (wait) {
        expectation = self.defaultExpectation;
        _invokerMock.expectation = expectation;
    }
    
    [_moduleToTest loadForPlacementID: placementID
                              options: [UADSLoadOptions new]
                         loadDelegate: _loadDelegateMock];

    
    if (wait) {
        [self waitForExpectations:@[expectation] timeout: DEFAULT_TEST_WAIT_TIME];
    }

}

- (void)waitForTimeInterval: (NSTimeInterval)waitTime {
    XCTestExpectation *expectation = [self expectationWithDescription: @"wait.expectations"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, waitTime * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectations: @[expectation] timeout: waitTime + 2];
}

-(void)await {
    [self waitForExpectations:@[_loadDelegateMock.expectation] timeout:DEFAULT_TEST_WAIT_TIME];
}

-(void)setExpectationInDelegate {
    _loadDelegateMock.expectation = self.defaultExpectation;
}

-(void)emulateSendLoaded {
    [_moduleToTest sendAdLoadedForPlacementID: kUADSLoadModuleTestsPlacementID
                                andListenerID: self.lastParamsInInvoker.id];
}

-(void)emulateSendFailed {

    [_moduleToTest sendAdFailedToLoadForPlacementID:kUADSLoadModuleTestsPlacementID
                                         listenerID:self.lastParamsInInvoker.id
                                            message:@""
                                              error:kUnityAdsLoadErrorInvalidArgument];
}


#warning should avoid using global states, the object should depend on the configuration reader
-(void)setDefaultConfiguration {
    USRVConfiguration *config = [USRVConfiguration new];
    config.loadTimeout = DEFAULT_TEST_SLEEP_TIME * 1000;
    [UADSAbstractModule setConfiguration: config];
}



-(id<UADSAbstractModuleOperationObject>)lastParamsInInvoker {
    return (id<UADSAbstractModuleOperationObject>)_invokerMock.operations.lastObject;
}

-(XCTestExpectation *)defaultExpectation {
    return [self expectationWithDescription: @"UADSLoadModuleTests.Expectation"];
}

@end
