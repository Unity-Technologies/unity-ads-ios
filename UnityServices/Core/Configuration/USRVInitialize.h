#import "USRVConfiguration.h"
#import "USRVConnectivityMonitor.h"
#import "USRVApiSdk.h"

@interface USRVInitialize : NSObject

+ (void)initialize:(USRVConfiguration *)configuration;
+ (void)reset;
+ (USRVDownloadLatestWebViewStatus)downloadLatestWebView;

@end

/* STATE CLASSES */

// BASE STATE

@interface USRVInitializeState : NSOperation

@property (nonatomic, strong) USRVConfiguration *configuration;

- (instancetype)execute;
- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration;

@end

// LOAD CONFIG

@interface USRVInitializeStateLoadConfigFile : USRVInitializeState
@end

// RESET

@interface USRVInitializeStateReset : USRVInitializeState

@end

// INIT MODULES

@interface USRVInitializeStateInitModules : USRVInitializeState

@end

// FORCE RESET

@interface USRVInitializeStateForceReset : USRVInitializeStateReset

@end

// CONFIG

@interface USRVInitializeStateConfig : USRVInitializeState

@property (nonatomic, strong) USRVConfiguration *localConfig;
@property (nonatomic, assign) int retries;
@property (nonatomic, assign) long retryDelay;

- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration retries:(int)retries retryDelay:(long)retryDelay;

@end

// LOAD CACHE

@interface USRVInitializeStateLoadCache : USRVInitializeState

@end

// LOAD NETWORK

@interface USRVInitializeStateLoadWeb : USRVInitializeState

- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration retries:(int)retries retryDelay:(long)retryDelay;

@property (nonatomic, assign) int retries;
@property (nonatomic, assign) long retryDelay;

@end

// CREATE
#define InitializeStateCreateStateName @"create webapp"
@interface USRVInitializeStateCreate : USRVInitializeState

@property (atomic, strong) NSString *webViewData;

- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration webViewData:(NSString *)webViewData;

@end

// COMPLETE

@interface USRVInitializeStateComplete : USRVInitializeState

@end

// ERROR

@interface USRVInitializeStateError : USRVInitializeState

@property (nonatomic, strong) id erroredState;
@property (nonatomic, assign) NSString *stateName;
@property (nonatomic, assign) NSString *message;

- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration erroredState:(id)erroredState stateName:(NSString *)stateName message:(NSString *)message;

@end

// NETWORK ERROR

@interface USRVInitializeStateNetworkError : USRVInitializeStateError <USRVConnectivityDelegate>

@property (nonatomic, strong) NSCondition *blockCondition;
@property (nonatomic, assign) int receivedConnectedEvents;
@property (nonatomic, assign) long long lastConnectedEventTimeMs;

@end

// RETRY

@interface USRVInitializeStateRetry:  USRVInitializeState

@property (nonatomic, strong) id retryState;
@property (nonatomic, assign) long retryDelay;

- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration retryState:(id)retryState retryDelay:(long)retryDelay;

@end

// CLEAN CACHE
@interface USRVInitializeStateCleanCache : USRVInitializeState

- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration nextState:(USRVInitializeState*)nextState;

@property (nonatomic, strong) USRVInitializeState* nextState;

@end

// CHECK FOR UPDATED WEBVIEW
@interface USRVInitializeStateCheckForUpdatedWebView : USRVInitializeState

- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration localConfiguration:(USRVConfiguration *)localConfiguration;

@property (nonatomic, strong) USRVConfiguration* localWebViewConfiguration;
@property (nonatomic, strong) NSString* localWebViewData;

@end

// LOAD CACHE CONFIG AND WEBVIEW
@interface USRVInitializeStateLoadCacheConfigAndWebView : USRVInitializeState

- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration localConfig:(USRVConfiguration *)localConfig;

@property (nonatomic, strong) USRVConfiguration *localConfig;

@end

// DOWNLOAD LATEST WEBVIEW
@interface USRVInitializeStateDownloadLatestWebView : USRVInitializeState

@property (nonatomic, assign) int retries;
@property (nonatomic, assign) long retryDelay;

@end

// UPDATE CACHE
@interface USRVInitializeStateUpdateCache : USRVInitializeState

@property (nonatomic, strong) NSString* localWebViewData;

- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration webViewData:(NSString *)webViewData;

@end

// CHECK FOR CACHED WEBVIEW UPDATE

@interface USRVInitializeStateCheckForCachedWebViewUpdate : USRVInitializeState

@end
