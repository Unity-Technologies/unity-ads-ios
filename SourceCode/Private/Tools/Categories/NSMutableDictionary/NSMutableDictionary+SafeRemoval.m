#import "NSMutableDictionary+SafeRemoval.h"

@implementation NSMutableDictionary (SafeRemoval)
- (id)uads_removeObjectForKeyAndReturn: (NSString *)key {
    if (key == nil) {
        return nil;
    }
    
    id object = [self objectForKey: key];
    [self removeObjectForKey: key];
    return object;
}

@end
