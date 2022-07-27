#import "USRVInitialize.h"
#import "USRVWebViewApp.h"
#import "USRVSdkProperties.h"
#import "USRVWebRequest.h"
#import "NSString+Hash.h"
#import "USRVWebViewApp.h"
#import "USRVModuleConfiguration.h"
#import "USRVWebRequestQueue.h"
#import "USRVDevice.h"
#import "USRVCacheQueue.h"
#import "USRVWebRequestFactory.h"
#import "USRVSDKMetrics.h"
#import "UADSConfigurationLoaderBuilder.h"
#import "UADSInitializeEventsMetricSender.h"
#import "UADSTokenStorage.h"
#import <CommonCrypto/CommonDigest.h>
#import <sys/mman.h>
#import "UADSHeaderBiddingTokenReaderBuilder.h"
#import "UADSServiceProvider.h"

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

// LOAD_LOCAL_CONFIG

@implementation USRVInitializeStateLoadConfigFile : USRVInitializeState

- (instancetype)execute {
    USRVConfiguration *localConfig;

    @try {
        if ([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalConfigFilepath]]) {
            NSData *configData = [NSData dataWithContentsOfFile: [USRVSdkProperties getLocalConfigFilepath]
                                                        options: NSDataReadingUncached
                                                          error: nil];
            localConfig = [[USRVConfiguration alloc] initWithConfigJsonData: configData];

            self.configuration = localConfig;
            USRVLogDebug(@"Unity Ads init: Using cached configuration parameters");
        }
    } @catch (NSException *exception) {
        USRVLogDebug(@"Unity Ads init: Using default configuration parameters");
    } @finally {
        id nextState = [[USRVInitializeStateReset alloc] initWithConfiguration: self.configuration];
        return nextState;
    }
} /* execute */

@end

// RESET

@implementation USRVInitializeStateReset : USRVInitializeState

- (instancetype)execute {
    [USRVCacheQueue start];
    [USRVWebRequestQueue start];
    USRVWebViewApp *currentWebViewApp = [USRVWebViewApp getCurrentApp];

    if (currentWebViewApp != NULL) {
        [currentWebViewApp resetWebViewAppInitialization];
        NSCondition *blockCondition = [[NSCondition alloc] init];
        [blockCondition lock];

        if ([currentWebViewApp webView] != NULL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([currentWebViewApp webView] && [[currentWebViewApp webView] superview]) {
                    [[currentWebViewApp webView] removeFromSuperview];
                }

                [currentWebViewApp setWebView: NULL];
                [blockCondition lock];
                [blockCondition signal];
                [blockCondition unlock];
            });
        }

        double resetWebAppTimeoutInSeconds = [self.configuration resetWebAppTimeout] / (double)1000;
        BOOL success = [blockCondition waitUntilDate: [[NSDate alloc] initWithTimeIntervalSinceNow: resetWebAppTimeoutInSeconds]];
        [blockCondition unlock];

        if (!success) {
            USRVLogError(@"Unity Ads init: dispatch async did not run through while resetting SDK");
            id nextState = [[USRVInitializeStateError alloc] initWithConfiguration: self.configuration
                                                                      erroredState: self
                                                                              code: kUADSErrorStateCreateWebview
                                                                           message: @"Failure to reset the webapp"];
            return nextState;
        }

        [USRVWebViewApp setCurrentApp: NULL];
    }

    for (NSString *moduleName in [self.configuration getModuleConfigurationList]) {
        USRVModuleConfiguration *moduleConfiguration = [self.configuration getModuleConfiguration: moduleName];

        if (moduleConfiguration) {
            [moduleConfiguration resetState: self.configuration];
        }
    }

    id nextState = [[USRVInitializeStateInitModules alloc] initWithConfiguration: self.configuration];

    return nextState;
} /* execute */

@end

// FORCE RESET

@implementation USRVInitializeStateForceReset : USRVInitializeStateReset

- (instancetype)execute {
    [USRVSdkProperties setInitializationState: NOT_INITIALIZED];
    [super execute];
    return nil;
}

@end

@implementation USRVInitializeStateInitModules : USRVInitializeState

- (instancetype)execute {
    for (NSString *moduleName in [self.configuration getModuleConfigurationList]) {
        USRVModuleConfiguration *moduleConfiguration = [self.configuration getModuleConfiguration: moduleName];

        if (moduleConfiguration) {
            [moduleConfiguration initModuleState: self.configuration];
        }
    }

    id nextState = [[USRVInitializeStateConfig alloc] initWithConfiguration: self.configuration
                                                                    retries: 0
                                                                 retryDelay: [self.configuration retryDelay]];

    return nextState;
}

