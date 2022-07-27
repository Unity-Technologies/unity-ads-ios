#import <XCTest/XCTest.h>
#import "SDKMetricsSenderMock.h"
#import "UADSInitializeEventsMetricSender.h"
#import "UADSTsiMetric.h"
#import "UADSConfigurationCRUDBase.h"
#import "NSDictionary+JSONString.h"
#import "UADSCurrentTimestampMock.h"
#import "UADSConfigurationReaderMock.h"
#import "XCTestCase+Convenience.h"


@interface UADSInitializeEventsMetricSenderTestCase : XCTestCase
@property (nonatomic, strong) SDKMetricsSenderMock *metricsMock;
@property (nonatomic, strong) UADSInitializeEventsMetricSender *sut;
@property (nonatomic, strong) USRVInitializationNotificationCenter *initializationSubject;
@property (nonatomic, assign) NSInteger configRetryCount;
@property (nonatomic, assign) NSInteger webviewRetryCount;
@end

@implementation UADSInitializeEventsMetricSenderTestCase

- (void)setUp {
    self.initializationSubject = [USRVInitializationNotificationCenter new];
    self.metricsMock = [SDKMetricsSenderMock new];
    self.sut = [[UADSInitializeEventsMetricSender alloc] initWithMetricSender: self.metricsMock
                                                             currentTimestamp: [UADSCurrentTimestampMock new]
                                                                  initSubject: self.initializationSubject];
    self.configRetryCount = 0;
    self.webviewRetryCount = 0;
}

- (void)test_sends_metric_when_init_successful_only_once {
    [self.sut didInitStart];
    [self mockConfigRetry];
    [self mockWebviewRetry];
    [self emulateInitializationSucceed];
    NSArray *expected = @[ [UADSTsiMetric newInitStarted],
                           [UADSTsiMetric newInitTimeSuccess: UADSCurrentTimestampMock.mockedDuration
                                                        tags: self.retryTags] ];

    [self waitForTimeInterval: 1];
    XCTAssertEqualObjects(self.metricsMock.sentMetrics, expected);

    [self emulateInitializationSucceed];
    [self waitForTimeInterval: 1];
    XCTAssertEqualObjects(self.metricsMock.sentMetrics, expected);
}

- (void)test_sends_metric_when_init_fails_only_once {
    [self.sut didInitStart];
    [self mockConfigRetry];
    [self mockConfigRetry];
    [self mockWebviewRetry];
    [self emulateInitializationFailureWithCode: kUADSErrorStateInvalidHash];
    NSMutableDictionary *tags = [NSMutableDictionary dictionaryWithDictionary: @{ @"stt": @"invalid_hash" }];

    [tags addEntriesFromDictionary: self.retryTags];
    NSArray *expected = @[ [UADSTsiMetric newInitStarted],
                           [UADSTsiMetric newInitTimeFailure: UADSCurrentTimestampMock.mockedDuration
                                                        tags: tags]];

    [self waitForTimeInterval: 1];
    XCTAssertEqualObjects(self.metricsMock.sentMetrics, expected);

    [self emulateInitializationFailureWithCode: kUADSErrorStateInvalidHash];
    [self waitForTimeInterval: 1];
    XCTAssertEqualObjects(self.metricsMock.sentMetrics, expected);
}

- (void)test_sends_metric_when_gets_token_only_once {
    [self.sut didInitStart];
    [self mockConfigRetry];
    [self mockWebviewRetry];
    [self mockWebviewRetry];
    [self.sut sendTokenAvailabilityLatencyOnceOfType: YES];

    NSArray *expected = @[ [UADSTsiMetric newInitStarted],
                           [UADSTsiMetric newTokenAvailabilityLatencyConfig: UADSCurrentTimestampMock.mockedDuration
                                                                       tags: self.retryTags]];

    XCTAssertEqualObjects(self.metricsMock.sentMetrics, expected);

    [self.sut sendTokenAvailabilityLatencyOnceOfType: NO];
    XCTAssertEqualObjects(self.metricsMock.sentMetrics, expected);
}

- (void)test_sends_metric_when_gets_token_with_webview {
    [self.sut didInitStart];
    [self mockConfigRetry];
    [self mockWebviewRetry];
    [self mockWebviewRetry];
    [self.sut sendTokenAvailabilityLatencyOnceOfType: NO];

    NSArray *expected = @[ [UADSTsiMetric newInitStarted],
                           [UADSTsiMetric newTokenAvailabilityLatencyWebview: UADSCurrentTimestampMock.mockedDuration
                                                                        tags: self.retryTags]];

    XCTAssertEqualObjects(self.metricsMock.sentMetrics, expected);

    [self.sut sendTokenAvailabilityLatencyOnceOfType: NO];
    XCTAssertEqualObjects(self.metricsMock.sentMetrics, expected);
}

- (void)test_does_not_send_latency_metric_when_start_config_not_called {
    [self.sut didInitStart];
    [self.sut sendTokenAvailabilityLatencyOnceOfType: YES];
    NSArray *expected = @[ [UADSTsiMetric newInitStarted],
                           [UADSTsiMetric newTokenAvailabilityLatencyConfig: UADSCurrentTimestampMock.mockedDuration
                                                                       tags: self.retryTags]];

    XCTAssertEqualObjects(self.metricsMock.sentMetrics, expected);
}

- (void)test_does_not_send_init_metric_when_init_started_not_called {
    [self emulateInitializationSucceed];
    [self waitForTimeInterval: 1];
    XCTAssertEqual(self.metricsMock.sentMetrics.count, 0);

    [self emulateInitializationFailureWithCode: kUADSErrorStateNetworkConfigRequest];
    [self waitForTimeInterval: 1];
    XCTAssertEqual(self.metricsMock.sentMetrics.count, 0);
}

- (NSError *)mockedError {
    return [NSError errorWithDomain: @"test"
                               code: 0
                           userInfo: nil];
}

- (void)emulateInitializationFailureWithCode: (UADSErrorState)code {
    [_initializationSubject triggerSdkInitializeDidFail: @"InitFailed"
                                                   code: code];
}

- (void)emulateInitializationSucceed {
    [_initializationSubject triggerSdkDidInitialize];
}

- (void)mockConfigRetry {
    [_sut didRetryConfig];
    self.configRetryCount += 1;
}

- (void)mockWebviewRetry {
    [_sut didRetryWebview];
    self.webviewRetryCount += 1;
}

- (NSDictionary *)retryTags {
    return @{
        @"c_retry": @(self.configRetryCount).stringValue,
        @"wv_retry": @(self.webviewRetryCount).stringValue
    };
}

@end
