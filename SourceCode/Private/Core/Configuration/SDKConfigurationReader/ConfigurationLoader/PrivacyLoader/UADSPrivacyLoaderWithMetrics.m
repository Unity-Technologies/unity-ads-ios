#import "UADSPrivacyLoaderWithMetrics.h"
#import "UADSPrivacyMetrics.h"

@interface UADSPrivacyLoaderWithMetrics ()
@property (nonatomic, strong) id<UADSPrivacyLoader> original;
@property (nonatomic, strong) id<ISDKPerformanceMetricsSender> metricsSender;
@property (nonatomic, strong) id<UADSRetryInfoReader> retryInfoReader;
@end

@implementation UADSPrivacyLoaderWithMetrics


+ (instancetype)decorateOriginal: (id<UADSPrivacyLoader>)original
                andMetricsSender: (id<ISDKPerformanceMetricsSender>)metricsSender
                 retryInfoReader: (id<UADSRetryInfoReader>)retryInfoReader {
    UADSPrivacyLoaderWithMetrics *decorator = [self new];

    decorator.original = original;
    decorator.metricsSender = metricsSender;
    decorator.retryInfoReader = retryInfoReader;
    return decorator;
}

- (void)loadPrivacyWithSuccess: (UADSPrivacyCompletion)success
            andErrorCompletion: (UADSErrorCompletion)errorCompletion {
    [_metricsSender measureDurationAndSend:^(UADSCompleteMeasureBlock _Nonnull metricCompletion) {
        [self callOriginalWithSuccess: success
                   andErrorCompletion: errorCompletion
                 andMetricsCompletion: metricCompletion];
    }];
}

- (void)callOriginalWithSuccess: (UADSPrivacyCompletion)success
             andErrorCompletion: (UADSErrorCompletion)errorCompletion
           andMetricsCompletion: (UADSCompleteMeasureBlock)metricsCompletion {
    id privacySuccess = ^(UADSInitializationResponse *response) {
        metricsCompletion([UADSPrivacyMetrics newPrivacyRequestSuccessLatency: self.retryInfoReader.retryTags]);
        success(response);
    };


    id privacyError = ^(id<UADSError> error) {
        NSMutableDictionary *tags = [NSMutableDictionary dictionary];
        tags[@"reason"] = uads_privacyErrorTypeToString(error.errorCode.intValue) ? : [error.errorCode stringValue];
        [tags addEntriesFromDictionary: self.retryInfoReader.retryTags];
        metricsCompletion([UADSPrivacyMetrics newPrivacyRequestErrorLatency: tags]);
        errorCompletion(error);
    };

    [_original loadPrivacyWithSuccess: privacySuccess
                   andErrorCompletion: privacyError];
}

@end
