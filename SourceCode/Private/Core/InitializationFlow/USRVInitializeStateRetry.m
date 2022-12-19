#import "USRVInitializeStateRetry.h"

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


- (void)startWithCompletion:(void (^)(void))completion error:(void (^)(NSError * _Nonnull))error {
    double retryDelayInSeconds = self.retryDelay / (double)1000;

    USRVLogDebug(@"Unity Ads init: retrying in %f seconds ", retryDelayInSeconds);

    NSCondition *blockCondition = [[NSCondition alloc] init];

    [blockCondition lock];
    [blockCondition waitUntilDate: [[NSDate alloc] initWithTimeIntervalSinceNow: retryDelayInSeconds]];
    [blockCondition unlock];
    
    [self.retryState startWithCompletion: completion error: error];
}

@end
