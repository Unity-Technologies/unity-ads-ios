#import "SDKMetricsSenderMock.h"

@implementation SDKMetricsSenderMock

- (instancetype)init {
    self = [super init];
    _sentMetrics = [NSMutableArray array];
    return self;
}

- (void)sendEvent: (NSString *)event {
    [self sendMetrics: @[[UADSMetric newWithName: event
                                           value: nil
                                            tags: nil]]];
}

- (void)sendEvent: (NSString *)event value: (NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags {
    [self sendMetrics: @[[UADSMetric newWithName: event
                                           value: value
                                            tags: tags]]];
}

- (void)sendEventWithTags: (NSString *)event tags: (NSDictionary<NSString *, NSString *> *)tags {
    [self sendMetrics: @[[UADSMetric newWithName: event
                                           value: nil
                                            tags: tags]]];
}

- (void)sendMetric: (UADSMetric *)metric {
    [self sendMetrics: @[metric]];
}

- (void)sendMetrics: (NSArray<UADSMetric *> *)metrics {
    @synchronized (self) {
        self.callCount += 1;
        [self.sentMetrics addObjectsFromArray: metrics];
    }
    [self.exp fulfill];
}

- (void)measureDurationAndSend: (UADSMetricsMeasureBlock)measureBlock {
    UADSCompleteMeasureBlock complete = ^(UADSMetric *metric) {
        [self sendMetric: metric];
    };

    measureBlock(complete);
}

@end
