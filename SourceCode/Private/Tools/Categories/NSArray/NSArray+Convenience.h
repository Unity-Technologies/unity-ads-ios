#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<ObjectType>(Category)

+ (instancetype)uads_newWithRepeating: (ObjectType)object count: (int)count;
- (bool)uads_allSatisfy: (bool (^)(ObjectType obj))block;
- (NSArray *)uads_removingFirstWhere: (bool(NS_NOESCAPE ^)(ObjectType _Nonnull))block;



@end

NS_ASSUME_NONNULL_END
