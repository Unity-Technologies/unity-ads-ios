#import "UADSInitialize.h"
#import "UADSWebViewApp.h"
#import "UADSSdkProperties.h"
#import "UADSStorageManager.h"
#import "UADSWebRequest.h"
#import "UADSWebRequestQueue.h"
#import "UADSCacheQueue.h"
#import "UADSPlacement.h"
#import "UADSNotificationObserver.h"
#import "NSString+Hash.h"
#import "UADSDevice.h"
#import "UADSConnectivityUtils.h"
#import "UADSWKWebViewApp.h"
#import "UADSVolumeChange.h"

@implementation UADSInitialize

static NSOperationQueue *initializeQueue;
static UADSConfiguration *currentConfiguration;
static dispatch_once_t onceToken;

+ (void)initialize:(UADSConfiguration *)configuration {
    dispatch_once(&onceToken, ^{
        if (!initializeQueue) {
            initializeQueue = [[NSOperationQueue alloc] init];
            initializeQueue.maxConcurrentOperationCount = 1;
        }
    });

    if (initializeQueue && initializeQueue.operationCount == 0) {
        currentConfiguration = configuration;
        id state = [[UADSInitializeStateReset alloc] initWithConfiguration:currentConfiguration];
        [initializeQueue addOperation:state];
    }
}

@end

/* STATE CLASSES */

// BASE STATE

@implementation UADSInitializeState

- (void)main {
    id nextState = [self execute];
    if (nextState && initializeQueue) {
        [initializeQueue addOperation:nextState];
    }
}

- (instancetype)execute {
    return NULL;
}

- (instancetype)initWithConfiguration:(UADSConfiguration *)configuration {
    self = [super init];
    
    if (self) {
        [self setConfiguration:configuration];
    }
    
    return self;
}

@end

// RESET

@implementation UADSInitializeStateReset : UADSInitializeState

- (instancetype)execute {
    [UADSCacheQueue start];
    [UADSWebRequestQueue start];    
    UADSWebViewApp *currentWebViewApp = [UADSWebViewApp getCurrentApp];
    
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
            UADSLogError(@"Unity Ads init: dispatch async did not run through while resetting SDK");
        }

        [UADSWebViewApp setCurrentApp:NULL];
    }
    [UADSDevice initCarrierUpdates];
    [UADSConnectivityUtils initCarrierInfo];
    [UADSSdkProperties setInitialized:false];
    [UADSPlacement reset];
    [UADSCacheQueue cancelAllDownloads];
    [UADSWebRequestQueue cancelAllOperations];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UADSConnectivityMonitor stopAll];
    });
    [UADSStorageManager init];
    [UADSNotificationObserver unregisterNotificationObserver];
    [UADSVolumeChange clearAllDelegates];
    
    id nextState = [[UADSInitializeStateConfig alloc] initWithConfiguration:self.configuration retries:0 retryDelay:5];
    return nextState;
}

@end

// CONFIG

@implementation UADSInitializeStateConfig : UADSInitializeState

- (instancetype)initWithConfiguration:(UADSConfiguration *)configuration retries:(int)retries retryDelay:(int)retryDelay {
    self = [super initWithConfiguration:configuration];
    
    if (self) {
        [self setRetries:retries];
        [self setMaxRetries:6];
        [self setRetryDelay:retryDelay];
    }
    
    return self;
}

- (instancetype)execute {
    UADSLogInfo(@"Unity Ads init: load configuration from %@", [UADSSdkProperties getConfigUrl]);

    [self.configuration setConfigUrl:[UADSSdkProperties getConfigUrl]];
    [self.configuration makeRequest];
    
    if (!self.configuration.error) {
        id nextState = [[UADSInitializeStateLoadCache alloc] initWithConfiguration:self.configuration];
        return nextState;
    }
    else if (self.configuration.error && self.retries < self.maxRetries) {
        self.retryDelay = self.retryDelay * 2;
        self.retries++;
        id retryState = [[UADSInitializeStateConfig alloc] initWithConfiguration:self.configuration retries:self.retries retryDelay:self.retryDelay];
        id nextState = [[UADSInitializeStateRetry alloc] initWithConfiguration:self.configuration retryState:retryState retryDelay:self.retryDelay];
        return nextState;
    }
    else {
        id erroredState = [[UADSInitializeStateConfig alloc] initWithConfiguration:self.configuration retries:self.retries retryDelay:self.retryDelay];
        id nextState = [[UADSInitializeStateNetworkError alloc] initWithConfiguration:self.configuration erroredState:erroredState];
        return nextState;
    }
}

@end

// LOAD CACHE

@implementation UADSInitializeStateLoadCache : UADSInitializeState

- (instancetype)execute {
    NSString *localWebViewFile = [UADSSdkProperties getLocalWebViewFile];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:localWebViewFile]) {
        NSData *fileData = [NSData dataWithContentsOfFile:localWebViewFile options:NSDataReadingUncached error:nil];
        NSString *fileString = [[NSString alloc] initWithBytesNoCopy:(void *)[fileData bytes] length:[fileData length] encoding:NSUTF8StringEncoding freeWhenDone:NO];
        NSString *localWebViewHash = [fileString sha256];
        
        if (!localWebViewHash || (localWebViewHash && [localWebViewHash isEqualToString:self.configuration.webViewHash])) {
            UADSLogInfo(@"Unity Ads init: webapp loaded from local cache");
            id nextState = [[UADSInitializeStateCreate alloc] initWithConfiguration:self.configuration webViewData:fileString];
            return nextState;
        }
    }
    
    id nextState = [[UADSInitializeStateLoadWeb alloc] initWithConfiguration:self.configuration retries:0 retryDelay:5];
    return nextState;
}

