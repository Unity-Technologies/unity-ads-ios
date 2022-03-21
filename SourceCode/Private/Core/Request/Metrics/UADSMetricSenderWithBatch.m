#import "UADSMetricSenderWithBatch.h"

@interface UADSMetricSenderWithBatch ()
@property (nonatomic, strong) NSMutableArray<UADSMetric *> *metricsQueue;
@end

@implementation UADSMetricSenderWithBatch

- (instancetype)initWithMetricSender: (id <ISDKMetrics>)original {
    SUPER_INIT

        _original = original;

    _metricsQueue = [NSMutableArray array];

    return self;
}

- (void)sendEvent: (NSString *)event {
    [self sendEventWithTags: event
                       tags: nil];
}

- (void)sendEventWithTags: (NSString *)event tags: (NSDictionary<NSString *, NSString *> *)tags {
    [self sendEvent: event
              value: nil
               tags: tags];
}

- (void)sendEvent: (NSString *)event value: (NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags {
    if (event == nil || [event isEqual: @""]) {
        USRVLogDebug(@"Metric event not sent due to being nil or empty: %@", event);
        return;
    }

    [self sendMetrics: @[[UADSMetric newWithName: event
                                           value: value
                                            tags: tags]]];
}

- (void)sendMetric: (UADSMetric *)metric {
    [self sendMetrics: @[metric]];
}

- (void)sendMetrics: (NSArray<UADSMetric *> *)metrics {
    NSArray *eventsToSend = [self appendToQueue: metrics];

    if (self.original.metricEndpoint && eventsToSend.count > 0) {
        [self.original sendMetrics: eventsToSend];
        [self clearQueue];
    }
}

- (void)sendQueueIfNeeded {
    [self sendMetrics: @[]];
}

- (void)clearQueue {
    @synchronized (self.metricsQueue) {
        [self.metricsQueue removeAllObjects];
    }
}

- (NSArray *)appendToQueue: (NSArray<UADSMetric *> *)metrics {
    NSArray *eventsToSend = metrics;

    @synchronized (self.metricsQueue) {
        [self.metricsQueue addObjectsFromArray: metrics];
        eventsToSend = [NSArray arrayWithArray: self.metricsQueue];
    }
    return eventsToSend;
}

@end
