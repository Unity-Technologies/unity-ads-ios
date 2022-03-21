#import "NSDictionary+Filter.h"

@implementation NSDictionary (Filter)
- (NSDictionary *)uads_filter: (BOOL(NS_NOESCAPE ^)(id key, id obj))block; {
    NSMutableDictionary *newDictionary = [NSMutableDictionary new];

    [self enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        if (block(key, obj)) {
            newDictionary[key] = obj;
        }
    }];

    return newDictionary;
}

- (NSDictionary *)uads_mapKeys: (id(NS_NOESCAPE ^)(id key))block {
    NSMutableDictionary *newDictionary = [NSMutableDictionary new];

    [self enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL *_Nonnull stop) {
        newDictionary[block(key)] = obj;
    }];

    return newDictionary;
}

@end
