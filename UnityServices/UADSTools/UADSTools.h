
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




#define GUARD(condition) if (!condition) { return; }

_Nullable id typecast(id obj, Class class);

NS_ASSUME_NONNULL_END
