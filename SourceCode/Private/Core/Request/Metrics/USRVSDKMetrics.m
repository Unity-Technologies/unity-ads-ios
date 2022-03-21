#import "USRVSDKMetrics.h"
#import "UADSMetricSender.h"
#import "UADSMetricSenderWithBatch.h"

@implementation UADSMetricsNullInstance
- (void)sendEvent: (NSString *)event {
    USRVLogDebug("Metric: %@ was skipped from being sent", event);
}

- (void)sendEventWithTags: (NSString *)event tags: (NSDictionary<NSString *, NSString *> *)tags {
    [self sendEvent: event];
}

- (void)sendEvent: (NSString *)event value: (NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags {
    [self sendEvent: event];
}

- (void)sendMetrics: (NSArray<UADSMetric *> *)metrics {
    USRVLogDebug("Metrics: %@ was skipped from being sent", metrics);
}

- (void)sendMetric: (UADSMetric *)metric {
    USRVLogDebug("Metric: %@ was skipped from being sent", metric);
}

@end

@implementation USRVSDKMetrics
static id <ISDKMetrics> _instance;
static UADSMetricSenderWithBatch *_batchedSender;

+ (void)setConfiguration: (USRVConfiguration *)configuration {
    [USRVSDKMetrics setConfiguration: configuration
                      requestFactory: [[USRVWebRequestFactory alloc] init]];
}

+ (void)setConfiguration: (USRVConfiguration *)configuration requestFactory: (id<IUSRVWebRequestFactoryStatic>)factory {
    if (configuration == nil) {
        USRVLogDebug("Metrics will not be sent from the device for this session due to misconfiguration");
        return;
    }

    if ([configuration metricSamplingRate] >= (arc4random_uniform(99) + 1)) {
        _instance = [[UADSMetricSender alloc] init: [configuration metricsUrl]
                                    requestFactory         : factory];
    } else {
        USRVLogDebug("Metrics will not be sent from the device for this session");
        _instance = [[UADSMetricsNullInstance alloc] init];
        _instance.metricEndpoint = [configuration metricsUrl];
    }

    if (_batchedSender == nil) {
        _batchedSender = [[UADSMetricSenderWithBatch alloc] initWithMetricSender: _instance];
    }

    _batchedSender.original = _instance;
    [_batchedSender sendQueueIfNeeded];
}

+ (id <ISDKMetrics>)getInstance {
    if (_instance == nil) {
        _instance = [[UADSMetricsNullInstance alloc] init];
    }

    if (_batchedSender == nil) {
        _batchedSender = [[UADSMetricSenderWithBatch alloc] initWithMetricSender: _instance];
    }

    return _batchedSender;
}

+ (void)reset {
    _instance = nil;
    _batchedSender = nil;
}

@end
