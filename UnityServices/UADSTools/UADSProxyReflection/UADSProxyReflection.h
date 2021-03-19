NS_ASSUME_NONNULL_BEGIN

/**
    Class-proxy that wraps any object that needs to be initialized or called method on it reflectively
 
    Provides the next functionality
 
     -   Init any object reflectively using instance or class methods.

     -   Check if an object exists.

     -   Check if an object is valid/was initialized properly. Should be done by subclasses.

     -   Unified method to call any instance function reflectively.
 
 @code
 // assuming we have ObjectA and ObjectB with the
 // next declarations that need to be called reflectively
 
 @interface ObjectA
 -(instancetype)initWithID: (NSString *)id;
 -(NSDictionary *)source;
 -(NSString *)requestID;
 @end
 
 @interface ObjectB
 +(instancetype)createUsingObject: (ObjectA *)obj
 @end
 
  //Declare and implement Bridges
 @interface ObjectABridge
 +(instancetype)newWithID: (NSString *)id;
 @end
 
 @implementation ObjectABridge()
 +(NSString *)className {
    return @"ObjectA";
 }
 
 +(instancetype)newWithID: (NSString *)id {
    return [self getInstanceUsingMethod:@"initWithID:"
                                   args:@[id]];
 }
 @end
 
 @interface ObjectBBridge
 +(instancetype)createUsingObject: (ObjectABridge *)obj
 @end
 
 @implementation ObjectBBridge
 +(NSString *)className {
    return @"ObjectB";
 }
 
 +(instancetype)createUsingObject: (ObjectABridge *)obj {
    return [self getInstanceUsingClassMethod:@"createUsingObject:"
                                        args: @[]];
 }
 @end
  
 // Now you can use them as a strong-type objects, intercept the calls if need.
    if (![ObjectABridge exists]) {
        // quit from the function with error if need
        return nil;
    }
    ObjectABridge *objA = [ObjectABridge newWithID: @"ID"];
    ObjectBBridge *objB = [ObjectBBridge createUsingObject: objA];
 */

@interface UADSProxyReflection: NSObject
@property (nonatomic, strong,readonly) NSObject *proxyObject;

/// A subclass should provide a class name of an object to work with reflectivly.
+(NSString *)className;

/// Returns a class of an object
+(Class)getClass;

/// Returns if the object with `className` exists
+(bool)exists;

/// Create an object using instance method
/// @param methodName Instance method initializer
/// @param arguments An Array of arguments for initializer
+(instancetype)getInstanceUsingMethod:(NSString *)methodName
                                 args:(NSArray<id> *)arguments;

/// Create an object using class method
/// @param methodName Class method for initializing/creating an object
/// @param arguments An Array of arguments for initializer
+(instancetype)getInstanceUsingClassMethod:(NSString *)methodName
                                      args:(NSArray<id> *)arguments;

/// Create a proxy with an object
/// @param object Any object
+(instancetype)getProxyWithObject:(id)object;

/// Initialize a proxy with an object
/// @param object Any object
-(instancetype)initWithProxyObject:(_Nullable id)object;

/// Returns if an object is valid. By default it checks if the wrapped object is not nil
-(bool)isValid;

/// Call an instance method reflectively
/// @param methodName Instance method name. Should be a format: @"methodname:arg1:arg2"
/// @param arguments An Array of arguments for the method
-(void)callInstanceMethod: (NSString *)methodName
                     args: (NSArray<id> *)arguments;

+(void)callClassMethod: (NSString *)methodName
                  args: (NSArray<id> *)arguments;


// Subclasses can override it to provide extended check for class existance
// Include the selectors that are required for a class to operate
+ (NSArray<NSString *> *)requiredSelectors;


// Subclasses can override it to provide extended check for class existance
// Include keys that are used by KVC and are required for a class to operate
+ (NSArray<NSString *> *)requiredKeysForKVO;


@end

NS_ASSUME_NONNULL_END
