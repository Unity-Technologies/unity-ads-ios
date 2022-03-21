#import "SDKMetricsSenderMock.h"

@implementation SDKMetricsSenderMock

- (instancetype)init {
    self = [super init];
    _sentMetrics = [NSMutableArray array];
    return self;
}

- (void)sendEvent: (NSString *)event {
    self.callCount += 1;
    [self.sentMetrics addObject: [UADSMetric newWithName: event
                                                   value: nil
                                                    tags: nil]];
}

- (void)sendEvent: (NSString *)event value: (NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags {
    self.callCount += 1;
    [self.sentMetrics addObject: [UADSMetric newWithName: event
                                                   value: value
                                                    tags: tags]];
}

- (void)sendEventWithTags: (NSString *)event tags: (NSDictionary<NSString *, NSString *> *)tags {
    self.callCount += 1;
    [self.sentMetrics addObject: [UADSMetric newWithName: event
                                                   value: nil
                                                    tags: tags]];
}

- (void)sendMetric: (UADSMetric *)metric {
    self.callCount += 1;
    [self.sentMetrics addObject: metric];
}

- (void)sendMetrics: (NSArray<UADSMetric *> *)metrics {
    self.callCount += 1;
    [self.sentMetrics addObjectsFromArray: metrics];
}

@end
