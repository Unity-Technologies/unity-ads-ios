#import "USRVConfiguration.h"
#import "USRVConnectivityMonitor.h"

@interface USRVInitialize : NSObject

+ (void)initialize:(USRVConfiguration *)configuration;
+ (void)reset;

@end

/* STATE CLASSES */

// BASE STATE

@interface USRVInitializeState : NSOperation

@property (nonatomic, assign) USRVConfiguration *configuration;

- (instancetype)execute;
- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration;

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

@property (nonatomic, assign) int retries;
@property (nonatomic, assign) int maxRetries;
@property (nonatomic, assign) int retryDelay;

- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration retries:(int)retries retryDelay:(int)retryDelay;

@end

// LOAD CACHE

@interface USRVInitializeStateLoadCache : USRVInitializeState

@end

// LOAD NETWORK

@interface USRVInitializeStateLoadWeb : USRVInitializeState

- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration retries:(int)retries retryDelay:(int)retryDelay;

@property (nonatomic, assign) int retries;
@property (nonatomic, assign) int maxRetries;
@property (nonatomic, assign) int retryDelay;

@end

// CREATE

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
@property (nonatomic, assign) int retryDelay;

- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration retryState:(id)retryState retryDelay:(int)retryDelay;

@end
