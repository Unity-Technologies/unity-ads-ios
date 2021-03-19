#import "NSArray + Map.h"

@implementation NSArray(Map)
- (NSArray *)uads_mapObjectsUsingBlock:(NSArrayMapBlock)block {
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[self count]];
     [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
         [result addObject:block(obj)];
     }];
     return result;
}
@end