@end


// CONFIG

@interface USRVInitializeStateConfig ()
@property (nonatomic, strong) id<UADSConfigurationLoader> configLoader;
@end

@implementation USRVInitializeStateConfig : USRVInitializeState

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration retries: (int)retries retryDelay: (long)retryDelay {
    self = [super initWithConfiguration: configuration];

    if (self) {
        self.localConfig = configuration;
        //read from local config
        self.configuration = [[USRVConfiguration alloc] initWithConfigUrl: [USRVSdkProperties getConfigUrl]];
        self.configLoader = [UADSServiceProvider.sharedInstance configurationLoaderUsing: configuration
                                                                         retryInfoReader: UADSInitializeEventsMetricSender.sharedInstance];

        [self setRetries: retries];
        [self setRetryDelay: retryDelay];
    }

    return self;
}

- (instancetype)execute {
    USRVLogInfo(@"\n=============== %@ ============= \n", NSStringFromClass([self class]));
    return self.localConfig.experiments.isTwoStageInitializationEnabled ? [self executeWithLoader] : [self executeLegacy];
} /* execute */

- (instancetype)executeLegacy {
    USRVLogInfo(@"\n=============== %@ LEGACY FLOW ============= \n", NSStringFromClass([self class]));
    USRVLogInfo(@"Loading Configuration %@", [USRVSdkProperties getConfigUrl]);

    [self.configuration makeRequest];

    if (!self.configuration.error) {
        if (self.configuration.headerBiddingToken) {
            USRVLogInfo(@"Found token in the response. Will Attempt to save");
            [UADSServiceProvider.sharedInstance.hbTokenReader setInitToken: self.configuration.headerBiddingToken];
        }

        USRVLogInfo(@"Saving Configuration To Disk");

        [UADSServiceProvider.sharedInstance.configurationSaver saveConfiguration: self.configuration];

        if (self.configuration.delayWebViewUpdate) {
            id nextState = [[USRVInitializeStateLoadCacheConfigAndWebView alloc] initWithConfiguration: self.configuration
                                                                                           localConfig: self.localConfig];
            return nextState;
        } else {
            id nextState = [[USRVInitializeStateLoadCache alloc] initWithConfiguration: self.configuration];
            return nextState;
        }
    } else if (self.configuration.error && self.retries < [self.configuration maxRetries]) {
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

@end

// LOAD CACHE

@implementation USRVInitializeStateLoadCache : USRVInitializeState

- (instancetype)execute {
    NSString *localWebViewFile = [USRVSdkProperties getLocalWebViewFile];

    if ([[NSFileManager defaultManager] fileExistsAtPath: localWebViewFile]) {
        NSData *fileData = [NSData dataWithContentsOfFile: localWebViewFile
                                                  options: NSDataReadingUncached
                                                    error: nil];
        NSString *fileString = [[NSString alloc] initWithBytesNoCopy: (void *)[fileData bytes]
                                                              length: [fileData length]
                                                            encoding: NSUTF8StringEncoding
                                                        freeWhenDone: NO];
        NSString *localWebViewHash = [fileString uads_sha256];

        if (localWebViewHash && [localWebViewHash isEqualToString: self.configuration.webViewHash]) {
            USRVLogInfo(@"Unity Ads init: webapp loaded from local cache");
            id nextState = [[USRVInitializeStateCreate alloc] initWithConfiguration: self.configuration
                                                                        webViewData: fileString];
            return nextState;
        }
    }

    id nextState = [[USRVInitializeStateLoadWeb alloc] initWithConfiguration: self.configuration
                                                                     retries: 0
                                                                  retryDelay: [self.configuration retryDelay]];

    return nextState;
} /* execute */

@end

// LOAD NETWORK

@implementation USRVInitializeStateLoadWeb : USRVInitializeState

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration retries: (int)retries retryDelay: (long)retryDelay {
    self = [super initWithConfiguration: configuration];

    if (self) {
        [self setRetries: retries];
        [self setRetryDelay: retryDelay];
    }

    return self;
}

- (instancetype)execute {
    NSString *urlString = [NSString stringWithFormat: @"%@", [self.configuration webViewUrl]];

    USRVLogInfo(@"Unity Ads init: loading webapp from %@", urlString);

    NSURL *candidateURL = [NSURL URLWithString: urlString];
    bool validUrl = (candidateURL && candidateURL.scheme && candidateURL.host);

    if (!validUrl) {
        id nextState = [[USRVInitializeStateError alloc] initWithConfiguration: self.configuration
                                                                  erroredState: self
                                                                          code: kUADSErrorStateMalformedWebviewRequest
                                                                       message: @"Malformed URL when attempting to obtain the webview html"];
        return nextState;
    }

    id<USRVWebRequest> webRequest = [USRVWebRequestFactory create: urlString
                                                      requestType: @"GET"
                                                          headers: NULL
                                                   connectTimeout: 30000];
    NSData *responseData = [webRequest makeRequest];

    if (!webRequest.error) {
        [responseData writeToFile: [USRVSdkProperties getLocalWebViewFile]
                       atomically: YES];
    } else if (webRequest.error && self.retries < [self.configuration maxRetries]) {
        self.retryDelay = self.retryDelay * [self.configuration retryScalingFactor];
        self.retries++;
        [[UADSInitializeEventsMetricSender sharedInstance] didRetryWebview];
        id retryState = [[USRVInitializeStateLoadWeb alloc] initWithConfiguration: self.configuration
                                                                          retries: self.retries
                                                                       retryDelay: self.retryDelay];
        id nextState = [[USRVInitializeStateRetry alloc] initWithConfiguration: self.configuration
                                                                    retryState: retryState
                                                                    retryDelay: self.retryDelay];
        return nextState;
    } else if (webRequest.error) {
        id erroredState = [[USRVInitializeStateLoadWeb alloc] initWithConfiguration: self.configuration
                                                                            retries: self.retries
                                                                         retryDelay: self.retryDelay];
        id nextState = [[USRVInitializeStateNetworkError alloc] initWithConfiguration: self.configuration
                                                                         erroredState: erroredState
                                                                                 code: kUADSErrorStateNetworkWebviewRequest
                                                                              message: @"Network error while loading WebApp from internet, waiting for connection"];
        return nextState;
    }

    NSString *responseString = [[NSString alloc] initWithData: responseData
                                                     encoding: NSUTF8StringEncoding];
    NSString *webViewHash = [self.configuration webViewHash];

    if (webViewHash != nil && ![[responseString uads_sha256] isEqualToString: webViewHash]) {
        id nextState = [[USRVInitializeStateError alloc] initWithConfiguration: self.configuration
                                                                  erroredState: self
                                                                          code: kUADSErrorStateInvalidHash
                                                                       message: @"Webview hash did not match returned hash in configuration"];
        return nextState;
    }

    id nextState = [[USRVInitializeStateCreate alloc] initWithConfiguration: self.configuration
                                                                webViewData: responseString];

    return nextState;
} /* execute */

@end

// CREATE

@implementation USRVInitializeStateCreate : USRVInitializeState
- (instancetype)execute {
    USRVLogDebug(@"Unity Ads init: creating webapp");

    [self.configuration setWebViewData: [self webViewData]];
    NSNumber *errorState = [USRVWebViewApp create: self.configuration
                                             view: nil];

    if (!errorState) {
        id nextState = [[USRVInitializeStateComplete alloc] initWithConfiguration: self.configuration];
        return nextState;
    } else {
        id erroredState = [[USRVInitializeStateCreate alloc] init];
        NSString *errorMessage = @"Unity Ads WebApp creation failed";

        if ([[USRVWebViewApp getCurrentApp] getWebAppFailureMessage] != nil) {
            errorMessage = [[USRVWebViewApp getCurrentApp] getWebAppFailureMessage];
        }

        id nextState = [[USRVInitializeStateError alloc] initWithConfiguration: self.configuration
                                                                  erroredState: erroredState
                                                                          code: [errorState intValue]
                                                                       message: errorMessage];
        return nextState;
    }
} /* execute */

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration webViewData: (NSString *)webViewData {
    self = [super initWithConfiguration: configuration];

    if (self) {
        [self setWebViewData: webViewData];
    }

    return self;
}

@end

// COMPLETE

@implementation USRVInitializeStateComplete : USRVInitializeState
- (instancetype)execute {
    for (NSString *moduleName in [self.configuration getModuleConfigurationList]) {
        USRVModuleConfiguration *moduleConfiguration = [self.configuration getModuleConfiguration: moduleName];

        if (moduleConfiguration) {
            [moduleConfiguration initCompleteState: self.configuration];
        }
    }

    return NULL;
}

@end

// ERROR

@implementation USRVInitializeStateError : USRVInitializeState

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration erroredState: (id)erroredState code: (UADSErrorState)stateCode message: (NSString *)message {
    self = [super initWithConfiguration: configuration];

    if (self) {
        [self setErroredState: erroredState];
        [self setStateCode: stateCode];
        [self setMessage: message];
    }

    return self;
}

- (instancetype)execute {
    for (NSString *moduleName in [self.configuration getModuleConfigurationList]) {
        USRVModuleConfiguration *moduleConfiguration = [self.configuration getModuleConfiguration: moduleName];

        if (moduleConfiguration) {
            [moduleConfiguration initErrorState: self.configuration
                                           code: self.stateCode
                                        message: self.message];
        }
    }

    return NULL;
}

@end

// NETWORK ERROR

@implementation USRVInitializeStateNetworkError : USRVInitializeStateError

- (void)connected {
    USRVLogDebug(@"Unity Ads init got connected event");

    self.receivedConnectedEvents++;

    if ([self shouldHandleConnectedEvent]) {
        [self.blockCondition lock];
        [self.blockCondition signal];
        [self.blockCondition unlock];
    }

    self.lastConnectedEventTimeMs = [[NSDate date] timeIntervalSince1970] * 1000;
}

- (void)disconnected {
    USRVLogDebug(@"Unity Ads init got disconnected event");
}

- (instancetype)execute {
    USRVLogError(@"Unity Ads init: network error, waiting for connection events");

    self.blockCondition = [[NSCondition alloc] init];
    [self.blockCondition lock];

    dispatch_async(dispatch_get_main_queue(), ^{
        [USRVConnectivityMonitor startListening: self];
    });

    double networkErrorTimeoutInSeconds = [self.configuration networkErrorTimeout] / (double)1000;
    BOOL success = [self.blockCondition waitUntilDate: [[NSDate alloc] initWithTimeIntervalSinceNow: networkErrorTimeoutInSeconds]];

    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [USRVConnectivityMonitor stopListening: self];
        });

        [self.blockCondition unlock];
        return self.erroredState;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [USRVConnectivityMonitor stopListening: self];
        });
    }

    [self.blockCondition unlock];
    id nextState = [[USRVInitializeStateError alloc] initWithConfiguration: self.configuration
                                                              erroredState: self.erroredState
                                                                      code: self.stateCode
                                                                   message: self.message];

    return nextState;
} /* execute */

