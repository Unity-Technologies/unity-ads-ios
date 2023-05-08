#import <XCTest/XCTest.h>
#import "UADSBannerLoadModule.h"
#import "UADSWebViewInvokerMock.h"
#import "UADSBannerViewDelegateMock.h"
#import "UADSEventHandlerMock.h"
#import <UnityAds/UADSBannerView.h>

static NSString *const kUADSLoadModuleTestsPlacementID = @"kUADSLoadModuleTestsPlacementID";
#define DEFAULT_TEST_WAIT_TIME  3
#define DEFAULT_TEST_SLEEP_TIME 2

@interface UADSBannerLoadModuleTests : XCTestCase
@property (nonatomic, strong) UADSWebViewInvokerMock *invokerMock;
@property (nonatomic, strong) UADSBannerViewDelegateMock *loadDelegateMock;
@property (nonatomic, strong) UADSBannerLoadModule *moduleToTest;
@property (nonatomic, strong) UADSEventHandlerMock *eventHandlerMock;
@property (nonatomic, strong) UADSBannerView *bannerView;
@end

@implementation UADSBannerLoadModuleTests

- (void)setUp {
    self.bannerView = [[UADSBannerView alloc] initWithPlacementId:kUADSLoadModuleTestsPlacementID size:CGSizeMake(320.0, 50.0)];
    self.loadDelegateMock = [UADSBannerViewDelegateMock new];
    self.invokerMock = [UADSWebViewInvokerMock new];
    self.eventHandlerMock = [UADSEventHandlerMock new];
    self.moduleToTest = [UADSBannerLoadModule newWithInvoker: _invokerMock
                                       andEventHandler: _eventHandlerMock
                                          timerFactory:  [UADSTimerFactoryBase new]];

    [self setDefaultConfiguration];
}

- (void)tearDown {
    _loadDelegateMock = nil;
    _invokerMock = nil;
    _moduleToTest = nil;
    _eventHandlerMock = nil;
}

- (void)test_calls_invoker_if_placement_id_is_not_empty {
    [self setExpectationInDelegate];
    [self emulateLoadCallWithPlacementID: kUADSLoadModuleTestsPlacementID];
    [self emulateSendLoaded];
    [self await];
    [self waitForTimeInterval: DEFAULT_TEST_SLEEP_TIME];
    [self validateEventHandlerIsCalledOnceWithSuccess];
    XCTAssertEqual(_invokerMock.invokerCalledNumberOfTimes, 1);
    XCTAssertEqual(_loadDelegateMock.failedBanners.count, 0);
    XCTAssertEqual(_loadDelegateMock.succeedBanners.count, 1);
}

- (void)test_notifies_delegate_if_placement_is_empty {
    [self setExpectationInDelegate];
    [self emulateLoadCallWithPlacementID: @""
                                 andWait: false];
    [self await];
    [self waitForTimeInterval: DEFAULT_TEST_SLEEP_TIME];
    XCTAssertEqual(_loadDelegateMock.failedBanners.count, 1);
    [self validateEventHandlerIsCalledOnceWithErrorForIds: nil]; // do not know uuid for the failed operation since invoker wasn't called
    XCTAssertEqual(_eventHandlerMock.errors.allValues.lastObject.lastObject.errorCode, kUADSInternalErrorAbstractModule);
    XCTAssertEqual(_eventHandlerMock.errors.allValues.lastObject.lastObject.reasonCode, kUADSInternalErrorAbstractModuleEmptyPlacementID);
    XCTAssertEqual(_loadDelegateMock.succeedBanners.count, 0);
}

- (void)test_notifies_delegate_about_states {
    [self setExpectationInDelegateWithFulfillmentCount:3];
    [self emulateLoadCallWithPlacementID: kUADSLoadModuleTestsPlacementID];
    [self emulateSendLoaded];
    [self emulateSendClicked];
    [self emulateSendLeaveApplication];
    [self await];
    [self waitForTimeInterval: DEFAULT_TEST_SLEEP_TIME];
    XCTAssertEqual(_invokerMock.invokerCalledNumberOfTimes, 1);
    XCTAssertEqual(_loadDelegateMock.failedBanners.count, 0);
    XCTAssertEqual(_loadDelegateMock.succeedBanners.count, 1);
    XCTAssertEqual(_loadDelegateMock.clickedBanners.count, 1);
    XCTAssertEqual(_loadDelegateMock.leaveAppBanners.count, 1);
}

- (void)test_sends_fail_event_to_a_delegate {
    [self setExpectationInDelegate];
    [self emulateLoadCallWithPlacementID: kUADSLoadModuleTestsPlacementID];
    [self emulateSendFailed];
    [self await];
    [self waitForTimeInterval: DEFAULT_TEST_SLEEP_TIME];
    [self validateEventHandlerIsCalledOnceWithError];
    XCTAssertEqual(_invokerMock.invokerCalledNumberOfTimes, 1);
    XCTAssertEqual(_loadDelegateMock.failedBanners.count, 1);
    XCTAssertEqual(_loadDelegateMock.succeedBanners.count, 0);
}

