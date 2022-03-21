#import "UADSMetricSender.h"
#import "USRVWebRequest.h"
#import "USRVSdkProperties.h"
#import "USRVDevice.h"
#import "NSDictionary+JSONString.h"
#import "UADSMetric.h"
#import "UADSMetricCommonTags.h"
#import "UADSMetricsContainer.h"

@interface UADSMetricSender ()
@property (nonatomic, strong) dispatch_queue_t metricQueue;
@property (nonatomic, strong) NSObject<IUSRVWebRequestFactoryStatic> *requestFactory;
@property (nonatomic, strong) UADSMetricCommonTags *commonTags;

@end

@implementation UADSMetricSender

- (instancetype)init: (NSString *)url requestFactory: (id<IUSRVWebRequestFactoryStatic>)factory {
    self = [super init];

    if (self) {
        self.metricEndpoint = url;
        self.metricQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        self.requestFactory = factory;
        self.commonTags = [[UADSMetricCommonTags alloc] initWithCountryISO: [USRVDevice getNetworkCountryISOWithLocaleFallback]
                                                                  platform: @"ios"
                                                                sdkVersion: [USRVSdkProperties getVersionName]
                                                             systemVersion: [USRVDevice getOsVersion]];
    }

    return self;
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
            UADSMetricsContainer *container = [[UADSMetricsContainer alloc] initWithCommonTags: self.commonTags
                                                                                       metrics: metrics];
            NSString *postBody = [[container dictionary] jsonEncodedString];

            id<USRVWebRequest> request = [[self.requestFactory class] create: self.metricEndpoint
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

@end