- (BOOL)shouldHandleConnectedEvent {
    long long currentTimeMs = [[NSDate date] timeIntervalSince1970] * 1000;

    if (currentTimeMs - self.lastConnectedEventTimeMs >= [self.configuration connectedEventThresholdInMs] && self.receivedConnectedEvents < [self.configuration maximumConnectedEvents]) {
        return true;
    }

    return false;
}

@end

// RETRY

@implementation USRVInitializeStateRetry : USRVInitializeState

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration retryState: (id)retryState retryDelay: (long)retryDelay {
    self = [super initWithConfiguration: configuration];

    if (self) {
        [self setRetryState: retryState];
        [self setRetryDelay: retryDelay];
    }

    return self;
}

- (instancetype)execute {
    double retryDelayInSeconds = self.retryDelay / (double)1000;

    USRVLogDebug(@"Unity Ads init: retrying in %f seconds ", retryDelayInSeconds);

    NSCondition *blockCondition = [[NSCondition alloc] init];

    [blockCondition lock];
    [blockCondition waitUntilDate: [[NSDate alloc] initWithTimeIntervalSinceNow: retryDelayInSeconds]];
    [blockCondition unlock];

    return self.retryState;
}

@end

// CLEAN CACHE

@implementation USRVInitializeStateCleanCache : USRVInitializeState

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration nextState: (USRVInitializeState *)nextState {
    self = [super initWithConfiguration: configuration];

    if (self) {
        [self setNextState: nextState];
    }

    return self;
}

