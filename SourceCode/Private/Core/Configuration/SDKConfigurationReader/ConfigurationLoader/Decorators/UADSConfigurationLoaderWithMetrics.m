#import "UADSConfigurationLoaderWithMetrics.h"
#import "UADSTsiMetric.h"

@interface UADSConfigurationLoaderWithMetrics ()

@property (nonatomic, strong) id<UADSConfigurationLoader> original;
@property (nonatomic, strong) id<ISDKPerformanceMetricsSender, ISDKMetrics> metricsSender;
@property (nonatomic, strong) id<UADSRetryInfoReader> retryInfoReader;
@end

@implementation UADSConfigurationLoaderWithMetrics

+ (instancetype)decorateOriginal: (id<UADSConfigurationLoader>)original
                andMetricsSender: (id<ISDKPerformanceMetricsSender, ISDKMetrics>)metricsSender
                 retryInfoReader: (id<UADSRetryInfoReader>)retryInfoReader {
    UADSConfigurationLoaderWithMetrics *decorator = [self new];

    decorator.original = original;
    decorator.metricsSender = metricsSender;
    decorator.retryInfoReader = retryInfoReader;
    return decorator;
}

- (void)loadConfigurationWithSuccess: (nonnull NS_NOESCAPE UADSConfigurationCompletion)success
                  andErrorCompletion: (nonnull NS_NOESCAPE UADSErrorCompletion)error {
    [_metricsSender measureDurationAndSend:^(UADSCompleteMeasureBlock _Nonnull metricCompletion) {
        [self callOriginalWithSuccess: success
                   andErrorCompletion: error
                 andMetricsCompletion: metricCompletion];
    }];
}

- (void)callOriginalWithSuccess: (UADSConfigurationCompletion)success
             andErrorCompletion: (UADSErrorCompletion)errorCompletion
           andMetricsCompletion: (UADSCompleteMeasureBlock)metricsCompletion {
    id configSuccess = ^(USRVConfiguration *config) {
        UADSTsiMetric *metric = [UADSTsiMetric newTokenResolutionRequestLatency: 0
                                                                           tags: self.retryInfoReader.retryTags];
        metricsCompletion(metric);
        [self sendConfigMetrics:config];
        success(config);
    };


    id configError = ^(id<UADSError> error) {
        NSMutableDictionary *tags = [NSMutableDictionary dictionary];
        tags[@"reason"] = uads_configurationErrorTypeToString(error.errorCode.intValue) ? : [error.errorCode stringValue];
        [tags addEntriesFromDictionary: self.retryInfoReader.retryTags];
        UADSMetric *metric = [UADSTsiMetric newTokenResolutionRequestFailureLatency: tags];
        metricsCompletion(metric);
        errorCompletion(error);
    };

    [_original loadConfigurationWithSuccess: configSuccess
                         andErrorCompletion: configError];
}

- (void)sendConfigMetrics: (USRVConfiguration *)config {
    if (!config.headerBiddingToken) {
        [self.metricsSender sendMetric: [UADSTsiMetric newMissingToken]];
    }

    if (!config.stateId) {
        [self.metricsSender sendMetric: [UADSTsiMetric newMissingStateId]];
    }
}

@end
