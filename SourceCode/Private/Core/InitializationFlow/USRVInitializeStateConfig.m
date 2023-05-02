#import "USRVInitializeStateConfig.h"
#import "USRVSdkProperties.h"
#import "USRVInitializeStateLoadCache.h"
#import "USRVInitializeStateLoadCacheConfigAndWebView.h"
#import "USRVInitializeStateRetry.h"
#import "USRVInitializeStateNetworkError.h"

#import "UADSHeaderBiddingTokenReaderBuilder.h"
#import "UADSServiceProviderContainer.h"
#import "UADSInitializeEventsMetricSender.h"

@interface USRVInitializeStateConfig ()

@end

@implementation USRVInitializeStateConfig : USRVInitializeState

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration retries: (int)retries retryDelay: (long)retryDelay {
    self = [super initWithConfiguration: configuration];

    if (self) {
        self.localConfig = configuration;
        //read from local config
        self.configuration = [[USRVConfiguration alloc] initWithConfigUrl: [USRVSdkProperties getConfigUrl]];
        self.configLoader = [UADSServiceProviderContainer.sharedInstance.serviceProvider configurationLoader];

        [self setRetries: retries];
        [self setRetryDelay: retryDelay];
    }

    return self;
}

- (instancetype)execute {
    USRVLogInfo(@"\n=============== %@ ============= \n", NSStringFromClass([self class]));
    return [self executeWithLoader];
} /* execute */

- (instancetype)executeWithLoader {
    USRVLogInfo(@"\n=============== %@ TSI FLOW/ USING LOADER ============= \n", NSStringFromClass([self class]));


    __block NSError *configError;
    id success = ^(USRVConfiguration *config) {
        self.configuration = config;
        USRVLogInfo(@"Config received");
    };

    id error = ^(NSError *error) {
        configError = error;
    };

    [self.configLoader loadConfigurationWithSuccess: success
                                 andErrorCompletion: error];

    if (!configError) {
        if (self.configuration.delayWebViewUpdate) {
            id nextState = [[USRVInitializeStateLoadCacheConfigAndWebView alloc] initWithConfiguration: self.configuration
                                                                                           localConfig: self.localConfig];
            return nextState;
        } else {
            id nextState = [[USRVInitializeStateLoadCache alloc] initWithConfiguration: self.configuration];
            return nextState;
        }
    } else if (configError && self.retries < [self.configuration maxRetries]) {
        if (configError.code == kPrivacyGameIdDisabledCode) {
            id nextState = [[USRVInitializeStateError alloc] initWithConfiguration: self.configuration
                                                                      erroredState: self
                                                                              code: kUADSErrorStateNetworkConfigRequest
                                                                           message: @"GameId disabled"];
            return nextState;
        }
    
        self.retryDelay = self.retryDelay * [self.configuration retryScalingFactor];
        self.retries++;
        [[UADSInitializeEventsMetricSender sharedInstance] didRetryConfig];
        id retryState = [[USRVInitializeStateConfig alloc] initWithConfiguration: self.localConfig
                                                                         retries: self.retries
                                                                      retryDelay: self.retryDelay];
        id nextState = [[USRVInitializeStateRetry alloc] initWithConfiguration: self.localConfig
                                                                    retryState: retryState
                                                                    retryDelay: self.retryDelay];
        return nextState;
    } else {
        id erroredState = [[USRVInitializeStateConfig alloc] initWithConfiguration: self.localConfig
                                                                           retries: self.retries
                                                                        retryDelay: self.retryDelay];
        id nextState = [[USRVInitializeStateNetworkError alloc] initWithConfiguration: self.localConfig
                                                                         erroredState: erroredState
                                                                                 code: kUADSErrorStateNetworkConfigRequest
                                                                              message: @"Network error occured init SDK initialization, waiting for connection"];
        return nextState;
    }
}


- (void)startWithCompletion:(void (^)(void))completion error:(void (^)(NSError * _Nonnull))error {
    
    USRVLogInfo(@"\n=============== %@ TSI FLOW/ USING LOADER ============= \n", NSStringFromClass([self class]));


    __block NSError *configError;
    id success = ^(USRVConfiguration *config) {
        self.configuration = config;
        completion();
        USRVLogInfo(@"Config received");
    };

    id errorCompletion = ^(NSError *receivedError) {
        configError = receivedError;
        [self processError: receivedError
             andCompletion: completion
                     error: error];
    };

    [self.configLoader loadConfigurationWithSuccess: success
                                 andErrorCompletion: errorCompletion];

}

- (void)processError: (NSError *)configError
       andCompletion: (void (^)(void))completion
               error:(void (^)(NSError * _Nonnull))error  {
    if (configError && self.retries < [self.configuration maxRetries]) {
        if (configError.code == kPrivacyGameIdDisabledCode) {
            id nextState = [[USRVInitializeStateError alloc] initWithConfiguration: self.configuration
                                                                      erroredState: self
                                                                              code: kUADSErrorStateNetworkConfigRequest
                                                                           message: @"GameId disabled"];
            [nextState startWithCompletion:completion error:error];
        } else {
            self.retryDelay = self.retryDelay * [self.configuration retryScalingFactor];
            self.retries++;
            [[UADSInitializeEventsMetricSender sharedInstance] didRetryConfig];
            USRVInitializeStateConfig *retryState = [[USRVInitializeStateConfig alloc] initWithConfiguration: self.localConfig];
            retryState.configuration = self.localConfig;
            retryState.localConfig = self.localConfig;
            [retryState setRetries: self.retries];
            [retryState setRetryDelay: self.retryDelay];
            retryState.configLoader = self.configLoader;

            id nextState = [[USRVInitializeStateRetry alloc] initWithConfiguration: self.localConfig
                                                                        retryState: retryState
                                                                        retryDelay: self.retryDelay];
            [nextState startWithCompletion:^{
                self.retries = retryState.retries;
                completion();
            } error:^(NSError * _Nonnull er) {
                self.retries = retryState.retries;
                error(er);
            }];
        }
    } else {
        USRVInitializeStateConfig *erroredState = [[USRVInitializeStateConfig alloc] initWithConfiguration: self.localConfig
                                                                           retries: self.retries
                                                                        retryDelay: self.retryDelay];
        id nextState = [[USRVInitializeStateNetworkError alloc] initWithConfiguration: self.localConfig
                                                                         erroredState: erroredState
                                                                                 code: kUADSErrorStateNetworkConfigRequest
                                                                              message: @"Network error occured init SDK initialization, waiting for connection"];
        [nextState startWithCompletion:^{
            self.retries = erroredState.retries;
            completion();
        } error:^(NSError * _Nonnull er) {
            self.retries = erroredState.retries;
            error(er);
        }];
    }
}

- (NSInteger)retryCount {
    return self.retries;
}

@end
