#import <XCTest/XCTest.h>
#import "USRVSDKMetrics.h"
#import "UADSMetricSenderWithBatch.h"
#import "SDKMetricsSenderMock.h"
#import "XCTestCase+Convenience.h"
#import "NSDate+Mock.h"
#import "NSArray+Map.h"
#import "UADSMetricSelectorMock.h"
#import "UADSGenericMediator.h"
#import "XCTestCase+Convenience.h"
#import "UADSLoggerMock.h"

@interface UADSConfigurationSubjectMock : UADSGenericMediator<USRVConfiguration *><UADSConfigurationSubject>
@end

@implementation UADSConfigurationSubjectMock

- (void)subscribeToConfigUpdates: (UADSConfigurationObserver)observer {
    [self subscribe: observer];
}

@end


@interface UADSMetricSenderWithBatchTest : XCTestCase
@property (nonatomic, strong) SDKMetricsSenderMock *mock;
@property (nonatomic, strong) UADSMetricSelectorMock *selectorMock;
@property (nonatomic, strong) UADSMetricSenderWithBatch *sut;
@property (nonatomic, strong) UADSConfigurationSubjectMock *mediator;
@property (nonatomic, strong) XCTestExpectation *exp;
@end

@implementation UADSMetricSenderWithBatchTest

- (void)setUp {
    _mock = [SDKMetricsSenderMock new];
    _selectorMock = [UADSMetricSelectorMock new];
    _mediator = [UADSConfigurationSubjectMock new];
    _sut = [UADSMetricSenderWithBatch newWithMetricSender: _mock
                                  andConfigurationSubject: _mediator
                                              andSelector: _selectorMock
                                                andLogger: [UADSLoggerMock new]];
}

- (void)test_batch_events_when_no_metric_url_is_set {
    [self setSenderExpectationWithInverted: true];
    [_sut sendEvent: @"test1 "];
    [self waitForExp];
    XCTAssertEqual(_mock.callCount, 0);


    [self setSenderExpectationWithInverted: true];
    [_sut sendEvent: @"test2 "];
    [self waitForExp];
    XCTAssertEqual(_mock.callCount, 0);

    [self setSenderExpectationWithInverted: false];
    [self emulateConfigurationUpdateWithAllowedMetrics: true];
    [_sut sendEvent: @"test3 "];
    [self waitForExp];
    NSArray *expected = @[ [UADSMetric newWithName: @"test1 "
                                             value: nil
                                              tags: nil], [UADSMetric newWithName: @"test2 "
                                                                            value: nil
                                                                             tags: nil], [UADSMetric newWithName: @"test3 "
                                                                                                           value: nil
                                                                                                            tags: nil] ];

    XCTAssertEqualObjects(_mock.sentMetrics, expected);

    expected = [expected arrayByAddingObject: [UADSMetric newWithName: @"test4 "
                                                                value: nil
                                                                 tags: nil] ];
    [self setSenderExpectationWithInverted: false];
    [_sut sendEvent: @"test4 "];
    [self waitForExp];
    XCTAssertEqualObjects(_mock.sentMetrics, expected);
}

- (void)test_batches_performance_metrics {
    [NSDate setMockDate: false];
    NSTimeInterval delay = 1;
    XCTestExpectation *exp = self.defaultExpectation;

    exp.expectedFulfillmentCount = 2;
    UADSMetric *testMetric1 = [UADSMetric newWithName: @"test1"
                                                value: nil
                                                 tags: nil];
    UADSMetric *testMetric2 = [UADSMetric newWithName: @"test2"
                                                value: nil
                                                 tags: nil];


    [_sut measureDurationAndSend:^(UADSCompleteMeasureBlock _Nonnull completion) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                           [NSThread sleepForTimeInterval: delay];
                           completion(testMetric1);
                           [exp fulfill];
                       });
    }];

    [self waitForTimeInterval: delay + 0.5];
    [self emulateConfigurationUpdateWithAllowedMetrics: true];

    [_sut measureDurationAndSend:^(UADSCompleteMeasureBlock _Nonnull completion) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
                           [NSThread sleepForTimeInterval: delay];
                           completion(testMetric2);
                           [exp fulfill];
                       });
    }];

    [self waitForExpectations: @[exp]
                      timeout: delay * 2 + 1];

    NSArray *expected = @[
        [testMetric1 updatedWithValue: @(delay)],
        [testMetric2 updatedWithValue: @(delay)]
    ];

    NSArray *received = [_mock.sentMetrics uads_mapObjectsUsingBlock:^id _Nonnull (UADSMetric *_Nonnull obj) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary: obj.dictionary];
        dictionary[@"v"] = @(round([dictionary[@"v"] intValue] / 1000));
        return dictionary;
    }];

    expected = [expected uads_mapObjectsUsingBlock:^id _Nonnull (UADSMetric *_Nonnull obj) {
        return obj.dictionary;
    }];

    XCTAssertEqualObjects(received, expected);
    [NSDate setMockDate: true];
}

