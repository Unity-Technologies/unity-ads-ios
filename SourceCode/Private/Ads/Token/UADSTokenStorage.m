#import "UADSTokenStorage.h"
#import "UADSTokenStorageEventHandler.h"
#import "UADSInitializeEventsMetricSender.h"

@interface UADSTokenStorage ()

@property id<UADSTokenStorageEventProtocol> eventHandler;
@property NSMutableArray *queue;
@property int accessCounter;
@property (nonatomic) BOOL peekMode;
@property dispatch_queue_t dispatchQueue;
@property (nonatomic, copy) NSString *firstToken;
@property NSObject *lockObject;

@end

@implementation UADSTokenStorage

+ (instancetype)sharedInstance {
    static UADSTokenStorage *sharedTokenStorage = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedTokenStorage = [[UADSTokenStorage alloc] initWithEventHandler: [UADSTokenStorageEventHandler new]];
    });
    return sharedTokenStorage;
}

- (instancetype)initWithEventHandler: (id<UADSTokenStorageEventProtocol>)eventHandler {
    self = [super init];

    if (self) {
        self.eventHandler = eventHandler;
        _peekMode = NO;
        _lockObject = [NSObject new];
    }

    return self;
}

- (void)createTokens: (NSArray<NSString *> *)tokens {
    @synchronized (_lockObject) {
        self.accessCounter = 0;
        self.queue = [[NSMutableArray alloc] initWithCapacity: tokens.count];
        [self.queue addObjectsFromArray: tokens];
        [self sendWebViewTokenAvailabilityMetricsIfRequired];
    }
}

- (void)appendTokens: (NSArray<NSString *> *)tokens {
    @synchronized (_lockObject) {
        if (self.queue == nil) {
            self.accessCounter = 0;
            self.queue = [[NSMutableArray alloc] initWithCapacity: tokens.count];
            [self sendWebViewTokenAvailabilityMetricsIfRequired];
        }

        [self.queue addObjectsFromArray: tokens];
    }
}

- (void)setPeekMode: (BOOL)mode {
    @synchronized (_lockObject) {
        _peekMode = mode;
    }
}

- (NSString *)getToken {
    @synchronized (_lockObject) {
        if (self.queue == nil) {
            return self.firstToken;
        }

        if (self.queue.count == 0) {
            [self.eventHandler sendQueueEmpty];
            return self.firstToken;
        }

        [self.eventHandler sendTokenAccessIndex: [NSNumber numberWithInt: self.accessCounter++]];

        NSString *nextToken = self.queue[0];

        if (!self.peekMode) {
            [self.queue removeObjectAtIndex: 0];
        }

        return nextToken;
    }
} /* getToken */

- (void)deleteTokens {
    @synchronized (_lockObject) {
        self.queue = nil;
        self.accessCounter = 0;
    }
}

- (void)setInitToken: (NSString *)token {
    @synchronized (_lockObject) {
        self.firstToken = token;
    }
    [self sendFirstInitTokenAvailabilityMetricsIfRequired];
}

- (void)sendFirstInitTokenAvailabilityMetricsIfRequired {
    if (_firstToken) {
        [self.metricsSender sendTokenAvailabilityLatencyOnceOfType: kUADSTokenAvailabilityTypeFirstToken];
    }
}

- (void)sendWebViewTokenAvailabilityMetricsIfRequired {
    if (_queue.count > 0) {
        [self.metricsSender sendTokenAvailabilityLatencyOnceOfType: kUADSTokenAvailabilityTypeWeb];
    }
}

- (UADSInitializeEventsMetricSender *)metricsSender {
    return UADSInitializeEventsMetricSender.sharedInstance;
}

@end
