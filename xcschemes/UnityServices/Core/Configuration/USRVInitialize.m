#import "USRVInitialize.h"
#import "USRVWebViewApp.h"
#import "USRVSdkProperties.h"
#import "USRVWebRequest.h"
#import "NSString+Hash.h"
#import "USRVWKWebViewApp.h"
#import "USRVModuleConfiguration.h"
#import "USRVWebRequestQueue.h"
#import "USRVDevice.h"
#import "USRVCacheQueue.h"

@implementation USRVInitialize

static NSOperationQueue *initializeQueue;
static USRVConfiguration *currentConfiguration;
static dispatch_once_t onceToken;

+ (void)initialize:(USRVConfiguration *)configuration {
    dispatch_once(&onceToken, ^{
        if (!initializeQueue) {
            initializeQueue = [[NSOperationQueue alloc] init];
            initializeQueue.maxConcurrentOperationCount = 1;
        }
    });

    if (initializeQueue && initializeQueue.operationCount == 0) {
        currentConfiguration = configuration;
        id state = [[USRVInitializeStateReset alloc] initWithConfiguration:currentConfiguration];
        [initializeQueue addOperation:state];
    }
}

+ (void) reset {
    if (initializeQueue) {
        id state = [[USRVInitializeStateForceReset alloc] initWithConfiguration:currentConfiguration];
        [initializeQueue addOperation:state];
    }
}

@end

/* STATE CLASSES */

// BASE STATE

@implementation USRVInitializeState

- (void)main {
    id nextState = [self execute];
    if (nextState && initializeQueue) {
        [initializeQueue addOperation:nextState];
    }
}

- (instancetype)execute {
    return NULL;
}

- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration {
    self = [super init];
    
    if (self) {
        [self setConfiguration:configuration];
    }
    
    return self;
}

@end

// RESET

@implementation USRVInitializeStateReset : USRVInitializeState

- (instancetype)execute {
    [USRVCacheQueue start];
    [USRVWebRequestQueue start];    
    USRVWebViewApp *currentWebViewApp = [USRVWebViewApp getCurrentApp];
    
    if (currentWebViewApp != NULL) {
        [currentWebViewApp setWebAppLoaded:false];
        [currentWebViewApp setWebAppInitialized:false];
        NSCondition *blockCondition = [[NSCondition alloc] init];
        [blockCondition lock];
        
        if ([currentWebViewApp webView] != NULL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([currentWebViewApp webView] && [[currentWebViewApp webView] superview]) {
                    [[currentWebViewApp webView] removeFromSuperview];
                }
                
                [currentWebViewApp setWebView:NULL];
                [blockCondition lock];
                [blockCondition signal];
                [blockCondition unlock];
            });
        }
        
        BOOL success = [blockCondition waitUntilDate:[[NSDate alloc] initWithTimeIntervalSinceNow:10]];
        [blockCondition unlock];
        
        if (!success) {
            USRVLogError(@"Unity Ads init: dispatch async did not run through while resetting SDK");
        }

        [USRVWebViewApp setCurrentApp:NULL];
    }

    for (NSString *moduleName in [self.configuration getModuleConfigurationList]) {
        USRVModuleConfiguration *moduleConfiguration = [self.configuration getModuleConfiguration:moduleName];
        if (moduleConfiguration) {
            [moduleConfiguration resetState:self.configuration];
        }
    }

    id nextState = [[USRVInitializeStateInitModules alloc] initWithConfiguration:self.configuration];
    return nextState;
}

@end

// FORCE RESET

@implementation USRVInitializeStateForceReset : USRVInitializeStateReset

- (instancetype)execute {
    [super execute];
    return nil;
}

@end

@implementation USRVInitializeStateInitModules : USRVInitializeState

- (instancetype)execute {
    for (NSString *moduleName in [self.configuration getModuleConfigurationList]) {
        USRVModuleConfiguration *moduleConfiguration = [self.configuration getModuleConfiguration:moduleName];
        if (moduleConfiguration) {
            [moduleConfiguration initModuleState:self.configuration];
        }
    }

    id nextState = [[USRVInitializeStateConfig alloc] initWithConfiguration:self.configuration retries:0 retryDelay:5];
    return nextState;
}

@end


// CONFIG

@implementation USRVInitializeStateConfig : USRVInitializeState

- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration retries:(int)retries retryDelay:(int)retryDelay {
    self = [super initWithConfiguration:configuration];
    
    if (self) {
        [self setRetries:retries];
        [self setMaxRetries:6];
        [self setRetryDelay:retryDelay];
    }
    
    return self;
}

- (instancetype)execute {
    USRVLogInfo(@"Unity Ads init: load configuration from %@", [USRVSdkProperties getConfigUrl]);

    [self.configuration setConfigUrl:[USRVSdkProperties getConfigUrl]];
    [self.configuration makeRequest];
    
    if (!self.configuration.error) {
        id nextState = [[USRVInitializeStateLoadCache alloc] initWithConfiguration:self.configuration];
        return nextState;
    }
    else if (self.configuration.error && self.retries < self.maxRetries) {
        self.retryDelay = self.retryDelay * 2;
        self.retries++;
        id retryState = [[USRVInitializeStateConfig alloc] initWithConfiguration:self.configuration retries:self.retries retryDelay:self.retryDelay];
        id nextState = [[USRVInitializeStateRetry alloc] initWithConfiguration:self.configuration retryState:retryState retryDelay:self.retryDelay];
        return nextState;
    }
    else {
        id erroredState = [[USRVInitializeStateConfig alloc] initWithConfiguration:self.configuration retries:self.retries retryDelay:self.retryDelay];
        id nextState = [[USRVInitializeStateNetworkError alloc] initWithConfiguration:self.configuration erroredState:erroredState stateName:@"network error" message:@"Network error occured init SDK initialization, waiting for connection"];
        return nextState;
    }
}

@end

// LOAD CACHE

@implementation USRVInitializeStateLoadCache : USRVInitializeState

- (instancetype)execute {
    NSString *localWebViewFile = [USRVSdkProperties getLocalWebViewFile];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:localWebViewFile]) {
        NSData *fileData = [NSData dataWithContentsOfFile:localWebViewFile options:NSDataReadingUncached error:nil];
        NSString *fileString = [[NSString alloc] initWithBytesNoCopy:(void *)[fileData bytes] length:[fileData length] encoding:NSUTF8StringEncoding freeWhenDone:NO];
        NSString *localWebViewHash = [fileString sha256];
        
        if (localWebViewHash && [localWebViewHash isEqualToString:self.configuration.webViewHash]) {
            USRVLogInfo(@"Unity Ads init: webapp loaded from local cache");
            id nextState = [[USRVInitializeStateCreate alloc] initWithConfiguration:self.configuration webViewData:fileString];
            return nextState;
        }
    }

    id nextState = [[USRVInitializeStateLoadWeb alloc] initWithConfiguration:self.configuration retries:0 retryDelay:5];
    return nextState;
}

@end

// LOAD NETWORK

@implementation USRVInitializeStateLoadWeb : USRVInitializeState

- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration retries:(int)retries retryDelay:(int)retryDelay {
    self = [super initWithConfiguration:configuration];

    if (self) {
        [self setRetries:retries];
        [self setMaxRetries:6];
        [self setRetryDelay:retryDelay];
    }

    return self;
}

- (instancetype)execute {
    NSString *urlString = [NSString stringWithFormat:@"%@", [self.configuration webViewUrl]];

    USRVLogInfo(@"Unity Ads init: loading webapp from %@", urlString);
    
    USRVWebRequest *webRequest = [[USRVWebRequest alloc] initWithUrl:urlString requestType:@"GET" headers:NULL connectTimeout:30000];
    NSData *responseData = [webRequest makeRequest];

    if (!webRequest.error) {
        [responseData writeToFile:[USRVSdkProperties getLocalWebViewFile] atomically:YES];
    }
    else if (webRequest.error && self.retries < self.maxRetries) {
        self.retryDelay = self.retryDelay * 2;
        self.retries++;
        id retryState = [[USRVInitializeStateLoadWeb alloc] initWithConfiguration:self.configuration retries:self.retries retryDelay:self.retryDelay];
        id nextState = [[USRVInitializeStateRetry alloc] initWithConfiguration:self.configuration retryState:retryState retryDelay:self.retryDelay];
        return nextState;
    }
    else if (webRequest.error) {
        id erroredState = [[USRVInitializeStateLoadWeb alloc] initWithConfiguration:self.configuration retries:self.retries retryDelay:self.retryDelay];
        id nextState = [[USRVInitializeStateNetworkError alloc] initWithConfiguration:self.configuration erroredState:erroredState stateName:@"load web" message:@"Network error while loading WebApp from internet, waiting for connection"];
        return nextState;
    }

    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    id nextState = [[USRVInitializeStateCreate alloc] initWithConfiguration:self.configuration webViewData:responseString];
    return nextState;
}

