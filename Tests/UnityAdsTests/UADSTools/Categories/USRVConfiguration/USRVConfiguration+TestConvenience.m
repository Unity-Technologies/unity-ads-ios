
#import "USRVConfiguration+TestConvenience.h"

@implementation USRVConfiguration (TestConvenience)
+ (instancetype)newEmpty {
    return [self newFromJSON: @{}];
}

@end
