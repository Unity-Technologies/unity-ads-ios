#import "NSObject+WeakProxy.h"
#import "UADSWeakProxy.h"

@implementation NSObject (Category)

- (id)weakSelf {
    return [UADSWeakProxy newWithObject: self];
}

@end
