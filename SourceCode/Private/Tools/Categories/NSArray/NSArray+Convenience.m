#import "NSArray+Convenience.h"

@implementation NSArray (Convenience)
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
    NSMutableArray *newArray = [[NSMutableArray alloc] initWithArray: self];

    [self enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (block(obj)) {
            [newArray removeObject: obj];
        } else {
            *stop = YES;
        }
    }];
    return newArray;
}

@end
