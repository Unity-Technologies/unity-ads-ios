#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef id _Nonnull (^NSArrayMapBlock)(id obj);
typedef BOOL (^NSArrayFilterBlock)(id obj);


@interface NSArray (Map)
- (NSArray *)uads_mapObjectsUsingBlock: (NSArrayMapBlock)block;

- (NSArray *)uads_filter: (NSArrayFilterBlock)block;
@end

NS_ASSUME_NONNULL_END
