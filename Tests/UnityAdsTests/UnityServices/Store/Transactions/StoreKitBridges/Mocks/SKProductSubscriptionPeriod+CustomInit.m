
#import "SKProductSubscriptionPeriod+CustomInit.h"

@implementation SKProductSubscriptionPeriod (CustomInit)

+ (instancetype)newFromDictionary: (NSDictionary *)dictionary {
    SKProductSubscriptionPeriod *newPeriod = [[SKProductSubscriptionPeriod alloc] init];

    [newPeriod setValue: dictionary[kSKProductSubscriptionUnitKey]
                 forKey: kSKProductSubscriptionUnitKey];

    [newPeriod setValue: dictionary[kSKProductSubscriptionNumberOfUnitsKey]
                 forKey: kSKProductSubscriptionNumberOfUnitsKey];
    return newPeriod;
}

+ (NSDictionary *)defaultTestData {
    NSMutableDictionary *mDictionary = [NSMutableDictionary new];

    mDictionary[kSKProductSubscriptionUnitKey] = @1;
    mDictionary[kSKProductSubscriptionNumberOfUnitsKey] = @1;
    return mDictionary;
}

@end
