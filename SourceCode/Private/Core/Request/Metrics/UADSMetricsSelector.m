#import "UADSMetricsSelector.h"

@implementation UADSMetricsSelectorBase
- (BOOL)shouldSendMetricsForSampleRate: (int)sampleRate {
    return sampleRate >= (arc4random_uniform(99) + 1);
}

@end