- (instancetype)execute {
    NSString *localConfigFilepath = [USRVSdkProperties getLocalConfigFilepath];
    NSString *localWebViewFilepath = [USRVSdkProperties getLocalWebViewFile];
    NSError *error = nil;

    if ([[NSFileManager defaultManager] fileExistsAtPath: localConfigFilepath]) {
        [[NSFileManager defaultManager] removeItemAtPath: localConfigFilepath
                                                   error: &error];

        if (error != nil) {
            USRVLogError(@"Unity Ads init: failed to delete file from cache: %@", localConfigFilepath)
            error = nil;
        }
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath: localWebViewFilepath]) {
        [[NSFileManager defaultManager] removeItemAtPath: localWebViewFilepath
                                                   error: &error];

        if (error != nil) {
            USRVLogError(@"Unity Ads init: failed to delete file from cache: %@", localWebViewFilepath)
        }
    }

    return _nextState;
} /* execute */

@end

// CHECK FOR UPDATED WEBVIEW

@implementation USRVInitializeStateCheckForUpdatedWebView : USRVInitializeState

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration localConfiguration: (USRVConfiguration *)localConfiguration {
    self = [super initWithConfiguration: configuration];

    if (self) {
        [self setLocalWebViewConfiguration: localConfiguration];
    }

    return self;
}