//- (void)test_timeouts_when_delegate_doesnt_receive_any_calls {
//    [self setExpectationInDelegate];
//    [self emulateLoadCallWithPlacementID: kUADSLoadModuleTestsPlacementID];
//    [self await];
//    [self waitForTimeInterval: DEFAULT_TEST_SLEEP_TIME];
//    [self validateEventHandlerIsCalledOnceWithError];
//    XCTAssertEqual(_invokerMock.invokerCalledNumberOfTimes, 1);
//    XCTAssertEqual(_loadDelegateMock.failedBanners.count, 1);
//    XCTAssertEqual(_loadDelegateMock.succeedBanners.count, 0);
//}

- (void)test_calls_event_handler_for_multiple_successful_loads {
    NSString *op1Id = [self emulateLoadCallWithPlacementID: @"placement1"];
    NSString *op2Id =  [self emulateLoadCallWithPlacementID: @"placement2"];

    [self emulateSendLoadedForPlacementId: @"placement1"
                              operationId: op1Id];
    [self emulateSendLoadedForPlacementId: @"placement2"
                              operationId: op2Id];


    [self validateEventHandlerIsCalledOnceWithSuccessForIds: @[op1Id, op2Id]];
}

- (void)test_calls_event_handler_for_multiple_failed_loads {
    NSString *op1Id = [self emulateLoadCallWithPlacementID: @"placement1"];
    NSString *op2Id =  [self emulateLoadCallWithPlacementID: @"placement2"];

    [self emulateSendFailedForPlacementId: @"placement1"
                              operationId: op1Id];
    [self emulateSendFailedForPlacementId: @"placement2"
                              operationId: op2Id];

    [self validateEventHandlerIsCalledOnceWithErrorForIds: @[op1Id, op2Id]];
}

- (void)test_create_banner_without_load_does_not_crash {
    @autoreleasepool {
        UADSBannerView *bannerView = [[UADSBannerView alloc] initWithPlacementId:kUADSLoadModuleTestsPlacementID size:CGSizeMake(320.0, 50.0)];
    }
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
    [self validateEventHandlerIsCalledOnceWithErrorForIds: @[self.lastParamsInInvoker.id]];
}

- (NSString *)emulateLoadCallWithPlacementID: (NSString *)placementID {
    [self emulateLoadCallWithPlacementID: placementID
                                 andWait: true];
    return self.lastParamsInInvoker.id;
}

- (void)emulateLoadCallWithPlacementID: (NSString *)placementID andWait: (BOOL)wait {
    XCTestExpectation *expectation;

    if (wait) {
        expectation = self.defaultExpectation;
        _invokerMock.expectation = expectation;
    }
    
    [_moduleToTest loadForPlacementID: placementID
                           bannerView: _bannerView
                              options: [UADSLoadOptions new]
                         loadDelegate: _loadDelegateMock];
    
    if (wait) {
        [self waitForExpectations: @[expectation]
                          timeout: DEFAULT_TEST_WAIT_TIME];
    }
}

- (void)waitForTimeInterval: (NSTimeInterval)waitTime {
    XCTestExpectation *expectation = [self expectationWithDescription: @"wait.expectations"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, waitTime * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [expectation fulfill];
    });
    [self waitForExpectations: @[expectation]
                      timeout: waitTime + 2];
}

- (void)await {
    [self waitForExpectations: @[_loadDelegateMock.expectation]
                      timeout: DEFAULT_TEST_WAIT_TIME];
}

- (void)setExpectationInDelegate {
    [self setExpectationInDelegateWithFulfillmentCount:1];
}

- (void)setExpectationInDelegateWithFulfillmentCount:(int)fulfillmentCount {
    _loadDelegateMock.expectation = self.defaultExpectation;
    _loadDelegateMock.expectation.expectedFulfillmentCount = fulfillmentCount;
}

- (void)emulateSendLoadedForPlacementId: (NSString *)placementId operationId: (NSString *)operationId {
    [_moduleToTest sendAdLoadedForPlacementID: placementId
                                andListenerID: operationId];
}

- (void)emulateSendLoaded {
    [self emulateSendLoadedForPlacementId: kUADSLoadModuleTestsPlacementID
                              operationId: self.lastParamsInInvoker.id];
}

- (void)emulateSendClicked {
    [_moduleToTest sendClickEventForListenerID:self.lastParamsInInvoker.id];
}

- (void)emulateSendLeaveApplication {
    [_moduleToTest sendLeaveApplicationEventForListenerID:self.lastParamsInInvoker.id];
}

- (void)emulateSendFailedForPlacementId: (NSString *)placementId operationId: (NSString *)operationId {
    [_moduleToTest sendAdFailedToLoadForPlacementID: placementId
                                         listenerID: operationId
                                            message: @""
                                              error: kUnityAdsLoadErrorInvalidArgument];
}

- (void)emulateSendFailed {
    [self emulateSendFailedForPlacementId: kUADSLoadModuleTestsPlacementID
                              operationId: self.lastParamsInInvoker.id];
}

#warning should avoid using global states, the object should depend on the configuration reader
- (void)setDefaultConfiguration {
    USRVConfiguration *config = [USRVConfiguration new];

    config.loadTimeout = DEFAULT_TEST_SLEEP_TIME * 1000;
    [UADSAbstractModule setConfiguration: config];
}

- (id<UADSAbstractModuleOperationObject>)lastParamsInInvoker {
    return (id<UADSAbstractModuleOperationObject>)_invokerMock.operations.lastObject;
}

- (XCTestExpectation *)defaultExpectation {
    return [self expectationWithDescription: @"UADSBannerLoadModuleTests.Expectation"];
}

@end
