#import "USRVSDKMetrics.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSMetricSender : NSObject <ISDKMetrics>

@property (nonatomic, strong, nullable) NSString *metricEndpoint;

- (instancetype)init: (NSString *)url requestFactory: (id<IUSRVWebRequestFactoryStatic>)factory;

@end

NS_ASSUME_NONNULL_END
