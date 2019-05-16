#import "USRVResolveOperation.h"

@implementation USRVResolveOperation

- (instancetype)initWithHostName:(NSString *)hostName completeBlock:(UnityServicesResolveRequestCompletion)completeBlock {
    self = [super init];
    
    if (self) {
        [self setCompleteBlock:completeBlock];
        [self setResolve:[[USRVResolve alloc] initWithHostName:hostName]];
    }
    
    return self;
}

- (void)main {
    [self startObserving];
    [self.resolve resolve];
    [self stopObserving];
    
    if (self.completeBlock && self.resolve && !self.resolve.canceled) {
        self.completeBlock(self.resolve.hostName, self.resolve.address, self.resolve.error, self.resolve.errorMessage);
    }
}

- (void)startObserving {
    @try {
        [self addObserver:self forKeyPath:@"isCancelled" options:NSKeyValueObservingOptionNew context:nil];
    }
    @catch (id exception) {
    }
}

- (void)stopObserving {
    @try {
        [self removeObserver:self forKeyPath:@"isCancelled"];
    }
    @catch (id exception) {
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"isCancelled"]) {
        if (self.resolve) {
            [self.resolve cancel];
        }
    }
}

@end
