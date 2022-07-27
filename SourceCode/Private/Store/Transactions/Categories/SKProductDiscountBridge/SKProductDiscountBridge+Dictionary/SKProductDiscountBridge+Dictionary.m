#import "SKProductDiscountBridge+Dictionary.h"
#import "NSMutableDictionary+SafeOperations.h"
#import "SKProductSubscriptionPeriodBridge+Dictionary.h"
#import "NSLocale+PriceDictionary.h"


@implementation SKProductDiscountBridge (Dictionary)
- (NSDictionary *_Nonnull)uads_Dictionary {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

    [dictionary uads_setValueIfNotNil: self.subscriptionPeriod.uads_Dictionary
                               forKey: kSKProductDiscountSubscriptionPeriodKey];

    [dictionary uads_setValueIfNotNil: self.identifier
                               forKey: kSKProductDiscountIDKey];

    [dictionary uads_setValueIfNotNil: self.priceLocale.uads_Dictionary
                               forKey: kSKProductDiscountPriceLocaleKey];

    [dictionary uads_setValueIfNotNil: self.price
                               forKey: kSKProductDiscountPriceKey];

    [dictionary uads_setValueIfNotNil: self.paymentModeNumber
                               forKey: kSKProductDiscountPaymentModeKey];

    [dictionary uads_setValueIfNotNil: self.numberOfPeriodsNumber
                               forKey: kSKProductDiscountNumberOfPeriodsKey];

    [dictionary uads_setValueIfNotNil: self.typeNumber
                               forKey: kSKProductDiscountTypeKey];

    return dictionary;
} /* uads_Dictionary */

@end
