#import "USRVWebViewCallback.h"
#import "USRVInvocation.h"

@implementation USRVWebViewCallback

- (instancetype)initWithCallbackId:(NSString *)callbackId invocationId:(int)invocationId {
    self = [super init];
    
    if (self) {
        self.callbackId = callbackId;
        self.invocationId = invocationId;
    }

    return self;
}

- (void)invokeWithStatus:(NSString *)status error:(NSString *)error params:(NSArray *)params {
    if (self.invoked || !self.callbackId || [self.callbackId length] == 0) return;
    
    [self setInvoked:true];
    
    USRVInvocation *invocation = [USRVInvocation getInvocationWithId:self.invocationId];
    
    if (invocation) {
        NSMutableArray *combinedParams = [[NSMutableArray alloc] initWithArray:params];
        [combinedParams insertObject:self.callbackId atIndex:0];
        [invocation setInvocationResponseWithStatus:status error:error params:combinedParams];
    }
    else {
        USRVLogError(@"Couldn't get invocation");
    }
}

- (void)invoke:(id)arg1, ... {
    va_list args;
    va_start(args, arg1);
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    
    __unsafe_unretained id arg = nil;
    
    if (arg1) {
        [params addObject:arg1];
        
        while ((arg = va_arg(args, id)) != nil) {
            [params addObject:arg];
        }
        
        va_end(args);
    }
    
    [self invokeWithStatus:@"OK" error:@"" params:params];
}

- (void)error:(NSString *)error arg1:(id)arg1, ... {
    va_list args;
    va_start(args, arg1);
    
    NSMutableArray *params = [[NSMutableArray alloc] init];
    
    __unsafe_unretained id arg = nil;
    
    if (arg1) {
        [params addObject:arg1];
        
        while ((arg = va_arg(args, id)) != nil) {
            [params addObject:arg];
        }
        
        va_end(args);
    }
    
    [self invokeWithStatus:@"ERROR" error:error params:params];
}

@end
