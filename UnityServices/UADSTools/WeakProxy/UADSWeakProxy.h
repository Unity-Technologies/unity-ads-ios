
NS_ASSUME_NONNULL_BEGIN

/**
 Instances of `UADSWeakProxy` hold a weak reference to the target object.
 */

@interface UADSWeakProxy : NSProxy

/**
 Initializes an `UADSWeakProxy` object with the specified target object.
 
 @param object The target object for the proxy.
 
 @return The newly initialized proxy.
 */
+ (instancetype)newWithObject: (id)object;

@end


NS_ASSUME_NONNULL_END
