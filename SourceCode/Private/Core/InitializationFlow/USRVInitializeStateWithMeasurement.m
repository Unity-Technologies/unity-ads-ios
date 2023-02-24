#import "USRVInitializeStateWithMeasurement.h"
#import "UADSServiceProviderContainer.h"

@interface USRVInitializeStateWithMeasurement()
@property (nonatomic, strong) id<USRVInitializeTask> original;
@end

@implementation USRVInitializeStateWithMeasurement

+ (instancetype)newWithOriginal:(id<USRVInitializeTask>)original {
    USRVInitializeStateWithMeasurement *obj = [self new];
    obj.original = original;
    return original;
    
}

- (NSString *)systemName {
    return _original.systemName;
}
- (void)startWithCompletion:(void (^)(void))completion error:(void (^)(NSError * _Nonnull))error {
    [self startPerformanceMeasurement];

    id completionSuccess = ^ {
        [self calculateAndSendDuration];
        completion();
    };
    
    id errorCompletion = ^(NSError *stateError){
        [self calculateAndSendDuration];
        error(stateError);
    };

    [_original startWithCompletion:completionSuccess error:errorCompletion];

}

- (void)startPerformanceMeasurement {
    [UADSServiceProviderContainer.sharedInstance.serviceProvider.performanceMeasurer startMeasureForSystemIfNeeded: self.systemName];
}

- (void)calculateAndSendDuration {
    NSNumber *duration = [UADSServiceProviderContainer.sharedInstance.serviceProvider.performanceMeasurer endMeasureForSystem: self.systemName];
    UADSMetric *metric = [UADSMetric newWithName: self.systemName
                                           value: duration
                                            tags: UADSInitializeEventsMetricSender.sharedInstance.retryTags];
    [UADSServiceProviderContainer.sharedInstance.serviceProvider.metricSender sendMetric: metric];
    
}
@end
