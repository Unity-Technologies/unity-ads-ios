#import "UADSMetricSenderWithBatch.h"

@interface UADSMetricSenderWithBatch ()
@property (nonatomic, strong) NSMutableArray<UADSMetric *> *metricsQueue;
@property (nonatomic, strong) id<UADSLogger>logger;
@property (nonatomic) dispatch_queue_t syncQueue;
@end

@implementation UADSMetricSenderWithBatch

+ (instancetype)decorateWithMetricSender: (id<ISDKMetrics, ISDKPerformanceMetricsSender>)original andConfigurationSubject: (id<UADSConfigurationSubject>)subject
                               andLogger: (nonnull id<UADSLogger>)logger {
    UADSMetricSenderWithBatch *decorator = [UADSMetricSenderWithBatch new];

    decorator.original = original;
    decorator.state = kUADSMetricSenderStateWaiting;
    decorator.metricsQueue = [NSMutableArray new];
    decorator.syncQueue = dispatch_queue_create("com.dispatch.UADSMetricSenderWithBatch", DISPATCH_QUEUE_SERIAL);
    decorator.logger = logger;
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

        if (weakSelf.state != kUADSMetricSenderStateWaiting) {
            [weakSelf clearQueue];
            [self logMetrics: eventsToSend];
        }

        if (weakSelf.state == kUADSMetricSenderStateSend && eventsToSend.count > 0) {
            [weakSelf.original sendMetrics: eventsToSend];
        }
    });
}

- (void)logMetrics: (NSArray<UADSMetric *> *)metrics {
    for (UADSMetric *metric in metrics) {
        NSString *actionMessage = _state == kUADSMetricSenderStateLog ? @"Skipping" : @"Sending";
        NSString *logMessage = [NSString stringWithFormat: @"%@ metric: \r%@\r ", actionMessage, metric];
        UADSLogRecordBase *log = [UADSLogRecordBase newWithSystem: @"METRICS"
                                                       andMessage: logMessage
                                                         andLevel: kUADSLogLevelDebug];

        [self.logger logRecord: log];
    }
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

- (void)measureDurationAndSend: (UADSMetricsMeasureBlock)measureBlock {
    __block UADSMetric *metricToSend;

    __weak typeof(self) weakSelf = self;

    uads_measure_duration_round_async(^(UADSVoidClosure _Nonnull completion) {
        measureBlock(^(UADSMetric *metric) {
            metricToSend = metric;
            completion();
        });
    }, ^(NSNumber *duration) {
        metricToSend = [metricToSend updatedWithValue: duration];
        [weakSelf sendMetrics: @[metricToSend]];
    });
}

- (void)configurationUpdated: (USRVConfiguration *)configuration {
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.syncQueue, ^{
        BOOL shouldSend = configuration.enableNativeMetrics;
        weakSelf.state = shouldSend ? kUADSMetricSenderStateSend : kUADSMetricSenderStateLog;

        [weakSelf sendQueueIfNeeded];
    });
}

@end
