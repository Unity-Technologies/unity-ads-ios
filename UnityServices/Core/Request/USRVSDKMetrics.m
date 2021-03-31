#import "USRVSDKMetrics.h"
#import "USRVWebRequest.h"
#import "USRVWebRequestFactory.h"
#import "USRVSdkProperties.h"
#import "USRVDevice.h"
#include <stdlib.h>

@interface MetricInstance : NSObject <ISDKMetrics>
@property(nonatomic, strong) dispatch_queue_t metricQueue;
@property(nonatomic, strong) NSString *metricEndpoint;
@end

@interface NullInstance : NSObject <ISDKMetrics>
@end

@implementation NullInstance
- (void)sendEvent:(NSString *)event {
    USRVLogDebug("Metric: %@ was skipped from being sent", event);
}

- (void)sendEventWithTags:(NSString *)event tags:(NSDictionary<NSString *, NSString *> *)tags {
    [self sendEvent:event];
}

@end


@implementation MetricInstance

- (instancetype)init:(NSString *)url {
    self = [super init];
    if (self) {
        self.metricEndpoint = url;
        self.metricQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    }
    return self;
}

- (void)sendEvent:(NSString *)event {
    [self sendEventWithTags:event tags:nil];
}

- (void)sendEventWithTags:(NSString *)event tags:(NSDictionary<NSString *, NSString *> *)tags {
    if (event == nil || [event isEqual: @""]) {
        USRVLogDebug(@"Metric event not sent due to being nil or empty: %@", event);
        return;
    }
    
    if (self.metricEndpoint == nil || [self.metricEndpoint isEqual: @""]) {
        USRVLogDebug(@"Metric: %@ was not sent due to nil or empty endpoint: %@", event, self.metricEndpoint);
        return;
    }
    
    if (self.metricQueue == nil) {
        USRVLogDebug("Metric: %@ was not sent due to misconfiguration", event);
        return;
    }
    
    dispatch_async(self.metricQueue, ^{
        @try {
            NSString *tagString = @"";
            if (tags != nil) {
                NSData *jsonTags = [NSJSONSerialization dataWithJSONObject:tags options:0 error:nil];
                tagString = [NSString stringWithFormat:@",\"t\":%@", [[NSString alloc] initWithData:jsonTags encoding:NSUTF8StringEncoding]];
            }
            NSString *postBody = [NSString stringWithFormat:@"{\"m\":[{\"n\":\"%@\"%@}],\"t\":{\"iso\":\"%@\",\"plt\":\"ios\",\"sdv\":\"%@\"}}", event, tagString, [USRVDevice getNetworkCountryISO], [USRVSdkProperties getVersionName]];
            
            id<USRVWebRequest> request = [USRVWebRequestFactory create:self.metricEndpoint requestType:@"POST" headers:NULL connectTimeout:30000];
            [request setBody:postBody];
            [request makeRequest];

            bool is2XXResponse = (int)[request responseCode] / 100 == 2;
            if (is2XXResponse) {
                USRVLogDebug("Metric %@ with tags: %@ sent to %@ ", event, tagString, self.metricEndpoint);
            } else {
                USRVLogDebug("Metric %@ failed to send to %@ with response code %ld", event, self.metricEndpoint, [request responseCode]);
            }
        } @catch (NSException *exception) {
            USRVLogDebug("Metric %@ failed to send from exception: %@", event, [exception name]);
        }
    });
}

@end


@implementation USRVSDKMetrics
static id <ISDKMetrics> _instance;

+ (void)setConfiguration:(USRVConfiguration *)configuration {
    
    if (configuration == nil) {
        USRVLogDebug("Metrics will not be sent from the device for this session due to misconfiguration");
        return;
    }

    if ([configuration metricSamplingRate] >= (arc4random_uniform(99) + 1)) {
        _instance = [[MetricInstance alloc] init:[configuration metricsUrl]];
    } else {
        USRVLogDebug("Metrics will not be sent from the device for this session");
        _instance = [[NullInstance alloc] init];
    }
}

+ (id <ISDKMetrics>)getInstance {
    if (_instance == nil) {
        _instance = [[NullInstance alloc] init];
    }

    return _instance;
}
@end
