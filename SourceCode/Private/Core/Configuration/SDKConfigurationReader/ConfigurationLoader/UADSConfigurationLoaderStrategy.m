#import "UADSConfigurationLoaderStrategy.h"
#import "NSDictionary+JSONString.h"
#import "UADSConfigurationLoader.h"
#import "UADSConfigurationExperiments.h"
#import "UADSTsiMetric.h"
#import "USRVSDKMetrics.h"

@interface UADSConfigurationLoaderStrategy ()
@property (nonatomic, strong) id<UADSConfigurationLoader> mainLoader;
@property (nonatomic, strong) id<UADSConfigurationLoader> fallbackLoader;
@property (nonatomic, strong) id<ISDKMetrics> metricSender;
@end

@implementation UADSConfigurationLoaderStrategy


+ (id<UADSConfigurationLoader>)newWithMainLoader: (id<UADSConfigurationLoader>)mainLoader
                               andFallbackLoader: (id<UADSConfigurationLoader>)fallbackLoader
                                    metricSender: (id<ISDKMetrics>)metricSender {
    UADSConfigurationLoaderStrategy *strategy = [UADSConfigurationLoaderStrategy new];

    strategy.mainLoader = mainLoader;
    strategy.fallbackLoader = fallbackLoader;
    strategy.metricSender = metricSender;
    return strategy;
}

- (void)loadConfigurationWithSuccess: (NS_NOESCAPE UADSConfigurationCompletion)success andErrorCompletion: (NS_NOESCAPE UADSErrorCompletion)error {
    id newSuccess = ^(USRVConfiguration *config) {
        success(config);
        [self sendConfigMetrics: config];
    };

    id newError = ^(id<UADSError> mainError) {
        [self processError: mainError
                   withSuccess: success
            andErrorCompletion: error];
    };

    [_mainLoader loadConfigurationWithSuccess: newSuccess
                           andErrorCompletion: newError];
}

- (void)  processError: (id<UADSError>)error
           withSuccess: (NS_NOESCAPE UADSConfigurationCompletion)success
    andErrorCompletion: (NS_NOESCAPE UADSErrorCompletion)errorCompletion {
    if (![self shouldFallbackForError: error]) {
        errorCompletion(error);
        return;
    }

    [_fallbackLoader loadConfigurationWithSuccess: success
                               andErrorCompletion: errorCompletion];
    [self sendFallbackMetric];
}

- (BOOL)shouldFallbackForError: (id<UADSError>)error {
    if (_fallbackLoader == nil) {
        return false;
    }

    return error.errorDomain == kConfigurationLoaderErrorDomain;
}

- (void)sendConfigMetrics: (USRVConfiguration *)config {
    if (!config.headerBiddingToken) {
        [self.metricSender sendMetric: [UADSTsiMetric newMissingToken]];
    }

    if (!config.stateId) {
        [self.metricSender sendMetric: [UADSTsiMetric newMissingStateId]];
    }
}

- (void)sendFallbackMetric {
    [self.metricSender sendMetric: [UADSTsiMetric newEmergencySwitchOff]];
}

@end
