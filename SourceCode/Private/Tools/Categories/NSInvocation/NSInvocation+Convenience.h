NS_ASSUME_NONNULL_BEGIN

/*
 * Category that provides convenience static methods to create and perform invocations.
 *
 */
@interface NSInvocation (Category)


/// Invokes a method on a Class or on an instance with a set of arguments
/// @note If a target is nil, will try to perform static method on a class.
/// @param methodName Full name of a selector
/// @param classType Class
/// @param target target of type Class
/// @param arguments arguments required by the a function
///
/// @note When we need to pass an enum as an argument, use NSEnumWrapper
///    @code NSEnumWrapper *typeWrapped = [NSEnumWrapper newWithBytes:&`EnumValue` objCType: @encode(EnumType)];
+ (void)uads_invokeUsingMethod: (NSString *)methodName
                     classType: (Class)classType
                        target: (_Nullable id)target
                          args: (NSArray *)arguments;


/// Creates a prepared NSInvocation to perform a method of a Class or on an instance with a set of arguments
/// @note If a target is nil, will try to perform static method on a class.
/// @param methodName Full name of a selector
/// @param classType Class
/// @param target target of type Class
/// @param arguments arguments required by the a function
///
/// @note When we need to pass an enum as an argument, use NSEnumWrapper
///    @code NSEnumWrapper *typeWrapped = [NSEnumWrapper newWithBytes:&`EnumValue` objCType: @encode(EnumType)];
+ (nullable instancetype)uads_newUsingMethod: (NSString *)methodName
                                   classType: (Class)classType
                                      target: (_Nullable id)target
                                        args: (NSArray *)arguments;


/// Invokes a method on a Class or on an instance with a set of arguments. Returns a result of invoked function
/// @note If a target is nil, will try to perform static method on a class.
///
/// @param methodName Full name of a selector
/// @param classType Class
/// @param target target of type Class
/// @param arguments arguments required by the a function
///
/// @note When we need to pass an enum as an argument, use NSEnumWrapper
///    @code NSEnumWrapper *typeWrapped = [NSEnumWrapper newWithBytes:&`EnumValue` objCType: @encode(EnumType)];
+ (nullable id)uads_invokeWithReturnedUsingMethod: (NSString *)methodName
                                        classType: (Class)classType
                                           target: (_Nullable id)target
                                             args: (NSArray *)arguments;
@end

NS_ASSUME_NONNULL_END
