#import "SKProductDiscountBridge.h"

@implementation SKProductDiscountBridge

- (NSDecimalNumber *)price {
    return  [self valueForKey: kSKProductDiscountPriceKey];
}

- (NSString *)identifier {
    return  [self valueForKey: kSKProductDiscountIDKey];
}

- (NSLocale *)priceLocale {
    return [self valueForKey: kSKProductDiscountPriceLocaleKey];
}

- (NSNumber *)numberOfPeriodsNumber {
    return [self valueForKey: kSKProductDiscountNumberOfPeriodsKey];
}

- (NSNumber *)paymentModeNumber {
    return  [self valueForKey: kSKProductDiscountPaymentModeKey];
}

- (NSNumber *)typeNumber {
    return  [self valueForKey: kSKProductDiscountTypeKey];
}

@end
