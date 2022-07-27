#import "NSObject+WeakProxy.h"
#import "UADSWeakProxy.h"

@implementation NSObject (Category)

- (id)uads_weakSelf {
    return [UADSWeakProxy newWithObject: self];
}

@end