- (void)test_doesnt_send_batch_when_selector_says_to_log {
    [self setSenderExpectationWithInverted: true];
    [_sut sendEvent: @"test1 "];
    [self waitForExp];
    XCTAssertEqual(_mock.callCount, 0);

    [self setSenderExpectationWithInverted: true];
    [_sut sendEvent: @"test2 "];
    [self waitForExp];
    XCTAssertEqual(_mock.callCount, 0);

    [self setSenderExpectationWithInverted: true];
    [self emulateConfigurationUpdateWithAllowedMetrics: false];
    [_sut sendEvent: @"test3 "];
    [self waitForExp];
    XCTAssertEqual(_mock.callCount, 0);
}

- (void)test_preserve_the_first_selector_decision {
    [self setSenderExpectationWithInverted: true];
    [self emulateConfigurationUpdateWithAllowedMetrics: false];
    [_sut sendEvent: @"test1 "];
    [self waitForExp];
    XCTAssertEqual(_mock.callCount, 0);

    [self setSenderExpectationWithInverted: true];
    [self emulateConfigurationUpdateWithAllowedMetrics: true];
    [_sut sendEvent: @"test2 "];
    [self waitForExp];
    XCTAssertEqual(_mock.callCount, 0);
}

- (void)test_does_not_send_events_when_queue_if_empty_after_url_set {
    [self setSenderExpectationWithInverted: true];
    [self emulateConfigurationUpdateWithAllowedMetrics: true];
    [self waitForExp];
    XCTAssertEqual(_mock.callCount, 0);
}

- (void)test_does_not_crash_when_events_added_from_multiple_threads {
    int threadCount = 1000;

    [self setSenderExpectationWithInverted: false];

    [self asyncExecuteTimes: threadCount
                      block:^(XCTestExpectation *_Nonnull expectation, int index) {
                          [self.sut sendEvent: [NSString stringWithFormat: @"test %d ", index]];
                          [expectation fulfill];
                      }];

    [self emulateConfigurationUpdateWithAllowedMetrics: true];
    [self waitForExp];
    XCTAssertEqual(_mock.callCount, 1);
    XCTAssertEqual(_mock.sentMetrics.count, threadCount);
}

- (void)test_subscribing_doesnt_cause_mem_leak {
    UADSMetricSenderWithBatch *obj;

    @autoreleasepool {
        obj = [UADSMetricSenderWithBatch newWithMetricSender: _mock
                                     andConfigurationSubject: _mediator
                                                 andSelector: _selectorMock
                                                   andLogger: [UADSLoggerMock new]];
        USRVConfiguration *configMock = [USRVConfiguration newFromJSON: @{}];
        [_mediator notifyObserversWithObjectAndRemove: configMock];
    }

    __weak UADSMetricSenderWithBatch *weakObj = obj;

    [self addTeardownBlock:^{
        XCTAssertNil(weakObj);
    }];
}

- (void)test_does_not_send_metric_twice {
    int threadCount = 10;

    [self setSenderExpectationWithInverted: false];
    self.exp.expectedFulfillmentCount = threadCount;
    [self emulateConfigurationUpdateWithAllowedMetrics: true];



    [self asyncExecuteTimes: threadCount
                      block:^(XCTestExpectation *_Nonnull expectation, int index) {
                          [self.sut sendEvent: [NSString stringWithFormat: @"test %d", index]];
                          [expectation fulfill];
                      }];
    [self waitForExp];
    XCTAssertEqual(_mock.callCount, threadCount);
    XCTAssertEqual(_mock.sentMetrics.count, threadCount);
}

- (void)emulateConfigurationUpdateWithAllowedMetrics: (BOOL)sendMetrics {
    USRVConfiguration *configMock = [USRVConfiguration newFromJSON: @{}];
    configMock.enableNativeMetrics = sendMetrics;
    [_mediator notifyObserversWithObjectAndRemove: configMock];
}

- (void)setSenderExpectationWithInverted: (BOOL)isInverted {
    _exp = [self expectationWithDescription: [NSString stringWithFormat: @"sender expectation %d", isInverted]];
    [_exp setInverted: isInverted];
    _mock.exp = _exp;
}

- (void)waitForExp {
    [self waitForExpectations: @[_exp]
                      timeout: 0.5];
}

@end
