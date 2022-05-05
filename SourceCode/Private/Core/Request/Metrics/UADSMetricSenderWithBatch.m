#import "UADSMetricSenderWithBatch.h"

typedef NS_ENUM (NSInteger, UADSMetricSenderWithBatchState) {
    kUADSMetricSenderWithBatchStateWaiting,
    kUADSMetricSenderWithBatchStateSend,
    kUADSMetricSenderWithBatchStateLog
};

@interface UADSMetricSenderWithBatch ()
@property (nonatomic, strong) NSMutableArray<UADSMetric *> *metricsQueue;
@property (nonatomic, strong) id<UADSMetricsSelector> selector;
@property (nonatomic, assign) UADSMetricSenderWithBatchState state;
@property (nonatomic) dispatch_queue_t syncQueue;
@end

@implementation UADSMetricSenderWithBatch

+ (instancetype)decorateWithMetricSender: (id<ISDKMetrics>)original andConfigurationSubject: (id<UADSConfigurationSubject>)subject {
    return [self newWithMetricSender: original
             andConfigurationSubject: subject
                         andSelector: [UADSMetricsSelectorBase new]];
}

+ (instancetype)newWithMetricSender: (id <ISDKMetrics>)original
            andConfigurationSubject: (id<UADSConfigurationSubject>)subject
                        andSelector: (id<UADSMetricsSelector>)selector {
    UADSMetricSenderWithBatch *decorator = [UADSMetricSenderWithBatch new];

    decorator.original = original;
    decorator.state = kUADSMetricSenderWithBatchStateWaiting;
    decorator.selector = selector;
    decorator.metricsQueue = [NSMutableArray new];
    decorator.syncQueue = dispatch_queue_create("com.dispatch.UADSMetricSenderWithBatch", DISPATCH_QUEUE_SERIAL);
    [subject subscribeToConfigUpdates:^(USRVConfiguration *_Nonnull config) {
        [decorator configurationUpdated: config];
    }];

    return decorator;
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
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.syncQueue, ^{
        NSArray *eventsToSend = [weakSelf appendToQueue: metrics];

        if (weakSelf.state != kUADSMetricSenderWithBatchStateWaiting) {
            [weakSelf clearQueue];
        }

        if (weakSelf.state == kUADSMetricSenderWithBatchStateSend && eventsToSend.count > 0) {
            [weakSelf.original sendMetrics: eventsToSend];
        }

        if (weakSelf.state == kUADSMetricSenderWithBatchStateLog) {
            USRVLogDebug("Metrics: %@ was skipped from being sent", eventsToSend);
        }
    });
}

- (void)sendQueueIfNeeded {
    [self sendMetrics: @[]];
}

- (void)clearQueue {
    [self.metricsQueue removeAllObjects];
}

- (NSArray *)appendToQueue: (NSArray<UADSMetric *> *)metrics {
    [self.metricsQueue addObjectsFromArray: metrics];
    return [NSArray arrayWithArray: self.metricsQueue];
}

- (void)configurationUpdated: (USRVConfiguration *)configuration {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.syncQueue, ^{
        BOOL shouldSend = [weakSelf.selector shouldSendMetricsForSampleRate: configuration.metricSamplingRate];
        weakSelf.state = shouldSend ? kUADSMetricSenderWithBatchStateSend : kUADSMetricSenderWithBatchStateLog;

        [weakSelf sendQueueIfNeeded];
    });
}

@end
