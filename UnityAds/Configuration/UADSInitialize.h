#import "UADSConfiguration.h"
#import "UADSConnectivityMonitor.h"

@interface UADSInitialize : NSObject

+ (void)initialize:(UADSConfiguration *)configuration;

@end

/* STATE CLASSES */

// BASE STATE

@interface UADSInitializeState : NSOperation

@property (nonatomic, assign) UADSConfiguration *configuration;

- (instancetype)execute;
- (instancetype)initWithConfiguration:(UADSConfiguration *)configuration;

@end

// RESET

@interface UADSInitializeStateReset : UADSInitializeState

@end

// CONFIG

@interface UADSInitializeStateConfig : UADSInitializeState

@property (nonatomic, assign) int retries;
@property (nonatomic, assign) int maxRetries;
@property (nonatomic, assign) int retryDelay;

- (instancetype)initWithConfiguration:(UADSConfiguration *)configuration retries:(int)retries retryDelay:(int)retryDelay;

@end

// LOAD CACHE

@interface UADSInitializeStateLoadCache : UADSInitializeState

@end

// LOAD NETWORK

@interface UADSInitializeStateLoadWeb : UADSInitializeState

- (instancetype)initWithConfiguration:(UADSConfiguration *)configuration retries:(int)retries retryDelay:(int)retryDelay;

@property (nonatomic, assign) int retries;
@property (nonatomic, assign) int maxRetries;
@property (nonatomic, assign) int retryDelay;

@end

// CREATE

@interface UADSInitializeStateCreate : UADSInitializeState

@property (atomic, strong) NSString *webViewData;

- (instancetype)initWithConfiguration:(UADSConfiguration *)configuration webViewData:(NSString *)webViewData;

@end

// COMPLETE

@interface UADSInitializeStateComplete : UADSInitializeState

@end

// ERROR

@interface UADSInitializeStateError : UADSInitializeState

@property (nonatomic, strong) id erroredState;

- (instancetype)initWithConfiguration:(UADSConfiguration *)configuration erroredState:(id)erroredState;

@end

// NETWORK ERROR

@interface UADSInitializeStateNetworkError : UADSInitializeStateError <UADSConnectivityDelegate>

@property (nonatomic, strong) NSCondition *blockCondition;
@property (nonatomic, assign) int receivedConnectedEvents;
@property (nonatomic, assign) long long lastConnectedEventTimeMs;

@end

// RETRY

@interface UADSInitializeStateRetry:  UADSInitializeState

@property (nonatomic, strong) id retryState;
@property (nonatomic, assign) int retryDelay;

- (instancetype)initWithConfiguration:(UADSConfiguration *)configuration retryState:(id)retryState retryDelay:(int)retryDelay;

@end
