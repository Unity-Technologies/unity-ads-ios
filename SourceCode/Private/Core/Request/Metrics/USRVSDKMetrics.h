#import "USRVConfiguration.h"
#import "USRVWebRequestFactory.h"
#import "UADSMetric.h"
#import "UADSTools.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger, UADSMetricSenderState) {
    kUADSMetricSenderStateWaiting,
    kUADSMetricSenderStateSend,
    kUADSMetricSenderStateLog
};

typedef  void (^UADSCompleteMeasureBlock)(UADSMetric *);
typedef void (^UADSMetricsMeasureBlock)(UADSCompleteMeasureBlock);

@protocol ISDKMetrics<NSObject>

@property (nonatomic, strong, nullable) NSString *metricEndpoint;
@property (nonatomic, assign) UADSMetricSenderState state;

- (void)sendEvent: (NSString *)event;
- (void)sendEventWithTags: (NSString *)event tags: (nullable NSDictionary<NSString *, NSString *> *)tags;
- (void)sendEvent: (NSString *)event value: (nullable NSNumber *)value tags: (nullable NSDictionary<NSString *, NSString *> *)tags;
- (void)sendMetric: (UADSMetric *)metric;
- (void)sendMetrics: (NSArray<UADSMetric *> *)metrics;
@end



@protocol ISDKPerformanceMetricsSender<NSObject>
- (void)measureDurationAndSend: (UADSMetricsMeasureBlock)measureBlock;
@end

@interface USRVSDKMetrics : NSObject
//+ (void)setConfiguration: (nullable USRVConfiguration *)configuration;
//+ (void)setConfiguration: (nullable USRVConfiguration *)configuration requestFactory: (id<IUSRVWebRequestFactoryStatic>)factory;
+ (id <ISDKMetrics>)getInstance;
//+ (void)            reset;
@end

NS_ASSUME_NONNULL_END
