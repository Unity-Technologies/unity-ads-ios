#import "SKProductDiscount + CustomInit.h"
#import "SKProductSubscriptionPeriod + CustomInit.h"
#import "NSLocale + CustomInit.h"

@implementation SKProductDiscount (CustomInit)

+ (instancetype)newFromDictionary: (NSDictionary *)dictionary {
    SKProductDiscount *newPeriod = [[SKProductDiscount alloc] init];

    if (@available(iOS 12.0, *)) {
        [newPeriod setValue: dictionary[kSKProductDiscountIDKey]
                     forKey: kSKProductDiscountIDKey];
    }

    SKProductSubscriptionPeriod *period = [SKProductSubscriptionPeriod newFromDictionary: dictionary[kSKProductDiscountSubscriptionPeriodKey]];

    [newPeriod setValue: period
                 forKey: kSKProductDiscountSubscriptionPeriodKey];

    [newPeriod setValue: [NSLocale newForUS]
                 forKey: kSKProductDiscountPriceLocaleKey];

    [newPeriod setValue: dictionary[kSKProductDiscountPriceKey]
                 forKey: kSKProductDiscountPriceKey];

    [newPeriod setValue: dictionary[kSKProductDiscountPaymentModeKey]
                 forKey: kSKProductDiscountPaymentModeKey];

    [newPeriod setValue: dictionary[kSKProductDiscountNumberOfPeriodsKey]
                 forKey: kSKProductDiscountNumberOfPeriodsKey];

    if (@available(iOS 12.2, *)) {
        [newPeriod setValue: dictionary[kSKProductDiscountTypeKey]
                     forKey: kSKProductDiscountTypeKey];
    }

    return newPeriod;
} /* newFromDictionary */

+ (NSDictionary *)defaultTestData {
    NSMutableDictionary *mDictionary = [NSMutableDictionary new];

    mDictionary[kSKProductDiscountIDKey] = @"SKProductDiscountID";
    mDictionary[kSKProductDiscountSubscriptionPeriodKey] = [SKProductSubscriptionPeriod defaultTestData];
    mDictionary[kSKProductDiscountPriceKey] = @100.5;
    mDictionary[kSKProductDiscountNumberOfPeriodsKey] = @1;
    mDictionary[kSKProductDiscountPaymentModeKey] = @2;

    if (@available(iOS 12.2, *)) {
        mDictionary[kSKProductDiscountTypeKey] = @1;
    } else {
        mDictionary[kSKProductDiscountTypeKey] = nil;
    }

    return mDictionary;
}

@end
