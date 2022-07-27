#import "SKProductSubscriptionPeriodBridge+Dictionary.h"
#import "NSMutableDictionary+SafeOperations.h"

@implementation SKProductSubscriptionPeriodBridge (Dictionary)
- (NSDictionary *_Nonnull)uads_Dictionary {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

    [dictionary uads_setValueIfNotNil: self.numberOfUnitsNumber
                               forKey: kSKProductSubscriptionNumberOfUnitsKey];

    [dictionary uads_setValueIfNotNil: self.unitNumber
                               forKey: kSKProductSubscriptionUnitKey];
    return dictionary;
}

@end
