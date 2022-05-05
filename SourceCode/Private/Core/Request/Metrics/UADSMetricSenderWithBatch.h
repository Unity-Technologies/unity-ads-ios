#import "USRVSDKMetrics.h"
#import "UADSMetricSender.h"
#import "UADSConfigurationCRUDBase.h"
#import "UADSMetricsSelector.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSMetricSenderWithBatch : NSObject <ISDKMetrics>
@property (nonatomic, strong, nullable) NSString *metricEndpoint;
@property (nonatomic, strong) id <ISDKMetrics> original;


+ (instancetype)newWithMetricSender: (id <ISDKMetrics>)original
            andConfigurationSubject: (id<UADSConfigurationSubject>)subject
                        andSelector: (id<UADSMetricsSelector>)selector;

+ (instancetype)decorateWithMetricSender: (id <ISDKMetrics>)original
                 andConfigurationSubject: (id<UADSConfigurationSubject>)subject;

- (void)        sendQueueIfNeeded;
@end

NS_ASSUME_NONNULL_END
