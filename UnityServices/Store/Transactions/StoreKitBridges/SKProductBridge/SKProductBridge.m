
#import "SKProductBridge.h"
#import <StoreKit/StoreKit.h>
#import "NSArray + Map.h"

@implementation SKProductBridge

- (NSString *)productIdentifier {
    return [self valueForKey: kProductIdentifierKey];
}

- (NSString *)localizedTitle {
    return [self valueForKey: kLocalizedTitleKey];
}

- (NSString *)localizedDescription {
    return [self valueForKey: kLocalizedDescriptionKey];
}

- (NSNumber *)isDownloadableNumber {
    return [self valueForKey: kIsDownloadableKey];
}

- (NSNumber *)isFamilyShareableNumber {
    return [self valueForKey: kIsFamilyShareableKey];
}

- (NSString *)subscriptionGroupIdentifier {
    return [self valueForKey: kSubscriptionGroupIdentifierKey];
}

- (NSDecimalNumber *)price {
   return [self valueForKey: kPriceKey];
}

- (NSLocale *)priceLocale {
    return [self valueForKey: kPriceLocaleKey];
}

- (SKProductDiscountBridge *)introductoryPrice {
    id obj = [self valueForKey: kIntroductoryPriceKey];
    NULL_CHECK_OR_RETURN_NIL(obj)
    return [SKProductDiscountBridge getProxyWithObject: obj];
}
- (SKProductSubscriptionPeriodBridge *)subscriptionPeriod {
    id obj = [self valueForKey: kSubscriptionPeriodKey];
    NULL_CHECK_OR_RETURN_NIL(obj)
    return [SKProductSubscriptionPeriodBridge getProxyWithObject: obj];
}

- (NSArray<SKProductDiscountBridge *> *)discounts {
    NSArray *discountsAsIDs = [self valueForKey: kDiscountsKey];
    NULL_CHECK_OR_RETURN_NIL(discountsAsIDs)
    return [discountsAsIDs uads_mapObjectsUsingBlock:^id _Nonnull(id  _Nonnull obj) {
        return  [SKProductDiscountBridge getProxyWithObject: obj];
    }];
}


@end
