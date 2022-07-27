#import "NSArray+Convenience.h"

@implementation NSArray (Convenience)

+ (instancetype)uads_newWithRepeating: (id)object count: (int)count {
    NSMutableArray<id> *mutable = [[NSMutableArray alloc] initWithCapacity: count];

    for (int i = 0; i < count; i++) {
        mutable[i] = object;
    }

    return mutable;
}

- (bool)uads_allSatisfy: (bool (^)(id _Nonnull))block {
    __block bool result = true;

    [self enumerateObjectsUsingBlock: ^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (!block(obj)) {
            result = false;
            *stop = YES;
        }
    }];

    return result;
}

- (NSArray *)uads_removingFirstWhere: (bool(NS_NOESCAPE ^)(id _Nonnull))block {
    NSMutableArray *newArray = [[NSMutableArray alloc] init];
    __block BOOL removed = NO;

    [self enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (block(obj) && !removed) {
            removed = YES;
        } else {
            [newArray addObject: obj];
        }
    }];
    return newArray;
}

@end
