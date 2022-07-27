#import "USRVSDKMetrics.h"
#import "UADSMetricSender.h"
#import "UADSConfigurationCRUDBase.h"
#import "UADSMetricsSelector.h"
#import "UADSLogger.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSMetricSenderWithBatch : NSObject <ISDKMetrics, ISDKPerformanceMetricsSender>
@property (nonatomic, strong, nullable) NSString *metricEndpoint;
@property (nonatomic, strong) id <ISDKMetrics, ISDKPerformanceMetricsSender> original;
@property (nonatomic, assign) UADSMetricSenderState state;

+ (instancetype)newWithMetricSender: (id <ISDKMetrics, ISDKPerformanceMetricsSender>)original
            andConfigurationSubject: (id<UADSConfigurationSubject>)subject
                        andSelector: (id<UADSMetricsSelector>)selector
                          andLogger: (id<UADSLogger>)logger;

+ (instancetype)decorateWithMetricSender: (id <ISDKMetrics, ISDKPerformanceMetricsSender>)original
                 andConfigurationSubject: (id<UADSConfigurationSubject>)subject
                               andLogger: (id<UADSLogger>)logger;
@end

NS_ASSUME_NONNULL_END
