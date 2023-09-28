#import "NSInvocation+Convenience.h"
#import "NSPrimitivesBox.h"
#import "GADAdSizeStructBox.h"
#import "GADAdSizeBridge.h"
#import "UADSTools.h"

@implementation NSInvocation (Category)

+ (void)uads_invokeUsingMethod: (NSString *)methodName
                     classType: (Class)classType
                        target: (_Nullable id)target
                          args: (NSArray *)arguments {
    NSInvocation *invocation = [self uads_newUsingMethod: methodName
                                               classType: classType
                                                  target: target
                                                    args: arguments];

    [invocation invoke];
}

+ (nullable id)uads_invokeWithReturnedUsingMethod: (NSString *)methodName
                                        classType: (Class)classType
                                           target: (_Nullable id)target
                                             args: (NSArray *)arguments {
    __autoreleasing id returnedValue;
    NSInvocation *invocation = [self uads_newUsingMethod: methodName
                                               classType: classType
                                                  target: target
                                                    args: arguments];

    [invocation invoke];
    [invocation getReturnValue: &returnedValue];
    return returnedValue;
}

+ (nullable instancetype)uads_newUsingMethod: (NSString *)methodName
                                   classType: (Class)classType
                                      target: (_Nullable id)target
                                        args: (NSArray *)arguments {
    SEL selector = NSSelectorFromString(methodName);

    GUARD_OR_NIL(selector)

    __autoreleasing id targetArg;
    NSMethodSignature *signature;

    if (!target) {
        targetArg = classType;
        signature = [classType methodSignatureForSelector: selector];
    } else {
        targetArg = target;
        signature = [classType instanceMethodSignatureForSelector: selector];
    }

    GUARD_OR_NIL(signature)

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature: signature];
    [invocation setSelector: selector];
    [invocation setTarget: targetArg];

    for (int i = 0; i < [arguments count]; i++) {
        __autoreleasing id argument = arguments[i];

        NSPrimitivesBox *value = typecast(argument, [NSPrimitivesBox class]);

        if (value) {
            /** from https://developer.apple.com/documentation/foundation/nsinvocation/1437834-setargument
             * An integer specifying the index of the argument.
             * Indices 0 and 1 indicate the hidden arguments self and _cmd, respectively; you should set these values directly with the target and selector properties. Use indices 2 and greater for the arguments normally passed in a message.
             */
            [value setAsArgumentForInvocation:invocation atIndex: 2 + i];
        } else {
            [invocation setArgument: &argument
                            atIndex: 2 + i];
        }
    }

    if (!invocation.argumentsRetained) {
        [invocation retainArguments];
    }

    return invocation;
} /* uads_newUsingMethod */

@end
