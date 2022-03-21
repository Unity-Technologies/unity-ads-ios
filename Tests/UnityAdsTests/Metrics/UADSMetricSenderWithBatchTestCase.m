#import <XCTest/XCTest.h>
#import "USRVSDKMetrics.h"
#import "UADSMetricSenderWithBatch.h"
#import "SDKMetricsSenderMock.h"

@interface UADSMetricSenderWithBatchTest : XCTestCase
@property (nonatomic, strong) SDKMetricsSenderMock *mock;
@property (nonatomic, strong) UADSMetricSenderWithBatch *sut;
@end

@implementation UADSMetricSenderWithBatchTest

- (void)setUp {
    _mock = [SDKMetricsSenderMock new];
    _sut = [[UADSMetricSenderWithBatch alloc] initWithMetricSender: _mock];
}

- (void)test_batch_events_when_no_metric_url_is_set {
    [_sut sendEvent: @"test1"];
    XCTAssertEqual(_mock.callCount, 0);

    [_sut sendEvent: @"test2"];
    XCTAssertEqual(_mock.callCount, 0);

    _mock.metricEndpoint = @"endpoint";
    [_sut sendEvent: @"test3"];
    NSArray *expected = @[ [UADSMetric newWithName: @"test1"
                                             value: nil
                                              tags: nil], [UADSMetric newWithName: @"test2"
                                                                            value: nil
                                                                             tags: nil], [UADSMetric newWithName: @"test3"
                                                                                                           value: nil
                                                                                                            tags: nil] ];

    XCTAssertEqualObjects(_mock.sentMetrics, expected);

    expected = [expected arrayByAddingObject: [UADSMetric newWithName: @"test4"
                                                                value: nil
                                                                 tags: nil] ];
    [_sut sendEvent: @"test4"];
    XCTAssertEqualObjects(_mock.sentMetrics, expected);
}

- (void)test_does_not_send_events_when_queue_if_empty_after_url_set {
    _mock.metricEndpoint = @"endpoint";
    [_sut sendQueueIfNeeded];

    XCTAssertEqual(_mock.callCount, 0);
}

- (void)test_does_not_crash_when_events_added_from_multiple_threads {
    int threadCount = 1000;
    XCTestExpectation *exp = [self expectationWithDescription: @"wait for adding"];

    exp.expectedFulfillmentCount = threadCount;

    for (int i = 0; i < threadCount; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.sut sendEvent: [NSString stringWithFormat: @"test%d", i]];
            [exp fulfill];
        });
    }

    [self waitForExpectations: @[exp]
                      timeout: 1.0];
    _mock.metricEndpoint = @"endpoint";
    [_sut sendQueueIfNeeded];

    XCTAssertEqual(_mock.callCount, 1);
    XCTAssertEqual(_mock.sentMetrics.count, threadCount);
}

@end
