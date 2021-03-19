#import "UADSStoreKitReflection.h"

@implementation UADSStoreKitReflection
- (id)valueForKey:(NSString *)key {
    //due to unexpected behaviour in SKProduct in sdk lower than 12.0 we have to return nil
    //instead of calling super.
    NULL_CHECK_OR_RETURN_NIL([self.proxyObject respondsToSelector: NSSelectorFromString(key)]);
    return [self.proxyObject valueForKey: key];
}
@end
