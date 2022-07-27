#import <Foundation/Foundation.h>

#import "USRVDeviceLog.h"
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
    Macro that replaces  boilerplate code when calling super init
 */
#define SUPER_INIT self = [super init]; if (!self) { return nil; }

/**
    Convenience macro to provide sharedInstance function implementation with custom initializer
 */

#define _uads_custom_singleton_imp(CLASSNAME, INIT_FUNCTION) \
    + (instancetype)sharedInstance { \
        UADS_SHARED_INSTANCE(CLASSNAME, INIT_FUNCTION) \
    } \

/**
    Convenience macro to provide sharedInstance function implementation with default initializer
 */
#define _uads_default_singleton_imp(CLASSNAME) \
    + (instancetype)sharedInstance { \
        UADS_SHARED_INSTANCE(CLASSNAME, ^{ return [[self alloc] init]; }) \
    } \

/**
    Convenience macro to provide implementation of dispatch_once to create a singleton
 */
#define UADS_SHARED_INSTANCE(TOKEN, INIT_FUNCTION) \
    static id instance = nil; \
    UADS_DISPATCH_ONCE(TOKEN_NAME, ^{ \
        instance = INIT_FUNCTION(); \
    }) \
    return instance; \


/**
    Convenience macro to provide dispatch_once call implementation
 */
#define UADS_DISPATCH_ONCE(TOKEN_NAME, FUNCTION) \
    static dispatch_once_t TOKEN_NAME ## _token; \
    dispatch_once(&TOKEN_NAME ## _token, FUNCTION); \


/**
    Convenience macro to check for condition and return nil if false
 */
#define GUARD_OR_NIL(condition) if (!condition) { return nil; }

/**
    Convenience macro to check for condition and return if false
 */
#define GUARD(condition)        if (!condition) { return; }

#define CHECK_POINTER_AND_ASSIGN_OBJECT(pointer, object) \
    if (pointer) { \
        *pointer = object; \
    } \

#define UADS_ABSTRACT_CLASS_EXCEPTION \
    NSAssert(NO, @"Cannot be used as an abstract class");




_Nullable id typecast(id obj, Class class);

typedef void (^UADSNSErrorCompletion)(NSError *_Nullable error);

void dispatch_on_main(dispatch_block_t block);
void dispatch_on_main_sync(dispatch_block_t block);

typedef void (^UADSVoidClosure)(void);
typedef void (^UADSDurationMeasureClosure)(UADSVoidClosure);
typedef void (^UADSDurationClosure)(CFTimeInterval);
typedef void (^UADSDurationNSNumberClosure)(NSNumber *);


static NSString *const kUADS_EMPTY_STRING = @"";

void uads_measure_duration_async(UADSDurationMeasureClosure blockToMeasure, UADSDurationClosure result);
void uads_measure_duration_round_async(UADSDurationMeasureClosure blockToMeasure, UADSDurationNSNumberClosure result);


CFTimeInterval uads_measure_duration_sync(UADSVoidClosure blockToMeasure);
void uads_measure_performance_and_log(NSString *name, UADSVoidClosure blockToMeasure);

NSString *uads_bool_to_string(BOOL value);
NS_ASSUME_NONNULL_END
