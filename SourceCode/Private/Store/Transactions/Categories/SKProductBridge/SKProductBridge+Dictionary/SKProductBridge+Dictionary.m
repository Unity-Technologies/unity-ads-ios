#import "SKProductBridge+Dictionary.h"
#import "NSMutableDictionary+SafeOperations.h"
#import "SKProductSubscriptionPeriodBridge+Dictionary.h"
#import "NSLocale+PriceDictionary.h"
#import "SKProductDiscountBridge+Dictionary.h"
#import "NSArray+Map.h"

static NSString *const kSKProductIDLocalizedTitleKey = @"localizedTitle";
static NSString *const kSKProductIDLocalizedDescriptionKey = @"localizedDescription";
static NSString *const kSKProductIDKey = @"productIdentifier";
static NSString *const kSKProductIsDownloadableKey = @"downloadable";
static NSString *const kSKProductIsFamilySharable = @"familySharable";
static NSString *const kSKProductSubscriptionGroupIdentifierKey = @"subscriptionGroupIdentifier";
static NSString *const kSKProductSubscriptionPeriodKey = @"subscriptionPeriod";
static NSString *const kSKProductPriceKey = @"price";
static NSString *const kSKProductPriceLocalKey = @"priceLocale";
static NSString *const kSKProductDiscountsKey = @"discounts";
static NSString *const kSKProductIntroductoryPriceKey = @"introductoryPrice";

@implementation SKProductBridge (Dictionary)

- (NSDictionary *_Nonnull)uads_Dictionary {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

    [dictionary uads_setValueIfNotNil: self.productIdentifier
                               forKey: kSKProductIDKey];

    [dictionary uads_setValueIfNotNil: self.localizedTitle
                               forKey: kSKProductIDLocalizedTitleKey];

    [dictionary uads_setValueIfNotNil: self.localizedDescription
                               forKey: kSKProductIDLocalizedDescriptionKey];

    [dictionary uads_setValueIfNotNil: self.isDownloadableNumber
                               forKey: kSKProductIsDownloadableKey];

    [dictionary uads_setValueIfNotNil: self.isFamilyShareableNumber
                               forKey: kSKProductIsFamilySharable];

    [dictionary uads_setValueIfNotNil: self.subscriptionGroupIdentifier
                               forKey: kSKProductSubscriptionGroupIdentifierKey];

    [dictionary uads_setValueIfNotNil: self.subscriptionPeriod.uads_Dictionary
                               forKey: kSKProductSubscriptionPeriodKey];

    [dictionary uads_setValueIfNotNil: self.introductoryPrice.uads_Dictionary
                               forKey: kSKProductIntroductoryPriceKey];

    [dictionary uads_setValueIfNotNil: self.price
                               forKey: kSKProductPriceKey];

    [dictionary uads_setValueIfNotNil: self.priceLocale.uads_Dictionary
                               forKey: kSKProductPriceLocalKey];

    [dictionary uads_setValueIfNotNil: self.discountsAsDictionaries
                               forKey: kSKProductDiscountsKey];

    return dictionary;
} /* uads_Dictionary */

- (NSArray *)discountsAsDictionaries {
    NSArray *arrayOfDiscounts = self.discounts;

    GUARD_OR_NIL(arrayOfDiscounts)
    return [arrayOfDiscounts uads_mapObjectsUsingBlock: ^id _Nonnull (SKProductDiscountBridge *_Nonnull obj) {
        return obj.uads_Dictionary;
    }];
}

@end
