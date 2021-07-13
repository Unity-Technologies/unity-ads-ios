#import "NSMutableDictionary + SafeOperations.h"
#import "UADSTools.h"

@implementation NSMutableDictionary (SafeOperations)
- (void)uads_setValueIfNotNil: (id)object forKey: (NSString *)key {
    GUARD(object)
    [self setValue: object forKey: key];
}

@end
