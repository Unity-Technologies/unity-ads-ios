#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol UADSMetricsSelector <NSObject>
- (BOOL)shouldSendMetricsForSampleRate: (int)sampleRate;
@end

@interface UADSMetricsSelectorBase : NSObject<UADSMetricsSelector>

@end

NS_ASSUME_NONNULL_END
