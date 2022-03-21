#import "UADSInitializeEventsMetricSender.h"
#import "UADSTsiMetric.h"
#import "UADSConfigurationReader.h"
#import "UADSCurrentTimestampBase.h"
#import "USRVInitializationNotificationCenter.h"

@interface UADSInitializeEventsMetricSender ()<USRVInitializationDelegate>
@property (nonatomic, assign) CFTimeInterval startTime;
@property (nonatomic, assign) CFTimeInterval configStartTime;
@property (nonatomic, strong) id<ISDKMetrics> metricSender;
@property (nonatomic, strong, nonnull) id<UADSConfigurationMetricTagsReader> tagsReader;
@property (nonatomic, strong, nonnull) id<UADSCurrentTimestamp> timestampReader;
@property (nonatomic, assign) BOOL initMetricSent;
@property (nonatomic, assign) BOOL tokenMetricSent;

@end

@implementation UADSInitializeEventsMetricSender

_uads_custom_singleton_imp(UADSInitializeEventsMetricSender, ^{
    return [[UADSInitializeEventsMetricSender alloc] initWithMetricSender: [USRVSDKMetrics getInstance]
                                                               tagsReader: [UADSConfigurationReaderBase new]
                                                         currentTimestamp: [UADSCurrentTimestampBase new]
                                                              initSubject: USRVInitializationNotificationCenter.sharedInstance];
})

- (instancetype)initWithMetricSender: (id<ISDKMetrics>)metricSender
                          tagsReader: (id<UADSConfigurationMetricTagsReader>)tagsReader
                    currentTimestamp: (id<UADSCurrentTimestamp>)timestampReader
                         initSubject: (nonnull id<USRVInitializationNotificationCenterProtocol>)initializationSubject {
    SUPER_INIT;

    self.metricSender = metricSender;
    self.tagsReader = tagsReader;
    self.timestampReader = timestampReader;
    [initializationSubject addDelegate: self];
    return self;
}

- (void)didInitStart {
    self.startTime = self.timestampReader.currentTimestamp;

    [self.metricSender sendMetric: [UADSTsiMetric newInitStartedWithTags: [self getExperimentTags]]];
}

- (void)didConfigRequestStart {
    self.configStartTime = self.timestampReader.currentTimestamp;
}

- (void)sdkDidInitialize {
    @synchronized (self) {
        if (self.startTime == 0) {
            USRVLogDebug("sdkDidInitialize called before didInitStart, skipping metric");
            return;
        }

        if (!self.initMetricSent) {
            [self.metricSender sendMetric: [UADSTsiMetric newInitTimeSuccess: self.duration
                                                                    withTags: [self getExperimentTags]]];
            self.initMetricSent = YES;
        }
    }
}

- (NSNumber *)initializationStartTimeStamp {
    return @(_startTime);
}

- (void)sdkInitializeFailed: (NSError *)error {
    @synchronized (self) {
        if (self.startTime == 0) {
            USRVLogDebug("sdkInitializeFailed called before didInitStart, skipping metric");
            return;
        }

        if (!self.initMetricSent) {
            [self.metricSender sendMetric: [UADSTsiMetric newInitTimeFailure: self.duration
                                                                    withTags: [self getExperimentTags]]];
            self.initMetricSent = YES;
        }
    }
}

- (void)sendTokenAvailabilityLatencyOnceOfType: (UADSTokenAvailabilityType)type {
    @synchronized (self) {
        if (!self.tokenMetricSent) {
            [self sendTokenAvailabilityMetricOfType: type];
            [self sendTokenResolutionRequestMetricIfNeeded];
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
    NSDictionary *tags = [self getExperimentTags];
    UADSTsiMetric *metric;

    switch (type) {
        case kUADSTokenAvailabilityTypeWeb:
            metric = [UADSTsiMetric newTokenAvailabilityLatencyWebview: duration
                                                              withTags: tags];

            break;

        case kUADSTokenAvailabilityTypeFirstToken:
            metric = [UADSTsiMetric newTokenAvailabilityLatencyConfig: duration
                                                             withTags: tags];
            break;
    }

    [self.metricSender sendMetric: metric];
}

- (void)sendTokenResolutionRequestMetricIfNeeded {
    if (self.configStartTime != 0) {
        [self.metricSender sendMetric: [UADSTsiMetric newTokenResolutionRequestLatency: self.tokenDuration
                                                                              withTags: [self getExperimentTags]]];
    }
}

- (NSNumber *)duration {
    return [self.timestampReader msDurationFrom: self.startTime];
}

- (NSNumber *)tokenDuration {
    return [self.timestampReader msDurationFrom: self.configStartTime];
}

- (NSDictionary *)getExperimentTags {
    return [self.tagsReader metricTags];
}

@end
