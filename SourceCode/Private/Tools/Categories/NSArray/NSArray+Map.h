#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface NSArray<ObjectType> (Map)
typedef id _Nonnull (^NSArrayMapBlock)(ObjectType obj);
typedef BOOL (^NSArrayFilterBlock)(ObjectType obj);
- (NSArray *)uads_mapObjectsUsingBlock: (NSArrayMapBlock)block;

- (NSArray *)uads_filter: (NSArrayFilterBlock)block;
@end

NS_ASSUME_NONNULL_END
