#import "UADSInitializeEventsMetricSender.h"
#import "UADSTsiMetric.h"
#import "UADSConfigurationCRUDBase.h"
#import "UADSCurrentTimestampBase.h"
#import "USRVInitializationNotificationCenter.h"
#import "UADSServiceProviderContainer.h"

@interface UADSInitializeEventsMetricSender ()<USRVInitializationDelegate>
@property (nonatomic, assign) CFTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval epochStartTime;
@property (nonatomic, strong) id<ISDKMetrics> metricSender;
@property (nonatomic, strong, nonnull) id<UADSCurrentTimestamp> timestampReader;
@property (nonatomic, assign) BOOL initMetricSent;
@property (nonatomic, assign) BOOL tokenMetricSent;
@property (nonatomic, assign) NSInteger configRetryCount;
@property (nonatomic, assign) NSInteger webviewRetryCount;
@end

@implementation UADSInitializeEventsMetricSender

_uads_custom_singleton_imp(UADSInitializeEventsMetricSender, ^{
    return [[UADSInitializeEventsMetricSender alloc] initWithMetricSender: UADSServiceProviderContainer.sharedInstance.serviceProvider.metricSender
                                                         currentTimestamp: [UADSCurrentTimestampBase new]
                                                              initSubject: USRVInitializationNotificationCenter.sharedInstance];
})

- (instancetype)initWithMetricSender: (id<ISDKMetrics>)metricSender
                    currentTimestamp: (id<UADSCurrentTimestamp>)timestampReader
                         initSubject: (nonnull id<USRVInitializationNotificationCenterProtocol>)initializationSubject {
    SUPER_INIT;

    self.metricSender = metricSender;
    self.timestampReader = timestampReader;
    [initializationSubject addDelegate: self];
    return self;
}

- (void)didInitStart {
    self.startTime = self.timestampReader.currentTimestamp;
    self.epochStartTime = self.timestampReader.epochSeconds;
    self.configRetryCount = 0;
    self.webviewRetryCount = 0;

    [self.metricSender sendMetric: [UADSTsiMetric newInitStarted]];
}

- (void)didRetryConfig {
    self.configRetryCount += 1;
}

- (void)didRetryWebview {
    self.webviewRetryCount += 1;
}

- (void)sdkDidInitialize {
    @synchronized (self) {
        if (self.startTime == 0) {
            USRVLogDebug("sdkDidInitialize called before didInitStart, skipping metric");
            return;
        }

        if (!self.initMetricSent) {
            [self.metricSender sendMetric: [UADSTsiMetric newInitTimeSuccess: self.duration
                                                                        tags: self.retryTags]];
            self.initMetricSent = YES;
        }
    }
}

- (NSNumber *)initializationStartTimeStamp {
    return @(_epochStartTime);
}

- (void)sdkInitializeFailed: (NSError *)error {
    @synchronized (self) {
        if (self.startTime == 0) {
            USRVLogDebug("sdkInitializeFailed called before didInitStart, skipping metric");
            return;
        }

        if (!self.initMetricSent) {
            NSMutableDictionary *tags = [NSMutableDictionary dictionaryWithDictionary: @{
                                             @"stt": uads_errorStateString(error.code)
            }];
            [tags addEntriesFromDictionary: self.retryTags];
            [self.metricSender sendMetric: [UADSTsiMetric newInitTimeFailure: self.duration
                                                                        tags: tags]];
            self.initMetricSent = YES;
        }
    }
}

- (void)sendTokenAvailabilityLatencyOnceOfType: (UADSTokenAvailabilityType)type {
    @synchronized (self) {
        if (!self.tokenMetricSent) {
            [self sendTokenAvailabilityMetricOfType: type];
            self.tokenMetricSent = YES;
        }
    }
}

- (void)sendTokenAvailabilityMetricOfType: (UADSTokenAvailabilityType)type {
    if (self.startTime == 0) {
        USRVLogDebug("sdkTokenDidBecomeAvailable called before didInitStart, skipping metric");
        return;
    }

    NSNumber *duration = [self.timestampReader msDurationFrom: self.startTime];
    UADSTsiMetric *metric;

    switch (type) {
        case kUADSTokenAvailabilityTypeWeb:
            metric = [UADSTsiMetric newTokenAvailabilityLatencyWebview: duration
                                                                  tags: self.retryTags];

            break;

        case kUADSTokenAvailabilityTypeFirstToken:
            metric = [UADSTsiMetric newTokenAvailabilityLatencyConfig: duration
                                                                 tags: self.retryTags];
            break;
    }

    [self.metricSender sendMetric: metric];
}

- (NSNumber *)duration {
    return [self.timestampReader msDurationFrom: self.startTime];
}

- (NSDictionary *)retryTags {
    return @{
        @"c_retry": @(self.configRetryCount).stringValue,
        @"wv_retry": @(self.webviewRetryCount).stringValue
    };
}


- (void)resetForTests {
    @synchronized (self) {
        _initMetricSent = false;
        _tokenMetricSent = false;
        _webviewRetryCount = 0;
        _configRetryCount = 0;
        _startTime = 0;
        _epochStartTime = 0;
        
    }
 
    
}
@end
