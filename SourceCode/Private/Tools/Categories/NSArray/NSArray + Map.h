#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef id _Nonnull (^NSArrayMapBlock)(id obj);

@interface NSArray (Map)
- (NSArray *)uads_mapObjectsUsingBlock: (NSArrayMapBlock)block;
@end

NS_ASSUME_NONNULL_END
