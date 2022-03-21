#import <XCTest/XCTest.h>
#import "SDKMetricsSenderMock.h"
#import "UADSInitializeEventsMetricSender.h"
#import "UADSTsiMetric.h"
#import "UADSConfigurationReader.h"
#import "NSDictionary+JSONString.h"
#import "UADSCurrentTimestamp.h"
#import "UADSConfigurationReaderMock.h"
#import "XCTestCase+Convenience.h"


@interface UADSCurrentTimestampMock : NSObject <UADSCurrentTimestamp>
@property (nonatomic, assign) CFTimeInterval currentTime;
@end

@implementation UADSCurrentTimestampMock

- (CFTimeInterval)currentTimestamp {
    self.currentTime += 1.2345;
    return self.currentTime;
}

- (NSNumber *)msDurationFrom: (CFTimeInterval)time {
    CFTimeInterval duration = self.currentTimestamp - time;

    return [NSNumber numberWithInt: round(duration * 1000)];
}

@end

@interface UADSInitializeEventsMetricSenderTestCase : XCTestCase
@property (nonatomic, strong) SDKMetricsSenderMock *metricsMock;
@property (nonatomic, strong) UADSInitializeEventsMetricSender *sut;
@property (nonatomic, strong) USRVInitializationNotificationCenter *initializationSubject;
@end

@implementation UADSInitializeEventsMetricSenderTestCase

- (void)setUp {
    self.initializationSubject = [USRVInitializationNotificationCenter new];
    self.metricsMock = [SDKMetricsSenderMock new];
    self.sut = [[UADSInitializeEventsMetricSender alloc] initWithMetricSender: self.metricsMock
                                                                   tagsReader: [UADSConfigurationReaderMock newWithExperiments: [self tags]]
                                                             currentTimestamp: [UADSCurrentTimestampMock new]
                                                                  initSubject: self.initializationSubject];
}

- (void)test_sends_metric_when_init_successful_only_once {
    [self.sut didInitStart];
    [self emulateInitializationSucceed];
    NSArray *expected = @[ [UADSTsiMetric newInitStartedWithTags: self.tags],
                           [UADSTsiMetric newInitTimeSuccess: @(1235)
                                                    withTags: self.tags] ];

    [self waitForTimeInterval: 1];
    XCTAssertEqualObjects(self.metricsMock.sentMetrics, expected);

    [self emulateInitializationSucceed];
    [self waitForTimeInterval: 1];
    XCTAssertEqualObjects(self.metricsMock.sentMetrics, expected);
}

- (void)test_sends_metric_when_init_fails_only_once {
    [self.sut didInitStart];
    [self emulateInitializationFailure];
    NSArray *expected = @[ [UADSTsiMetric newInitStartedWithTags: self.tags],
                           [UADSTsiMetric newInitTimeFailure: @(1235)
                                                    withTags: self.tags] ];

    [self waitForTimeInterval: 1];
    XCTAssertEqualObjects(self.metricsMock.sentMetrics, expected);

    [self emulateInitializationFailure];
    [self waitForTimeInterval: 1];
    XCTAssertEqualObjects(self.metricsMock.sentMetrics, expected);
}

- (void)test_sends_metric_when_gets_token_only_once {
    [self.sut didInitStart];
    [self.sut didConfigRequestStart];
    [self.sut sendTokenAvailabilityLatencyOnceOfType: YES];

    NSArray *expected = @[ [UADSTsiMetric newInitStartedWithTags: self.tags],
                           [UADSTsiMetric newTokenAvailabilityLatencyConfig: @(2469)
                                                                   withTags: self.tags],
                           [UADSTsiMetric newTokenResolutionRequestLatency: @(2469)
                                                                  withTags: self.tags]];

    XCTAssertEqualObjects(self.metricsMock.sentMetrics, expected);

    [self.sut sendTokenAvailabilityLatencyOnceOfType: NO];
    XCTAssertEqualObjects(self.metricsMock.sentMetrics, expected);
}

- (void)test_sends_metric_when_gets_token_with_webview {
    [self.sut didInitStart];
    [self.sut didConfigRequestStart];
    [self.sut sendTokenAvailabilityLatencyOnceOfType: NO];

    NSArray *expected = @[ [UADSTsiMetric newInitStartedWithTags: self.tags],
                           [UADSTsiMetric newTokenAvailabilityLatencyWebview: @(2469)
                                                                    withTags: self.tags],
                           [UADSTsiMetric newTokenResolutionRequestLatency: @(2469)
                                                                  withTags: self.tags]];

    XCTAssertEqualObjects(self.metricsMock.sentMetrics, expected);

    [self.sut sendTokenAvailabilityLatencyOnceOfType: NO];
    XCTAssertEqualObjects(self.metricsMock.sentMetrics, expected);
}

- (void)test_does_not_send_latency_metric_when_start_config_not_called {
    [self.sut didInitStart];
    [self.sut sendTokenAvailabilityLatencyOnceOfType: YES];
    NSArray *expected = @[ [UADSTsiMetric newInitStartedWithTags: self.tags],
                           [UADSTsiMetric newTokenAvailabilityLatencyConfig: @(1235)
                                                                   withTags: self.tags]];

    XCTAssertEqualObjects(self.metricsMock.sentMetrics, expected);
}

- (void)test_does_not_send_init_metric_when_init_started_not_called {
    [self emulateInitializationSucceed];
    [self waitForTimeInterval: 1];
    XCTAssertEqual(self.metricsMock.sentMetrics.count, 0);

    [self emulateInitializationFailure];
    [self waitForTimeInterval: 1];
    XCTAssertEqual(self.metricsMock.sentMetrics.count, 0);
}

- (NSDictionary *)tags {
    return @{ @"tag": @"1" };
}

- (NSError *)mockedError {
    return [NSError errorWithDomain: @"test"
                               code: 0
                           userInfo: nil];
}

- (void)emulateInitializationFailure {
    [_initializationSubject triggerSdkInitializeDidFail: @"InitFailed"
                                                   code: 0];
}

- (void)emulateInitializationSucceed {
    [_initializationSubject triggerSdkDidInitialize];
}

@end