- (instancetype)execute {
    NSString *localWebViewHash = [self getHashFromFile: [USRVSdkProperties getLocalWebViewFile]];

    if (![localWebViewHash isEqualToString: self.configuration.webViewHash]) {
        [USRVSdkProperties setLatestConfiguration: self.configuration];
    }

    // Prepare to load the WebView from cache.  We will first see if there is cached config to use to load with our cached webViewData
    // If there is no cached config, or its invalid, we will next attempt to use the downloaded config to load with the cached webViewData
    // If both of those options fail, we will attempt to clean whatever garbage is in the cache and load from web.
    if (localWebViewHash != nil && ![localWebViewHash isEqualToString: @""]) {
        if (_localWebViewConfiguration != NULL && [localWebViewHash isEqualToString: _localWebViewConfiguration.webViewHash] && [[USRVSdkProperties getVersionName] isEqualToString: _localWebViewConfiguration.sdkVersion]) {
            id nextState = [[USRVInitializeStateCreate alloc] initWithConfiguration: _localWebViewConfiguration
                                                                        webViewData: @""];
            return nextState;
        } else if (self.configuration != NULL && [localWebViewHash isEqualToString: self.configuration.webViewHash]) {
            id nextState = [[USRVInitializeStateCreate alloc] initWithConfiguration: self.configuration
                                                                        webViewData: @""];
            return nextState;
        }
    }

    id nextState = [[USRVInitializeStateLoadWeb alloc] initWithConfiguration: self.configuration
                                                                     retries: 0
                                                                  retryDelay: [self.configuration retryDelay]];

    return nextState;
} /* execute */

- (NSString *)getHashFromFile: (NSString *)filepath {
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath: filepath
                                                                                    error: nil] fileSize];
    int fd = open([filepath UTF8String], O_RDONLY);

    if (fd == -1) {
        USRVLogWarning(@"Unity Ads init: unable to hash cached WebView data: Bad File Descriptor.  Initialization will continue");
        return @"";
    }

    char *buffer = mmap((caddr_t)0, fileSize, PROT_READ, MAP_SHARED, fd, 0);

    if (buffer == MAP_FAILED) {
        USRVLogWarning(@"Unity Ads init: unable to hash cached WebView data: Failed to allocate buffer.  Initialization will continue");
        close(fd);
        return @"";
    }

    unsigned char result[CC_SHA256_DIGEST_LENGTH];

    CC_SHA256(buffer, (CC_LONG)fileSize, result);
    munmap(buffer, fileSize);
    close(fd);

    NSMutableString *ret = [NSMutableString stringWithCapacity: CC_SHA256_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [ret appendFormat: @"%02x", result[i]];
    }

    NSString *localWebViewHash = ret;

    return localWebViewHash;
} /* getHashFromFile */

@end

// LOAD CACHE CONFIG AND WEBVIEW

@implementation USRVInitializeStateLoadCacheConfigAndWebView : USRVInitializeState

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration localConfig: (USRVConfiguration *)localConfig {
    self = [super initWithConfiguration: configuration];

    if (self) {
        [self setLocalConfig: localConfig];
    }

    return self;
}

- (instancetype)execute {
    @try {
        if ([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalWebViewFile]]) {
            id nextState = [[USRVInitializeStateCheckForUpdatedWebView alloc] initWithConfiguration: self.configuration
                                                                                 localConfiguration: _localConfig];
            return nextState;
        }
    } @catch (NSException *exception) {
        // If we are unable to load cached webview data, then bail out, clean up whatever is in the cache, and load from the web
    }

    id loadWebState = [[USRVInitializeStateLoadWeb alloc] initWithConfiguration: self.configuration
                                                                        retries: 0
                                                                     retryDelay: [self.configuration retryDelay]];
    id nextState = [[USRVInitializeStateCleanCache alloc] initWithConfiguration: self.configuration
                                                                      nextState: loadWebState];

    return nextState;
}

