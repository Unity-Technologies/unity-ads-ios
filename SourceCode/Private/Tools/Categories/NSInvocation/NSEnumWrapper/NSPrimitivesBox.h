#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * The class is used in invocation when we want to pass any primitive values  to a function with NSInvocation
 *
 * @discussion
 * The problem: NSInvocation category accepts arguments as NSArray that operates with id. We could have used NSValue for those purposes but
 * in this case we would loose the ability to operate with NSNumbers. NSNumber is subclass of NSValue and since NSInvocation uses typecast to a box
 * this creates the problem. For that reason NSPrimitivesBox provides the solution by expecting any primitives for a function been wrapped into it
 *
 */
@interface NSPrimitivesBox : NSValue
+ (instancetype)newWithBytes: (nonnull const void *)bytes objCType: (nonnull const char *)type;

- (void)setAsArgumentForInvocation: (NSInvocation *)invocation atIndex:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
