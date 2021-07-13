#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<ObjectType>(Category)

- (bool)uads_allSatisfy: (bool (^)(ObjectType obj))block;

@end

NS_ASSUME_NONNULL_END
