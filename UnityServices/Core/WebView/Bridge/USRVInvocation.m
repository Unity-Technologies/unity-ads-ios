#import "USRVInvocation.h"
#import "USRVWebViewBridge.h"
#import "USRVApiSdk.h"
#import "USRVWebViewApp.h"
#import <objc/runtime.h>

@implementation USRVInvocation

static NSNumber *idCount = 0;
static NSMutableDictionary *invocationSets;
static NSMutableDictionary<NSString*, NSMutableDictionary<NSString*, NSMutableDictionary<NSNumber*, NSArray*>*>*> *selectorTable;
static NSMutableDictionary<NSString*, Class> *classTable;

+ (void)setClassTable:(NSArray<NSString*> *)allowedClasses {
    if (!selectorTable) {
        selectorTable = [[NSMutableDictionary alloc] init];
    }
    if (!classTable) {
        classTable = [[NSMutableDictionary alloc] init];
    }

    for (NSString *allowedClass in allowedClasses) {
        Class class = NSClassFromString(allowedClass);
        u_int count;
        Method* methods = class_copyMethodList(object_getClass(class), &count);

        if (class) {
            [classTable setObject:class forKey:allowedClass];
            for (int i = 0; i < count; i++) {
                SEL selector = method_getName(methods[i]);
                const char* mName = sel_getName(selector);
                NSString *currentSelectorName = [NSString stringWithCString:mName encoding:NSUTF8StringEncoding];
                NSArray *selectorNameComponents = [currentSelectorName componentsSeparatedByString:@":"];
                currentSelectorName = [selectorNameComponents objectAtIndex:0];

                if (selector && [currentSelectorName rangeOfString:@"WebViewExposed_"].location == 0) {
                    NSMethodSignature *signature = [class methodSignatureForSelector:selector];
                    if (signature) {
                        long numArgs = [signature numberOfArguments] - 2;

                        if (![selectorTable objectForKey:allowedClass]) {
                            [selectorTable setObject:[[NSMutableDictionary alloc] init] forKey:allowedClass];
                        }

                        if (![[selectorTable objectForKey:allowedClass] objectForKey:currentSelectorName]) {
                            [[selectorTable objectForKey:allowedClass] setObject:[[NSMutableDictionary alloc] init] forKey:currentSelectorName];
                        }

                        NSMutableDictionary<NSNumber*, NSArray*> *currentSelectorVersions = [[selectorTable objectForKey:allowedClass] objectForKey:currentSelectorName];
                        NSArray *selectorEntries = @[[NSValue valueWithPointer:selector], signature];
                        [currentSelectorVersions setObject:selectorEntries forKey:[NSNumber numberWithLong:numArgs]];
                        [[selectorTable objectForKey:allowedClass] setObject:currentSelectorVersions forKey:currentSelectorName];
                    }
                }
            }
        }
        
        free(methods);
    }
}

- (instancetype)init {
    self = [super init];
    
    if (self) {
        @synchronized (idCount) {
            idCount = [NSNumber numberWithInt:[idCount intValue] + 1];
            [self setInvocationId:[idCount intValue]];
        }
        
        if (!invocationSets) {
            invocationSets = [[NSMutableDictionary alloc] init];
        }
        
        [invocationSets setObject:self forKey:[NSNumber numberWithInt:[self invocationId]]];
    }
    
    return self;
}

- (void)addInvocation:(NSString *)className methodName:(NSString *)methodName parameters:(NSArray *)parameters callback:(USRVWebViewCallback *)callback {

    if (!self.invocations) {
        self.invocations = [[NSMutableArray alloc] init];
    }

    NSString *exceptionReason = NULL;

    Class class = [classTable objectForKey:className];
    if (class && [selectorTable objectForKey:className]) {
        NSMutableDictionary *allowedSelectors = [selectorTable objectForKey:className];
        NSMutableDictionary *selectorVersions = [allowedSelectors objectForKey:[NSString stringWithFormat:@"WebViewExposed_%@", methodName]];
        NSNumber *numberOrArgs = [NSNumber numberWithLong:[parameters count] + 1];
        NSArray *selectorEntries = [selectorVersions objectForKey:numberOrArgs];
        SEL selector = [[selectorEntries objectAtIndex:0] pointerValue];
        NSMethodSignature *signature = [selectorEntries objectAtIndex:1];

        if (signature && selector) {
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            invocation.selector = selector;
            invocation.target = class;

            for (int idx = 0; idx < [parameters count]; idx++) {
                id argument = [parameters objectAtIndex:idx];
                if (argument) {
                    [invocation setArgument:&argument atIndex:2 + idx];
                }
                else {
                    exceptionReason = [NSString stringWithFormat:@"Argument at index: %i is NULL", idx];
                    NSException* exception = [NSException
                                              exceptionWithName:@"InvalidInvocationException"
                                              reason:exceptionReason
                                              userInfo:nil];
                    @throw exception;
                    return;
                }
            }

            [invocation setArgument:&callback atIndex:2 + [parameters count]];
            if (![invocation argumentsRetained]) {
                [invocation retainArguments];
            }

            [self.invocations addObject:invocation];
        }
        else {
            exceptionReason = @"Could not find signature or selector";

            if (!signature) {
                exceptionReason = @"Could not find signature for the selector";
            }
            else if (!selector) {
                exceptionReason = @"Could not get selector for the invocation";
            }
        }
    }
    else {
        exceptionReason = @"Uknown error";

        if (!class) {
            exceptionReason = [NSString stringWithFormat:@"Could not fetch class from allowed classes cache %@", className];
        }
        else if (![selectorTable objectForKey:className]) {
            exceptionReason = [NSString stringWithFormat:@"No entry for class in allowed selector table"];
        }
    }

    if (exceptionReason) {
        NSException* exception = [NSException
                                  exceptionWithName:@"InvalidInvocationException"
                                  reason:exceptionReason
                                  userInfo:nil];
        @throw exception;
    }
}

- (BOOL)nextInvocation {
    if (self.invocations && [self.invocations count] > 0) {
        NSInvocation *invocation = [self.invocations objectAtIndex:0];
        [USRVWebViewBridge handleInvocation:invocation];
        [self.invocations removeObjectAtIndex:0];
        
        return true;
    }

    return false;
}

- (void)setInvocationResponseWithStatus:(NSString *)status error:(NSString *)error params:(NSArray *)params {
    if (!self.responses) {
        self.responses = [[NSMutableArray alloc] init];
    }

    if (!error) {
        error = @"";
    }

    NSArray *response = @[status, error, params];
    [self.responses addObject:response];
}

- (void)sendInvocationCallback {
    [invocationSets removeObjectForKey:[NSNumber numberWithInt:self.invocationId]];
    [[USRVWebViewApp getCurrentApp] invokeCallback:self];
}

+ (USRVInvocation *)getInvocationWithId:(int)invocationId {
    return [invocationSets objectForKey:[NSNumber numberWithInt:invocationId]];
}

@end
