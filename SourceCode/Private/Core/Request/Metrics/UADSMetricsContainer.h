#import "UADSDictionaryConvertible.h"
#import "UADSMetricCommonTags.h"
#import "UADSMetric.h"

@interface UADSMetricsContainer : NSObject <UADSDictionaryConvertible>
- (instancetype)initWithCommonTags: (UADSMetricCommonTags *)tags
                           metrics: (NSArray<UADSMetric *> *)metrics
                              info: (NSDictionary *)commonInfo;
@end
