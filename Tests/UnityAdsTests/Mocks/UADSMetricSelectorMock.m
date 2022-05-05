#import "UADSMetricSelectorMock.h"

@implementation UADSMetricSelectorMock

- (BOOL)shouldSendMetricsForSampleRate: (int)sampleRate {
    return self.shouldSend;
}

@end
