#import "UADSEventHandler.h"
#import "UADSLoadMetric.h"
#import "UnityAdsLoadError.h"
#import "UnityAdsShowError.h"
#import "UADSPerformanceMeasurer.h"
#import "UADSServiceProvider.h"
#import "UADSCurrentTimestampBase.h"

NSString * uads_loadErrorToString(UnityAdsLoadError error) {
    switch (error) {
        case kUnityAdsLoadErrorInitializeFailed:
            return @"init_failed";

        case kUnityAdsLoadErrorInternal:
            return @"internal";

        case kUnityAdsLoadErrorInvalidArgument:
            return @"invalid";

        case kUnityAdsLoadErrorNoFill:
            return @"no_fill";

        case kUnityAdsLoadErrorTimeout:
            return @"timeout";
    }
}

NSString * uads_showErrorToString(UnityAdsShowError error) {
    switch (error) {
        case kUnityShowErrorNotInitialized:
            return @"init_failed";

        case kUnityShowErrorNotReady:
            return @"not_ready";

        case kUnityShowErrorVideoPlayerError:
            return @"player";

        case kUnityShowErrorInvalidArgument:
            return @"invalid";

        case kUnityShowErrorNoConnection:
            return @"no_connection";

        case kUnityShowErrorAlreadyShowing:
            return @"already_showing";

        case kUnityShowErrorInternalError:
            return @"internal";

        case kUnityShowErrorTimeout:
            return @"timeout";
    }
}

@interface UADSEventHandlerBase ()
@property (nonatomic) UADSEventHandlerType moduleType;
@property (nonatomic, strong) id<ISDKMetrics> metricSender;
@property (nonatomic, strong) UADSPerformanceMeasurer *measurer;
@property (nonatomic, strong) id<UADSInitializationStatusReader> statusReader;
@end

@implementation UADSEventHandlerBase

+ (instancetype)newDefaultWithType: (UADSEventHandlerType)type {
    return [UADSEventHandlerBase newWithType: type
                                metricSender: [UADSServiceProvider sharedInstance].metricSender
                             timestampReader: [UADSCurrentTimestampBase new]
                            initStatusReader: [UADSInitializationStatusReaderBase new]];
}

+ (instancetype)newWithType: (UADSEventHandlerType)type metricSender: (id<ISDKMetrics>)metricSender timestampReader: (id<UADSCurrentTimestamp>)timestampReader initStatusReader: (id<UADSInitializationStatusReader>)initStatusReader {
    UADSEventHandlerBase *logger = [self new];

    logger.moduleType = type;
    logger.metricSender = metricSender;
    logger.measurer = [UADSPerformanceMeasurer newWithTimestampReader: timestampReader];
    logger.statusReader = initStatusReader;
    return logger;
}

- (void)eventStarted: (NSString *)identifier {
    [self.measurer startMeasureForSystem: identifier];
    [self.metricSender sendMetric: [UADSLoadMetric newEventStarted: self.moduleType
                                                              tags: self.initializationStateTag]];
}

- (void)onSuccess: (NSString *)identifier {
    NSNumber *duration = [self.measurer endMeasureForSystem: identifier];

    [self.metricSender sendMetric: [UADSLoadMetric newEventSuccess: self.moduleType
                                                              time: duration
                                                              tags: self.initializationStateTag]];
}

- (void)catchError: (UADSInternalError *)error forId: (NSString *)identifier {
    NSNumber *duration = [self.measurer endMeasureForSystem: identifier];
    NSString *reason = nil;

    if (error.errorCode == kUADSInternalErrorWebView && error.reasonCode ==  kUADSInternalErrorWebViewInternal) {
        reason = @"callback_error";
    } else if (error.errorCode == kUADSInternalErrorWebView && error.reasonCode ==  kUADSInternalErrorWebViewTimeout) {
        reason = @"callback_timeout";
    } else if (error.errorCode == kUADSInternalErrorAbstractModule && error.reasonCode ==  kUADSInternalErrorAbstractModuleTimeout) {
        reason = @"timeout";
    } else if (error.errorCode == kUADSInternalErrorLoadModule) {
        reason = uads_loadErrorToString(error.reasonCode);
    } else if (error.errorCode == kUADSInternalErrorShowModule) {
        reason = uads_showErrorToString(error.reasonCode);
    }

    NSMutableDictionary *tags = [NSMutableDictionary dictionaryWithDictionary: error.errorInfo];

    tags[@"reason"] = reason;
    [tags addEntriesFromDictionary: self.initializationStateTag];

    [self.metricSender sendMetric: [UADSLoadMetric newEventFailed: self.moduleType
                                                             time: duration
                                                             tags: tags]];
}

- (NSDictionary *)initializationStateTag {
    return @{ @"state":  UADSStringFromInitializationState(self.statusReader.currentState) };
}

@end
