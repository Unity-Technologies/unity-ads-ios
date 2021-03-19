#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

/**
    Macro that replaces boilerplate code like:
 @code
 
 if ([obj isKindOfClass: class]) {
     return obj;
 } else {
     return nil;
 }
 */
#define TYPECAST(obj, class) typecast(obj, class)

/**
    Macro that replaces  boilerplate code for nil checking and returning from the scope of a function
 */
#define NULL_CHECK_OR_RETURN_NIL(obj) if (!obj) { return nil;}


/**
    Macro that replaces  boilerplate code when calling super init
 */
#define SUPER_INIT self = [super init]; if (!self) { return nil ;}

/**
    Convenience macro to provide sharedInstance function implementation with custom initializer
 */

#define _uads_custom_singleton_imp(CLASSNAME, INIT_FUNCTION) \
+(instancetype)sharedInstance { \
UADS_SHARED_INSTANCE(CLASSNAME,INIT_FUNCTION)\
}\

/**
    Convenience macro to provide sharedInstance function implementation with default initializer
 */
#define _uads_default_singleton_imp(CLASSNAME) \
+(instancetype)sharedInstance { \
UADS_SHARED_INSTANCE(CLASSNAME,^{ return [[self alloc] init]; })\
}\

/**
    Convenience macro to provide implementation of dispatch_once to create a singleton
 */
#define UADS_SHARED_INSTANCE(TOKEN, INIT_FUNCTION) \
static id instance = nil; \
UADS_DISPATCH_ONCE(TOKEN_NAME,^{ \
    instance = INIT_FUNCTION(); \
})\
return instance;\


/**
    Convenience macro to provide dispatch_once call implementation
 */
#define UADS_DISPATCH_ONCE(TOKEN_NAME,FUNCTION) \
static dispatch_once_t TOKEN_NAME ## _token; \
dispatch_once(&TOKEN_NAME ## _token, FUNCTION);\

#define GUARD_OR_NIL(condition) if (!condition) { return nil;}

#define GUARD(condition) if (!condition) { return;}


_Nullable id typecast(id obj, Class class);

typedef void(^UADSNSErrorCompletion)(NSError * _Nullable error);

void dispatch_on_main(dispatch_block_t block);

typedef void(^UADSVoidClosure)(void);


NS_ASSUME_NONNULL_END
