#import "USRVNativeCallback.h"
#import "USRVWebViewApp.h"

@implementation USRVNativeCallback

static NSNumber *callbackCount = 0;

- (instancetype)initWithCallback:(NSString *)callback receiverClass:(id)receiverClass {
    self = [super init];
    
    if (self) {

        if (!callback || !receiverClass) {
            NSException* exception = [NSException
                                      exceptionWithName:@"NullPointerException"
                                      reason:@"Callback or receiver class NULL"
                                      userInfo:nil];
            @throw exception;
        }

        @synchronized (callbackCount) {
            callbackCount = [NSNumber numberWithLong:[callbackCount longValue] + 1];
        }
        
        [self setCallback:callback];
        [self setReceiverClass:receiverClass];
        [self setCallbackId:[NSString stringWithFormat:@"%@_%lu", callback, [callbackCount longValue]]];
    }
    
    return self;
}

- (void)invokeWithStatus:(NSString *)status params:(NSArray *)params {
    if (status && params && self.receiverClass && self.callback) {
        Class class = NSClassFromString(self.receiverClass);
        SEL selector = NSSelectorFromString(self.callback);
        NSMutableArray *combinedParams = [[NSMutableArray alloc] initWithObjects:status, nil];
        [combinedParams addObjectsFromArray:params];

        NSMethodSignature *signature = [class methodSignatureForSelector:selector];
        NSInvocation *invocation;

        if (signature) {
            invocation = [NSInvocation invocationWithMethodSignature:signature];
            invocation.selector = selector;
            invocation.target = class;
        }
        else {
            USRVLogError(@"Could not find signature for selector %@", self.callback);
            NSException* exception = [NSException
                                      exceptionWithName:@"NoSignatureException"
                                      reason:[NSString stringWithFormat:@"Could not find signature for selector: %@", self.callback]
                                      userInfo:nil];
            @throw exception;
        }

        if (invocation) {
            [invocation setArgument:&combinedParams atIndex:2];
            [invocation retainArguments];
            [invocation invoke];
        }
        else {
            USRVLogError(@"Could not create invocation for %@.%@", self.receiverClass, self.callback);
            NSException* exception = [NSException
                                      exceptionWithName:@"NoInvocationException"
                                      reason:[NSString stringWithFormat:@"Could not create invocation for: %@.%@", self.receiverClass, self.callback]
                                      userInfo:nil];
            @throw exception;
        }
    }

    [[USRVWebViewApp getCurrentApp] removeCallback:self];
}

@end
