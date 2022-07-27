#import "UADSMetricsContainer.h"

@interface UADSMetricsContainer ()
@property (nonatomic, strong) UADSMetricCommonTags *commonTags;
@property (nonatomic, strong) NSArray<UADSMetric *> *metrics;
@property (nonatomic, strong) NSDictionary *commonInfo;
@end

@implementation UADSMetricsContainer
- (instancetype)initWithCommonTags: (UADSMetricCommonTags *)tags metrics: (NSArray<UADSMetric *> *)metrics info: (NSDictionary *)commonInfo {
    SUPER_INIT;
    _commonTags = tags;
    _metrics = metrics;
    _commonInfo = commonInfo;
    return self;
}

- (NSDictionary *)dictionary {
    NSMutableArray *metricsDict = [NSMutableArray array];

    for (UADSMetric *metric in self.metrics) {
        [metricsDict addObject: [metric dictionary]];
    }

    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: @{
                                     @"m": metricsDict,
                                     @"t": [self.commonTags dictionary]
    }];

    if (self.commonInfo) {
        [dict addEntriesFromDictionary: self.commonInfo];
    }

    return dict;
}

@end
