#import "NSArray+SafeOperations.h"
#import "NSArray+Map.h"

@implementation NSArray (Category)

- (_Nullable id)uads_getItemSafelyAtIndex: (NSInteger)index {
    if (index >= [self count]) {
        return nil;
    } else {
        return [self objectAtIndex: index];
    }
}

- (instancetype)uads_removingFirstElements: (unsigned long)count {
    if (self.count <= count) {
        return [NSArray new];
    }

    unsigned long finalCount = self.count - count;
    NSMutableArray *result = [NSMutableArray arrayWithCapacity: finalCount];

    [self enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        if (idx > count - 1) {
            [result addObject: obj];
        }
    }];
    return result;
}

@end
