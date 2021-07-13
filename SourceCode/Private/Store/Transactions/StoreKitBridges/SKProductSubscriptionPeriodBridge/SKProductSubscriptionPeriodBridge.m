#import "SKProductSubscriptionPeriodBridge.h"

@implementation SKProductSubscriptionPeriodBridge

- (NSNumber *)unitNumber {
    return [self valueForKey: kSKProductSubscriptionUnitKey];
}

- (NSNumber *)numberOfUnitsNumber {
    return [self valueForKey: kSKProductSubscriptionNumberOfUnitsKey];
}

@end