@end

// DOWNLOAD LATEST WEBVIEW

@implementation USRVInitializeStateDownloadLatestWebView : USRVInitializeState

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration retries: (int)retries retryDelay: (long)retryDelay {
    self = [super initWithConfiguration: configuration];

    if (self) {
        [self setRetries: retries];
        [self setRetryDelay: retryDelay];
    }

    return self;
}

- (instancetype)execute {
    NSString *urlString = [NSString stringWithFormat: @"%@", [self.configuration webViewUrl]];

    USRVLogInfo(@"Unity Ads init: loading webapp from %@", urlString);

    NSURL *candidateURL = [NSURL URLWithString: urlString];
    bool validUrl = (candidateURL && candidateURL.scheme && candidateURL.host);

    if (!validUrl) {
        return NULL;
    }

    id<USRVWebRequest> webRequest = [USRVWebRequestFactory create: urlString
                                                      requestType: @"GET"
                                                          headers: NULL
                                                   connectTimeout: 30000];
    NSData *responseData = [webRequest makeRequest];

    if (!webRequest.error) {
        [responseData writeToFile: [USRVSdkProperties getLocalWebViewFile]
                       atomically: YES];
    } else if (webRequest.error && self.retries < [self.configuration maxRetries]) {
        self.retryDelay = self.retryDelay * [self.configuration retryScalingFactor];
        self.retries++;
        id retryState = [[USRVInitializeStateDownloadLatestWebView alloc] initWithConfiguration: self.configuration
                                                                                        retries: self.retries
                                                                                     retryDelay: self.retryDelay];
        id nextState = [[USRVInitializeStateRetry alloc] initWithConfiguration: self.configuration
                                                                    retryState: retryState
                                                                    retryDelay: self.retryDelay];
        return nextState;
    } else if (webRequest.error) {
        return NULL;
    }

    NSString *responseString = [[NSString alloc] initWithData: responseData
                                                     encoding: NSUTF8StringEncoding];

    NSString *webViewHash = [self.configuration webViewHash];

    if (webViewHash != nil && ![[responseString uads_sha256] isEqualToString: webViewHash]) {
        return NULL;
    }

    id nextState = [[USRVInitializeStateUpdateCache alloc] initWithConfiguration: self.configuration
                                                                     webViewData: responseString];

    return nextState;
} /* execute */

@end

// UPDATE CACHE

@implementation USRVInitializeStateUpdateCache : USRVInitializeState

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration webViewData: (NSString *)localWebViewData {
    self = [super initWithConfiguration: configuration];

    if (self) {
        [self setLocalWebViewData: localWebViewData];
    }

    return self;
}

- (instancetype)execute {
    if (_localWebViewData != nil && ![_localWebViewData isEqualToString: @""]) {
        [_localWebViewData writeToFile: [USRVSdkProperties getLocalWebViewFile]
                            atomically: YES];
    }

    if (self.configuration != nil) {
        [[self.configuration toJson] writeToFile: [USRVSdkProperties getLocalConfigFilepath]
                                      atomically: YES];
    }

    return NULL;
}

@end

// CHECK FOR CACHED WEBVIEW UPDATE

@implementation USRVInitializeStateCheckForCachedWebViewUpdate : USRVInitializeState

- (instancetype)execute {
    // check to see if we have data in webview
    NSData *fileData = [NSData dataWithContentsOfFile: [USRVSdkProperties getLocalWebViewFile]
                                              options: NSDataReadingUncached
                                                error: nil];
    NSString *fileString = [[NSString alloc] initWithBytesNoCopy: (void *)[fileData bytes]
                                                          length: [fileData length]
                                                        encoding: NSUTF8StringEncoding
                                                    freeWhenDone: NO];
    NSString *localWebViewHash = [fileString uads_sha256];

    if ([localWebViewHash isEqualToString: self.configuration.webViewHash]) {
        id nextState = [[USRVInitializeStateUpdateCache alloc] initWithConfiguration: self.configuration];
        return nextState;
    } else {
        id nextState = [[USRVInitializeStateDownloadLatestWebView alloc] initWithConfiguration: self.configuration];
        return nextState;
    }
}

@end
