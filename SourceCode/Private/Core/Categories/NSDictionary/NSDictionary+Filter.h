#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary<__covariant KeyType, __covariant ObjectType>  (Filter)

- (NSDictionary *)uads_filter: (BOOL(NS_NOESCAPE ^)(KeyType key, ObjectType obj))block;
- (NSDictionary *)uads_mapKeys: (KeyType(NS_NOESCAPE ^)(KeyType key))block;
- (NSDictionary *)uads_mapValues: (ObjectType(NS_NOESCAPE ^)(KeyType key, ObjectType obj))block;
@end

NS_ASSUME_NONNULL_END
