#import "USRVInitializeStateNetworkError.h"

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


- (void)startWithCompletion:(void (^)(void))completion error:(void (^)(NSError * _Nonnull))error {
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
        [self.erroredState startWithCompletion: completion error: error];
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

    [nextState startWithCompletion: completion error: error];
    
}

@end
