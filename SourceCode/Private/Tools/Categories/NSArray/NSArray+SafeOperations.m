#import "NSArray+SafeOperations.h"

@implementation NSArray (Category)

- (_Nullable id)uads_getItemSafelyAtIndex: (NSInteger)index {
    if (index >= [self count]) {
        return nil;
    } else {
        return [self objectAtIndex: index];
    }
}

@end