@end

// LOAD NETWORK

@implementation UADSInitializeStateLoadWeb : UADSInitializeState

- (instancetype)initWithConfiguration:(UADSConfiguration *)configuration retries:(int)retries retryDelay:(int)retryDelay {
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

    UADSLogInfo(@"Unity Ads init: loading webapp from %@", urlString);
    
    UADSWebRequest *webRequest = [[UADSWebRequest alloc] initWithUrl:urlString requestType:@"GET" headers:NULL connectTimeout:30000];
    NSData *responseData = [webRequest makeRequest];

    if (!webRequest.error) {
        [responseData writeToFile:[UADSSdkProperties getLocalWebViewFile] atomically:YES];
    }
    else if (webRequest.error && self.retries < self.maxRetries) {
        self.retryDelay = self.retryDelay * 2;
        self.retries++;
        id retryState = [[UADSInitializeStateLoadWeb alloc] initWithConfiguration:self.configuration retries:self.retries retryDelay:self.retryDelay];
        id nextState = [[UADSInitializeStateRetry alloc] initWithConfiguration:self.configuration retryState:retryState retryDelay:self.retryDelay];
        return nextState;
    }
    else if (webRequest.error) {
        id erroredState = [[UADSInitializeStateLoadWeb alloc] initWithConfiguration:self.configuration retries:self.retries retryDelay:self.retryDelay];
        id nextState = [[UADSInitializeStateNetworkError alloc] initWithConfiguration:self.configuration erroredState:erroredState];
        return nextState;
    }

    NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    id nextState = [[UADSInitializeStateCreate alloc] initWithConfiguration:self.configuration webViewData:responseString];
    return nextState;
}

@end

// CREATE

@implementation UADSInitializeStateCreate : UADSInitializeState

- (instancetype)execute {
    UADSLogDebug(@"Unity Ads init: creating webapp");
    
    [self.configuration setWebViewData:[self webViewData]];
    
    NSString *osVersion = [UADSDevice getOsVersion];
    NSArray<NSString *> *splitString = [osVersion componentsSeparatedByString:@"."];
    NSString *osMajorVersionString = [splitString objectAtIndex:0];
    int osMajorVersion = [osMajorVersionString intValue];
    
    if (osMajorVersion > 8) {
        UADSLogDebug(@"Using WKWebView");
        [UADSWKWebViewApp create:self.configuration];
        
        if (![UADSWKWebViewApp getCurrentApp]) {
            UADSLogDebug(@"Error creating WKWebView, falling back to UIWebView");
            [UADSWebViewApp create:self.configuration];
        }
    }
    else {
        UADSLogDebug(@"Using UIWebView");
        [UADSWebViewApp create:self.configuration];
    }

    id nextState = [[UADSInitializeStateComplete alloc] initWithConfiguration:self.configuration];
    return nextState;
}

- (instancetype)initWithConfiguration:(UADSConfiguration *)configuration webViewData:(NSString *)webViewData {
    self = [super initWithConfiguration:configuration];

    if (self) {
        [self setWebViewData:webViewData];
    }

    return self;
}

@end

// COMPLETE

@implementation UADSInitializeStateComplete : UADSInitializeState
- (instancetype)execute {
    return NULL;
}
@end

// ERROR

@implementation UADSInitializeStateError : UADSInitializeState

- (instancetype)initWithConfiguration:(UADSConfiguration *)configuration erroredState:(id)erroredState {
    self = [super initWithConfiguration:configuration];
    
    if (self) {
        [self setErroredState:erroredState];
    }
    
    return self;
}

- (instancetype)execute {
    return NULL;
}
@end

// NETWORK ERROR

@implementation UADSInitializeStateNetworkError : UADSInitializeStateError

- (void)connected {
    UADSLogDebug(@"Unity Ads init got connected event");
    
    self.receivedConnectedEvents++;
    
    if ([self shouldHandleConnectedEvent]) {
        [self.blockCondition lock];
        [self.blockCondition signal];
        [self.blockCondition unlock];
    }
    
    self.lastConnectedEventTimeMs = [[NSDate date] timeIntervalSince1970] * 1000;
}

- (void)disconnected {
    UADSLogDebug(@"Unity Ads init got disconnected event");
}

- (instancetype)execute {
    UADSLogError(@"Unity Ads init: network error, waiting for connection events");
        
    self.blockCondition = [[NSCondition alloc] init];
    [self.blockCondition lock];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UADSConnectivityMonitor startListening:self];
    });
    
    BOOL success = [self.blockCondition waitUntilDate:[[NSDate alloc] initWithTimeIntervalSinceNow:10000 * 60]];
    
    if (success) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UADSConnectivityMonitor stopListening:self];
        });
        
        [self.blockCondition unlock];
        return self.erroredState;
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UADSConnectivityMonitor stopListening:self];
            
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

@implementation UADSInitializeStateRetry:  UADSInitializeState

- (instancetype)initWithConfiguration:(UADSConfiguration *)configuration retryState:(id)retryState retryDelay:(int)retryDelay {
    self = [super initWithConfiguration:configuration];
    
    if (self) {
        [self setRetryState:retryState];
        [self setRetryDelay:retryDelay];
    }
    
    return self;
}

- (instancetype)execute {
    UADSLogDebug(@"Unity Ads init: retrying in %d seconds ", self.retryDelay);
    
    NSCondition *blockCondition = [[NSCondition alloc] init];
    [blockCondition lock];
    [blockCondition waitUntilDate:[[NSDate alloc] initWithTimeIntervalSinceNow:self.retryDelay]];
    [blockCondition unlock];
    
    return self.retryState;
}
@end
