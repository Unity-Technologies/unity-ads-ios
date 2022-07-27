#import <XCTest/XCTest.h>
#import "UADSEventHandler.h"
#import "UnityAdsLoadError.h"
#import "UnityAdsShowError.h"
#import "SDKMetricsSenderMock.h"
#import "UADSLoadMetric.h"
#import "UADSCurrentTimestampMock.h"
#import "XCTestCase+Convenience.h"
#import "NSArray+Convenience.h"
#import "UADSInitializationStatusReaderMock.h"

@interface UADSEventHandlerTests : XCTestCase
@property (nonatomic, strong) SDKMetricsSenderMock *metricsMock;
@property (nonatomic, strong) UADSInitializationStatusReaderMock *statusMock;
@end

@implementation UADSEventHandlerTests

- (void)setUp {
    _statusMock = [UADSInitializationStatusReaderMock new];
}

- (void)test_sends_success_time_events {
    self.statusMock.currentState = INITIALIZED_SUCCESSFULLY;
    [self verifySendsStartAndSuccessTimeForType: kUADSEventHandlerTypeLoadModule];
    [self verifySendsStartAndSuccessTimeForType: kUADSEventHandlerTypeShowModule];
}

- (void)test_sends_failure_time_for_callback_timeout {
    self.statusMock.currentState = INITIALIZING;
    [self verifySendsStartAndCallbackTimeoutFailureTimeForType: kUADSEventHandlerTypeLoadModule];
    [self verifySendsStartAndCallbackTimeoutFailureTimeForType: kUADSEventHandlerTypeShowModule];
}

- (void)test_sends_failure_time_for_callback_error {
    self.statusMock.currentState = INITIALIZED_FAILED;
    [self verifySendsStartAndCallbackErrorFailureTimeForType: kUADSEventHandlerTypeLoadModule];
    [self verifySendsStartAndCallbackErrorFailureTimeForType: kUADSEventHandlerTypeShowModule];
}

- (void)test_sends_failure_time_for_timeout {
    [self verifySendsStartAndTimeoutErrorFailureTimeForType: kUADSEventHandlerTypeLoadModule];
    [self verifySendsStartAndTimeoutErrorFailureTimeForType: kUADSEventHandlerTypeShowModule];
}

- (void)test_sends_failure_time_when_load_fails {
    [self verifySendsStartAndFailureTimeForType: kUADSEventHandlerTypeLoadModule
                                          error: [UADSInternalError newWithErrorCode: kUADSInternalErrorLoadModule
                                                                           andReason: kUnityAdsLoadErrorNoFill
                                                                          andMessage: @"no fill"]
                                         reason: @"no_fill"];
}

- (void)test_sends_failure_time_when_show_fails {
    [self verifySendsStartAndFailureTimeForType: kUADSEventHandlerTypeShowModule
                                          error: [UADSInternalError newWithErrorCode: kUADSInternalErrorShowModule
                                                                           andReason: kUnityShowErrorInternalError
                                                                          andMessage: @"internal error"]
                                         reason: @"internal"];
}

- (void)test_correctly_calculates_duration_for_multiple_operations {
    UADSEventHandlerType type = kUADSEventHandlerTypeLoadModule;
    UADSEventHandlerBase *sut = [self sutWithType: type];

    [sut eventStarted: @"1"]; // 12345
    [sut eventStarted: @"2"];  // 12345 * 2
    [sut onSuccess: @"2"];     // 12345 * 3
    [sut onSuccess: @"1"];     // 12345 * 4

    NSArray *expected = @[
        [self eventStartedMetricForType: type],
        [self eventStartedMetricForType: type],
        [self eventSuccessMetricForType: type],
        [self eventSuccessMetricForType: type
                                   time: @(3704)]];

    XCTAssertEqual(_metricsMock.callCount, 4);
    XCTAssertEqualObjects(_metricsMock.sentMetrics, expected);
}

- (void)test_does_not_crash_from_multiple_threads_for_success {
    int count = 10;
    UADSEventHandlerBase *sut = [self sutWithType: kUADSEventHandlerTypeLoadModule];

    [self asyncCallEventStarted: count
                           with: sut];
    [self asyncCallSuccess: count
                      with: sut];

    XCTAssertEqual(_metricsMock.callCount, count * 2);
}

- (void)test_does_not_crash_from_multiple_threads_for_failure {
    int count = 10;
    UADSEventHandlerBase *sut = [self sutWithType: kUADSEventHandlerTypeLoadModule];

    [self asyncCallEventStarted: count
                           with: sut];
    [self asyncCallError: count
                    with: sut];

    XCTAssertEqual(_metricsMock.callCount, count * 2);
}

