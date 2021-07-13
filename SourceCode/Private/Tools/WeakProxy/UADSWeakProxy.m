//
//  UADSWeakProxy.m
//  UnityAds
//
//  Created by Alex Crowe on 2020-10-13.
//

#import "UADSWeakProxy.h"

@interface UADSWeakProxy ()

@property (nonatomic, weak) id proxyObject;

@end

@implementation UADSWeakProxy

- (instancetype)initWithObject: (id)object {
    self.proxyObject = object;
    return self;
}

+ (instancetype)newWithObject: (id)object {
    return [[UADSWeakProxy alloc] initWithObject: object];
}

- (id)forwardingTargetForSelector: (SEL)aSelector {
    return self.proxyObject;
}

- (NSMethodSignature *)methodSignatureForSelector: (SEL)aSelector {
    NSMethodSignature *methodSignature;
    // Keep a strong reference so we can safely send messages
    id strongRefToObject = self.proxyObject;

    if (strongRefToObject) {
        methodSignature = [strongRefToObject methodSignatureForSelector: aSelector];
    } else {
        methodSignature = self.fallbackSignature;
    }

    return methodSignature;
}

/** If the proxyObject is nil we need to provide placeholder for the method signature to avoid crash of type "[NSProxy doesNotRecognizeSelector...
 * From the docs https://developer.apple.com/documentation/foundation/nsmethodsignature
 *
 * A method signature consists of one or more characters for the method return type, followed by the string encodings of the implicit arguments self and _cmd, followed by zero or more explicit arguments. You can determine the string encoding and the length of a return type using methodReturnType and methodReturnLength properties. You can access arguments individually using the getArgumentTypeAtIndex: method and numberOfArguments property.
 *
 * So the idea basically to create a string that contains necessary arguments and then using `signatureWithObjCTypes` create a "void" signature to prevent crash.
 *
 */
- (NSMethodSignature *)fallbackSignature {
    NSString *firstArgument = [NSString stringWithUTF8String: @encode(id)];
    NSString *secondArgument = [NSString stringWithUTF8String: @encode(SEL)];
    NSString *types = [NSString stringWithFormat: @"%@%@", firstArgument, secondArgument];
    const char *objCTypes = [types UTF8String];

    if (objCTypes) {
        return [NSMethodSignature signatureWithObjCTypes: objCTypes];
    } else {
        return nil;
    }
}

- (void)forwardInvocation: (NSInvocation *)anInvocation {
    [anInvocation invokeWithTarget: self.proxyObject];
}

@end
