#import "UADSMetricsContainer.h"

@interface UADSMetricsContainer ()
@property (nonatomic, strong) UADSMetricCommonTags *commonTags;
@property (nonatomic, strong) NSArray<UADSMetric *> *metrics;
@end

@implementation UADSMetricsContainer
- (instancetype)initWithCommonTags: (UADSMetricCommonTags *)tags metrics: (NSArray<UADSMetric *> *)metrics {
    SUPER_INIT;
    _commonTags = tags;
    _metrics = metrics;
    return self;
}

- (NSDictionary *)dictionary {
    NSMutableArray *metricsDict = [NSMutableArray array];

    for (UADSMetric *metric in self.metrics) {
        [metricsDict addObject: [metric dictionary]];
    }

    return @{
        @"m": metricsDict,
        @"t": [self.commonTags dictionary]
    };
}

@end
