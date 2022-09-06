#import "USRVInitialize.h"
#import "USRVSdkProperties.h"
#import "USRVWebRequest.h"
#import "USRVInitializeStateLoadConfigFile.h"
#import "USRVInitializeStateForceReset.h"
#import "USRVInitializeStateCheckForCachedWebViewUpdate.h"
#import "UADSInitializeEventsMetricSender.h"
#import "UADSServiceProvider.h"
#import "USRVInitializeStateRetry.h"

@implementation USRVInitialize

static NSOperationQueue *initializeQueue;
static USRVConfiguration *currentConfiguration;
static dispatch_once_t onceToken;

+ (void)initialize: (USRVConfiguration *)configuration {
    dispatch_once(&onceToken, ^{
        if (!initializeQueue) {
            initializeQueue = [[NSOperationQueue alloc] init];
            initializeQueue.maxConcurrentOperationCount = 1;
        }
    });

    if (initializeQueue && initializeQueue.operationCount == 0) {
        currentConfiguration = configuration;
        [[UADSInitializeEventsMetricSender sharedInstance] didInitStart];
        id state = [[USRVInitializeStateLoadConfigFile alloc] initWithConfiguration: currentConfiguration];
        [initializeQueue addOperation: state];
    }
}

+ (void)reset {
    if (initializeQueue) {
        id state = [[USRVInitializeStateForceReset alloc] initWithConfiguration: currentConfiguration];
        [initializeQueue addOperation: state];
    }
}

+ (USRVDownloadLatestWebViewStatus)downloadLatestWebView {
    if (!initializeQueue) {
        return kDownloadLatestWebViewStatusInitQueueNull;
    }

    if (initializeQueue.operationCount != 0) {
        return kDownloadLatestWebViewStatusInitQueueNotEmpty;
    }

    if ([USRVSdkProperties getLatestConfiguration] == nil) {
        return kDownloadLatestWebViewStatusMissingLatestConfig;
    }

    id state = [[USRVInitializeStateCheckForCachedWebViewUpdate alloc] initWithConfiguration: [USRVSdkProperties getLatestConfiguration]];

    [initializeQueue addOperation: state];
    return kDownloadLatestWebViewStatusBackgroundDownloadStarted;
}

@end

/* STATE CLASSES */

// BASE STATE

@implementation USRVInitializeState

- (void)main {
    NSString *metricName = [self metricName];

    if (![self isRetryState]) {
        [UADSServiceProvider.sharedInstance.performanceMeasurer startMeasureForSystemIfNeeded: metricName];
    }

    id nextState = [self execute];

    if (![self isRetryState] && ![nextState isRetryState]) {
        NSNumber *duration = [UADSServiceProvider.sharedInstance.performanceMeasurer endMeasureForSystem: metricName];
        [UADSServiceProvider.sharedInstance.metricSender sendMetric: [UADSMetric newWithName: metricName
                                                                                       value: duration
                                                                                        tags: UADSInitializeEventsMetricSender.sharedInstance.retryTags]];
    }

    if (nextState && initializeQueue) {
        [initializeQueue addOperation: nextState];
    }
}

- (instancetype)execute {
    return NULL;
}

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration {
    self = [super init];

    if (self) {
        [self setConfiguration: configuration];
    }

    return self;
}

- (NSString *)metricName {
    NSString *className = NSStringFromClass(self.class);
    NSString *metricName = [[className stringByReplacingOccurrencesOfString: @"USRVInitializeState"
                                                                 withString: @""] lowercaseString];

    return [NSString stringWithFormat: @"native_%@_state", metricName];
}

- (BOOL)isRetryState {
    return [self isKindOfClass: USRVInitializeStateRetry.class];
}

@end
