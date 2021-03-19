#import "UADSProxyReflection.h"
#import "NSInvocation+Convenience.h"
#import "NSArray+Convenience.h"
#import "NSObject+Convenience.h"

@interface UADSProxyReflection()
@property (nonatomic, strong) NSObject *proxyObject;
@end

@implementation UADSProxyReflection

+ (NSString *)className {
    return @"";
}

+ (NSArray<NSString *> *)requiredSelectors {
    return @[];
}

+ (NSArray<NSString *> *)requiredKeysForKVO {
    return @[];
}

+ (bool)exists {
    return [self getClass] != nil &&
           [self respondToRequiredSelectors] &&
           [self respondToRequiredKeys];
}

+ (bool)respondToRequiredSelectors {
    return [[self getClass] containsMethods: self.requiredSelectors];
}

+ (bool)respondToRequiredKeys {
    return [[self getClass] containsMethods: self.requiredKeysForKVO];
}

+ (instancetype)getProxyWithObject:(id)object {
    return [[self alloc] initWithProxyObject: object];
}

+ (instancetype)getInstanceUsingMethod:(NSString *)methodName
                                  args:(NSArray<id> *)arguments {
    return [self getInstanceUsingMethod: methodName
                            classMethod: false
                                   args: arguments];
}

+ (instancetype)getInstanceUsingClassMethod:(NSString *)methodName
                                       args:(NSArray<id> *)arguments {
    return [self getInstanceUsingMethod: methodName
                            classMethod: true
                                   args: arguments];
}

+ (Class)getClass {
    return NSClassFromString([self className]);
}

+ (instancetype)getInstanceUsingMethod: (NSString *)methodName
                           classMethod: (bool) isClassMethod
                                  args: (NSArray<id> *)arguments {
    Class class = [self getClass];
    NULL_CHECK_OR_RETURN_NIL(class)
    
    SEL selector = NSSelectorFromString(methodName);
    NULL_CHECK_OR_RETURN_NIL(selector)
    
    __autoreleasing id obj;
    if (isClassMethod) {
        obj = [NSInvocation uads_invokeWithReturnedUsingMethod: methodName
                                                     classType: class
                                                        target: nil
                                                          args: arguments];
    } else {
        obj = [class alloc];
        NULL_CHECK_OR_RETURN_NIL(obj)
        [NSInvocation uads_invokeUsingMethod: methodName
                                   classType: class
                                      target: obj
                                        args: arguments];
    }
    
    return [[self alloc] initWithProxyObject:  obj];
}

- (bool)isValid {
    return _proxyObject != nil;
}

- (instancetype)initWithProxyObject:(_Nullable id)object{
    self.proxyObject = object;
    return self;
}

- (NSObject *)proxyObject {
    return _proxyObject;
}

- (void)callInstanceMethod: (NSString *)methodName
                      args: (NSArray<id> *)arguments {
    [NSInvocation  uads_invokeUsingMethod: methodName
                                classType: [[self class] getClass]
                                   target: self.proxyObject
                                     args: arguments];
}

+ (void)callClassMethod:(NSString *)methodName args:(NSArray<id> *)arguments {
    [NSInvocation  uads_invokeUsingMethod: methodName
                                classType: [[self class] getClass]
                                   target: nil
                                     args: arguments];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    if ([self.proxyObject respondsToSelector:aSelector]) {
        return self.proxyObject;
    }
    return nil;
 }


- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
     NSMethodSignature *methodSignature;
     methodSignature = [self.proxyObject methodSignatureForSelector: aSelector];
     if (!methodSignature) {
         methodSignature = self.fallbackSignature;
     }
     return methodSignature;
 }

 /** If the proxyObject is nil we need to provide placeholder for the method signature to avoid crash of type "[NSProxy doesNotRecognizeSelector...
  From the docs https://developer.apple.com/documentation/foundation/nsmethodsignature
  
  A method signature consists of one or more characters for the method return type,
  followed by the string encodings of the implicit arguments self and _cmd, followed by zero or more explicit arguments.
  
  You can determine the string encoding and the length of a return type using methodReturnType and methodReturnLength properties.
  You can access arguments individually using the getArgumentTypeAtIndex: method and numberOfArguments property.
  
  So the idea basically to create a string that contains necessary arguments and then using `signatureWithObjCTypes` create a "void" signature to prevent crash.
  
 */
- (NSMethodSignature *)fallbackSignature {
     NSString *firstArgument = [NSString stringWithUTF8String:@encode(id)];
     NSString *secondArgument = [NSString stringWithUTF8String:@encode(SEL)];
     NSString *types = [NSString stringWithFormat:@"%@%@", firstArgument, secondArgument];
     const char *objCTypes = [types UTF8String];
     if (objCTypes) {
         return [NSMethodSignature signatureWithObjCTypes: objCTypes];
     } else {
         return nil;
     }
 }

- (void)forwardInvocation:(NSInvocation *)anInvocation {
   
    if (anInvocation.methodSignature.numberOfArguments < 2) {
        // invalid signature, we should skip it
        // Indication to fallBackSignature:
        // There are always at least two arguments, because an NSMethodSignature
        // object includes the implicit arguments self and _cmd,
        // which are the first two arguments passed to every method implementation.
        return;
    }
    
    [anInvocation invokeWithTarget: self.proxyObject];
}

- (id)valueForKey:(NSString *)key {
    if ([self.proxyObject respondsToSelector: NSSelectorFromString(key)]) {
        return  [self.proxyObject valueForKey:key];
    } else {
       return [super valueForKey: key];
    }
}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

@end