- (UADSEventHandlerBase *)sutWithType: (UADSEventHandlerType)type {
    _metricsMock = [SDKMetricsSenderMock new];
    return [UADSEventHandlerBase newWithType: type
                                metricSender: _metricsMock
                             timestampReader: [UADSCurrentTimestampMock new]
                            initStatusReader: _statusMock];
}

- (void)verifySendsStartAndSuccessTimeForType: (UADSEventHandlerType)type {
    UADSEventHandlerBase *sut = [self sutWithType: type];

    [sut eventStarted: @"1"];
    [sut onSuccess: @"1"];

    NSArray *expected = @[
        [self eventStartedMetricForType: type],
        [self eventSuccessMetricForType: type]];

    XCTAssertEqual(_metricsMock.callCount, 2);
    XCTAssertEqualObjects(_metricsMock.sentMetrics, expected);
}

- (void)verifySendsStartAndCallbackTimeoutFailureTimeForType: (UADSEventHandlerType)type {
    [self verifySendsStartAndFailureTimeForType: type
                                          error: [UADSInternalError newWithErrorCode: kUADSInternalErrorWebView
                                                                           andReason: kUADSInternalErrorWebViewTimeout
                                                                          andMessage: @""]
                                         reason: @"callback_timeout"];
}

- (void)verifySendsStartAndCallbackErrorFailureTimeForType: (UADSEventHandlerType)type {
    [self verifySendsStartAndFailureTimeForType: type
                                          error: [UADSInternalError newWithErrorCode: kUADSInternalErrorWebView
                                                                           andReason: kUADSInternalErrorWebViewInternal
                                                                          andMessage: @""]
                                         reason: @"callback_error"];
}

- (void)verifySendsStartAndTimeoutErrorFailureTimeForType: (UADSEventHandlerType)type {
    [self verifySendsStartAndFailureTimeForType: type
                                          error: [UADSInternalError newWithErrorCode: kUADSInternalErrorAbstractModule
                                                                           andReason: kUADSInternalErrorAbstractModuleTimeout
                                                                          andMessage: @""]
                                         reason: @"timeout"];
}

- (void)verifySendsStartAndFailureTimeForType: (UADSEventHandlerType)type error: (UADSInternalError *)error reason: (NSString *)reason {
    UADSEventHandlerBase *sut = [self sutWithType: type];

    [sut eventStarted: @"1"];
    [sut catchError: error
              forId: @"1"];

    NSArray *expected = @[
        [self eventStartedMetricForType: type],
        [self eventFailedMetricForType: type
                                reason: reason]];

    XCTAssertEqual(_metricsMock.callCount, 2);
    XCTAssertEqualObjects(_metricsMock.sentMetrics, expected);
}

- (void)asyncCallEventStarted: (int)count with: (UADSEventHandlerBase *)sut {
    [self asyncExecuteTimes: count
                      block:^(XCTestExpectation *_Nonnull expectation, int index) {
                          [sut eventStarted: [NSString stringWithFormat: @"%d", index]];
                          [expectation fulfill];
                      }];
}

- (void)asyncCallSuccess: (int)count with: (UADSEventHandlerBase *)sut {
    [self asyncExecuteTimes: count
                      block:^(XCTestExpectation *_Nonnull expectation, int index) {
                          [sut onSuccess: [NSString stringWithFormat: @"%d", index]];
                          [expectation fulfill];
                      }];
}

- (void)asyncCallError: (int)count with: (UADSEventHandlerBase *)sut {
    [self asyncExecuteTimes: count
                      block:^(XCTestExpectation *_Nonnull expectation, int index) {
                          [sut catchError: [UADSInternalError new]
                                    forId: [NSString stringWithFormat: @"%d", index]];
                          [expectation fulfill];
                      }];
}

- (UADSMetric *)eventStartedMetricForType: (UADSEventHandlerType)type {
    return [UADSLoadMetric newEventStarted: type
                                      tags: self.initializeStateTag];
}

- (UADSMetric *)eventSuccessMetricForType: (UADSEventHandlerType)type {
    return [self eventSuccessMetricForType: type
                                      time: UADSCurrentTimestampMock.mockedDuration];
}

- (UADSMetric *)eventSuccessMetricForType: (UADSEventHandlerType)type time: (NSNumber *)time {
    return [UADSLoadMetric newEventSuccess: type
                                      time: time
                                      tags: self.initializeStateTag];
}

- (UADSMetric *)eventFailedMetricForType: (UADSEventHandlerType)type reason: (NSString *)reason {
    NSMutableDictionary *tags = [NSMutableDictionary dictionaryWithDictionary: self.initializeStateTag];

    tags[@"reason"] = reason;
    return [UADSLoadMetric newEventFailed: type
                                     time: UADSCurrentTimestampMock.mockedDuration
                                     tags: tags];
}

- (NSDictionary *)initializeStateTag {
    return @{ @"state": UADSStringFromInitializationState(self.statusMock.currentState) };
}

@end
