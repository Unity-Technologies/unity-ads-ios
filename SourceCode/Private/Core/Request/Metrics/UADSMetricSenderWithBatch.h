#import "USRVSDKMetrics.h"
#import "UADSMetricSender.h"
#import "UADSConfigurationCRUDBase.h"
#import "UADSLogger.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSMetricSenderWithBatch : NSObject <ISDKMetrics, ISDKPerformanceMetricsSender>
@property (nonatomic, strong, nullable) NSString *metricEndpoint;
@property (nonatomic, strong) id <ISDKMetrics, ISDKPerformanceMetricsSender> original;
@property (nonatomic, assign) UADSMetricSenderState state;

+ (instancetype)decorateWithMetricSender: (id <ISDKMetrics, ISDKPerformanceMetricsSender>)original
                 andConfigurationSubject: (id<UADSConfigurationSubject>)subject
                               andLogger: (id<UADSLogger>)logger;
@end

NS_ASSUME_NONNULL_END
