#import "USRVConfiguration.h"
#import "USRVWebRequestFactory.h"
#import "UADSMetric.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ISDKMetrics<NSObject>

@property (nonatomic, strong, nullable) NSString *metricEndpoint;

- (void)sendEvent: (NSString *)event;
- (void)sendEventWithTags: (NSString *)event tags: (nullable NSDictionary<NSString *, NSString *> *)tags;
- (void)sendEvent: (NSString *)event value: (nullable NSNumber *)value tags: (nullable NSDictionary<NSString *, NSString *> *)tags;
- (void)sendMetric: (UADSMetric *)metric;
- (void)sendMetrics: (NSArray<UADSMetric *> *)metrics;
@end

@interface USRVSDKMetrics : NSObject
+ (void)setConfiguration: (nullable USRVConfiguration *)configuration;
+ (void)setConfiguration: (nullable USRVConfiguration *)configuration requestFactory: (id<IUSRVWebRequestFactoryStatic>)factory;
+ (id <ISDKMetrics>)getInstance;
+ (void)            reset;
@end

@interface UADSMetricsNullInstance : NSObject <ISDKMetrics>
@property (nonatomic, strong, nullable) NSString *metricEndpoint;
@end

NS_ASSUME_NONNULL_END