@end

// CREATE

@implementation USRVInitializeStateCreate : USRVInitializeState

- (instancetype)execute {
    USRVLogDebug(@"Unity Ads init: creating webapp");
    
    [self.configuration setWebViewData:[self webViewData]];
    
    NSString *osVersion = [USRVDevice getOsVersion];
    NSArray<NSString *> *splitString = [osVersion componentsSeparatedByString:@"."];
    NSString *osMajorVersionString = [splitString objectAtIndex:0];
    int osMajorVersion = [osMajorVersionString intValue];
    
    if (osMajorVersion > 8) {
        USRVLogDebug(@"Using WKWebView");
        [USRVWKWebViewApp create:self.configuration];
        
        if (![USRVWKWebViewApp getCurrentApp]) {
            USRVLogDebug(@"Error creating WKWebView, falling back to UIWebView");
            [USRVWebViewApp create:self.configuration];
        }
    }
    else {
        USRVLogDebug(@"Using UIWebView");
        [USRVWebViewApp create:self.configuration];
    }

    id nextState = [[USRVInitializeStateComplete alloc] initWithConfiguration:self.configuration];
    return nextState;
}

- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration webViewData:(NSString *)webViewData {
    self = [super initWithConfiguration:configuration];

    if (self) {
        [self setWebViewData:webViewData];
    }

    return self;
}

@end

// COMPLETE

@implementation USRVInitializeStateComplete : USRVInitializeState
- (instancetype)execute {
    for (NSString *moduleName in [self.configuration getModuleConfigurationList]) {
        USRVModuleConfiguration *moduleConfiguration = [self.configuration getModuleConfiguration:moduleName];
        if (moduleConfiguration) {
            [moduleConfiguration initCompleteState:self.configuration];
        }
    }

    return NULL;
}
@end

// ERROR

@implementation USRVInitializeStateError : USRVInitializeState

- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration erroredState:(id)erroredState stateName:(NSString *)stateName message:(NSString *)message {
    self = [super initWithConfiguration:configuration];
    
    if (self) {
        [self setErroredState:erroredState];
    }

    for (NSString *moduleName in [self.configuration getModuleConfigurationList]) {
        USRVModuleConfiguration *moduleConfiguration = [self.configuration getModuleConfiguration:moduleName];
        if (moduleConfiguration) {
            [moduleConfiguration initErrorState:self.configuration state:stateName message:message];
        }
    }

    return self;
}

- (instancetype)execute {
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
        [USRVConnectivityMonitor startListening:self];
    });
    
    BOOL success = [self.blockCondition waitUntilDate:[[NSDate alloc] initWithTimeIntervalSinceNow:10000 * 60]];
    
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [USRVConnectivityMonitor stopListening:self];
        });
        
        [self.blockCondition unlock];
        return self.erroredState;
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [USRVConnectivityMonitor stopListening:self];
            
        });
    }

    [self.blockCondition unlock];
    return NULL;
}

- (BOOL)shouldHandleConnectedEvent {
    long long currentTimeMs = [[NSDate date] timeIntervalSince1970] * 1000;
    if (currentTimeMs - self.lastConnectedEventTimeMs >= 10000 && self.receivedConnectedEvents < 500) {
        return true;
    }

    return false;
}

@end

// RETRY

@implementation USRVInitializeStateRetry: USRVInitializeState

- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration retryState:(id)retryState retryDelay:(int)retryDelay {
    self = [super initWithConfiguration:configuration];

    if (self) {
        [self setRetryState:retryState];
        [self setRetryDelay:retryDelay];
    }

    return self;
}

- (instancetype)execute {
    USRVLogDebug(@"Unity Ads init: retrying in %d seconds ", self.retryDelay);
    
    NSCondition *blockCondition = [[NSCondition alloc] init];
    [blockCondition lock];
    [blockCondition waitUntilDate:[[NSDate alloc] initWithTimeIntervalSinceNow:self.retryDelay]];
    [blockCondition unlock];
    
    return self.retryState;
}
@end
