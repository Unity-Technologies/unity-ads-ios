#import "UADSResolveOperation.h"

@implementation UADSResolveOperation

- (instancetype)initWithHostName:(NSString *)hostName completeBlock:(UnityAdsResolveRequestCompletion)completeBlock {
    self = [super init];
    
    if (self) {
        [self setCompleteBlock:completeBlock];
        [self setResolve:[[UADSResolve alloc] initWithHostName:hostName]];
    }
    
    return self;
}

- (void)main {
    [self.resolve resolve];
    
    if (self.completeBlock) {
        self.completeBlock(self.resolve.hostName, self.resolve.address, self.resolve.error, self.resolve.errorMessage);
    }
}

@end