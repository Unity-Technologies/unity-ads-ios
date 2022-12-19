#import "UADSMetricSender.h"
#import "USRVWebRequest.h"
#import "NSDictionary+JSONString.h"
#import "UADSMetricCommonTagsProvider.h"
#import "UADSMetricsContainer.h"
#import "UADSTools.h"

@interface UADSMetricSender ()
@property (nonatomic, strong) dispatch_queue_t metricQueue;
@property (nonatomic, strong) id<IUSRVWebRequestFactory> requestFactory;
@property (nonatomic, strong) id<UADSMetricCommonTagsProvider> commonTagsProvider;
@property (nonatomic, strong) id<UADSConfigurationReader, UADSConfigurationMetricTagsReader> configurationReader;
@end

@implementation UADSMetricSender

+ (instancetype)newWithConfigurationReader: (id<UADSConfigurationReader, UADSConfigurationMetricTagsReader>)configReader
                         andRequestFactory: (id<IUSRVWebRequestFactory>)factory
                             storageReader: (id<UADSJsonStorageReader>)storageReader
                             privacyReader: (id<UADSPrivacyResponseReader>)privacyReader {
    UADSMetricSender *sender = [UADSMetricSender new];

    sender.configurationReader = configReader;
    sender.requestFactory = factory;
    sender.metricQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    sender.commonTagsProvider = [UADSMetricCommonTagsProviderBase newWithTagsReader: configReader
                                                                      storageReader: storageReader
                                                                      privacyReader: privacyReader];
    return sender;
}

- (void)sendEvent: (NSString *)event {
    [self sendEventWithTags: event
                       tags: nil];
}

- (void)sendEventWithTags: (NSString *)event tags: (NSDictionary<NSString *, NSString *> *)tags {
    if (event == nil || [event isEqual: @""]) {
        USRVLogDebug(@"Metric event not sent due to being nil or empty: %@", event);
        return;
    }

    [self sendEvent: event
              value: nil
               tags: tags];
} /* sendEventWithTags */

- (void)sendEvent: (NSString *)event value: (NSNumber *)value tags: (NSDictionary<NSString *, NSString *> *)tags {
    [self sendMetrics: @[[UADSMetric newWithName: event
                                           value: value
                                            tags: tags]]];
}

- (void)sendMetric: (UADSMetric *)metric {
    [self sendMetrics: @[metric]];
}

- (void)sendMetrics: (NSArray<UADSMetric *> *)metrics {
    if (metrics == nil || metrics.count <= 0) {
        USRVLogDebug(@"Metrics event not sent due to being nil or empty: %@", metrics);
        return;
    }

    if (self.metricEndpoint == nil || [self.metricEndpoint isEqual: @""]) {
        USRVLogDebug(@"Metrics: %@ was not sent due to nil or empty endpoint: %@", metrics, self.metricEndpoint);
        return;
    }

    if (self.metricQueue == nil) {
        USRVLogDebug("Metrics: %@ was not sent due to misconfiguration", metrics);
        return;
    }

    dispatch_async(self.metricQueue, ^{
        @try {
            
            UADSMetricsContainer *container = [[UADSMetricsContainer alloc] initWithCommonTags: self.commonTagsProvider.commonTags
                                                                                       metrics: metrics
                                                                                          info: self.commonTagsProvider.commonInfo];
            NSString *postBody = [[container dictionary] uads_jsonEncodedString];

            id<USRVWebRequest> request = [self.requestFactory create: self.metricEndpoint
                                                         requestType: @"POST"
                                                             headers: NULL
                                                      connectTimeout: 30000];
            [request setBody: postBody];
            [request makeRequest];

            bool is2XXResponse = [request is2XXResponse];

            if (is2XXResponse) {
                USRVLogDebug("Metrics %@ sent to %@ ", metrics, self.metricEndpoint);
            } else {
                USRVLogDebug("Metrics %@ failed to send to %@ with response code %ld", metrics, self.metricEndpoint, [request responseCode]);
            }
        } @catch (NSException *exception) {
            USRVLogDebug("Metrics %@ failed to send from exception: %@", metrics, [exception name]);
        }
    });
}

- (void)measureDurationAndSend: (UADSMetricsMeasureBlock)measureBlock {
    __block UADSMetric *metricToSend;

    __weak typeof(self) weakSelf = self;

    uads_measure_duration_round_async(^(UADSVoidClosure _Nonnull completion) {
        measureBlock(^(UADSMetric *metric) {
            metricToSend = metric;
            completion();
        });
    }, ^(NSNumber *duration) {
        metricToSend = [metricToSend updatedWithValue: duration];
        [weakSelf sendMetrics: @[metricToSend]];
    });
}

- (NSString *)metricEndpoint {
    return [_configurationReader getCurrentMetricsUrl];
}

@end
