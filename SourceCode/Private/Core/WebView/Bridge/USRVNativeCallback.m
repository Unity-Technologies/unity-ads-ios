#import "USRVNativeCallback.h"
#import "USRVWebViewApp.h"

USRVNativeCallbackStatus USRVNativeCallbackStatusFromNSString(NSString *stringStatus) {
    if ([stringStatus isEqualToString: @"OK"]) {
        return USRVNativeCallbackStatusOk;
    } else {
        return USRVNativeCallbackStatusError;
    }
}

NSString * NSStringFromUSRVNativeCallbackStatus(USRVNativeCallbackStatus status) {
    switch (status) {
        case USRVNativeCallbackStatusOk:
            return @"OK";

        case USRVNativeCallbackStatusError:
            return @"ERROR";

        default:
            return @"ERROR";
    }
}

@implementation USRVNativeCallback

static long callbackCount = 0;
static NSString *lockObject = @"lock";

- (instancetype)initWithCallback: (USRVNativeCallbackBlock)callback context: (NSString *)context {
    self = [super init];

    if (self) {
        if (!callback) {
            NSException *exception = [NSException
                                      exceptionWithName: @"NullPointerException"
                                                 reason: @"Callback was NULL"
                                               userInfo: nil];
            @throw exception;
        }

        @synchronized (lockObject) {
            callbackCount = callbackCount + 1;

            [self setCallback: callback];
            [self setCallbackId: [NSString stringWithFormat: @"%@_%lu", context, callbackCount]];
        }
    }

    return self;
} /* initWithCallback */

- (instancetype)initWithMethod: (NSString *)method receiverClass: (NSString *)receiverClass {
    if (!method) {
        NSException *exception = [NSException
                                  exceptionWithName: @"NullPointerException"
                                             reason: @"method was NULL"
                                           userInfo: nil];
        @throw exception;
    }

    if (!receiverClass) {
        NSException *exception = [NSException
                                  exceptionWithName: @"NullPointerException"
                                             reason: @"receiverClass was NULL"
                                           userInfo: nil];
        @throw exception;
    }

    self = [self initWithCallback: ^(USRVNativeCallbackStatus status, NSArray *params) {
        if (params && receiverClass && method) {
            Class class = NSClassFromString(receiverClass);
            SEL selector = NSSelectorFromString(method);

            NSMethodSignature *signature = [class methodSignatureForSelector: selector];
            NSInvocation *invocation;

            if (signature) {
                invocation = [NSInvocation invocationWithMethodSignature: signature];
                invocation.selector = selector;
                invocation.target = class;
            } else {
                USRVLogError(@"Could not find signature for selector %@", method);
                NSException *exception = [NSException
                                          exceptionWithName: @"NoSignatureException"
                                                     reason: [NSString stringWithFormat: @"Could not find signature for selector: %@", method]
                                                   userInfo: nil];
                @throw exception;
            }

            if (invocation) {
                [invocation setArgument: &params
                                atIndex: 2];
                [invocation retainArguments];
                [invocation invoke];
            } else {
                USRVLogError(@"Could not create invocation for %@.%@", receiverClass, method);
                NSException *exception = [NSException
                                          exceptionWithName: @"NoInvocationException"
                                                     reason: [NSString stringWithFormat: @"Could not create invocation for: %@.%@", receiverClass, method]
                                                   userInfo: nil];
                @throw exception;
            }
        }
    }
                          context: method];
    return self;
} /* initWithMethod */

- (void)invokeWithStatus: (NSString *)status params: (NSArray *)params {
    USRVNativeCallbackStatus callbackStatus = USRVNativeCallbackStatusFromNSString(status);

    NSMutableArray *combinedParams = [[NSMutableArray alloc] initWithObjects: status, nil];

    if (params) {
        [combinedParams addObjectsFromArray: params];
    }

    self.callback(callbackStatus, combinedParams);
    // remove reference
    self.callback = nil;

    [[USRVWebViewApp getCurrentApp] removeCallback: self];
}

@end
