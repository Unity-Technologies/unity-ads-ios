#import "USRVSDKMetrics.h"
#import "UADSMetricSender.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSMetricSenderWithBatch : NSObject <ISDKMetrics>
@property (nonatomic, strong, nullable) NSString *metricEndpoint;
@property (nonatomic, strong) id <ISDKMetrics> original;

- (instancetype)initWithMetricSender: (id <ISDKMetrics>)original;
- (void)        sendQueueIfNeeded;
@end

NS_ASSUME_NONNULL_END
