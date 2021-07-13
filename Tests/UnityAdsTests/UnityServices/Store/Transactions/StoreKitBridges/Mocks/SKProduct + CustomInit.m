#import "SKProduct + CustomInit.h"
#import "NSLocale + CustomInit.h"
#import "SKProductSubscriptionPeriod + CustomInit.h"
#import "SKProductDiscount + CustomInit.h"
#import "NSArray + Map.h"

@implementation SKProduct (CustomInit)
+ (instancetype)newFromDictionary: (NSDictionary *)dictionary {
    SKProduct *newProduct = [[SKProduct alloc] init];

    [newProduct setValue: dictionary[kProductIdentifierKey]
                  forKey: kProductIdentifierKey];

    [newProduct setValue: dictionary[kLocalizedTitleKey]
                  forKey: kLocalizedTitleKey];

    [newProduct setValue: dictionary[kLocalizedDescriptionKey]
                  forKey: kLocalizedDescriptionKey];

    [newProduct setValue: dictionary[kPriceKey]
                  forKey: kPriceKey];

    [newProduct setValue: [NSLocale newForUS]
                  forKey: kPriceLocaleKey];

    if (@available(iOS 11.2, *)) {
        NSDictionary *periodDictionary = dictionary[kSubscriptionPeriodKey];
        [newProduct setValue: [SKProductSubscriptionPeriod newFromDictionary: periodDictionary]
                      forKey: kSubscriptionPeriodKey];


        NSDictionary *introductoryPriceDictionary = dictionary[kIntroductoryPriceKey];

        [newProduct setValue: [SKProductDiscount newFromDictionary: introductoryPriceDictionary]
                      forKey: kIntroductoryPriceKey];
    }

    if (@available(iOS 12.2, *)) {
        NSArray<NSDictionary *> *discountsDictionaries = dictionary[kDiscountsKey];
        NSArray<SKProductDiscount *> *discounts = [discountsDictionaries uads_mapObjectsUsingBlock: ^id _Nonnull (NSDictionary *_Nonnull obj) {
            return [SKProductDiscount newFromDictionary: obj];
        }];

        [newProduct setValue: discounts
                      forKey: kDiscountsKey];
    }

    return newProduct;
} /* newFromDictionary */

+ (NSDictionary *)defaultTestData {
    NSMutableDictionary *mDictionary = [NSMutableDictionary new];

    mDictionary[kProductIdentifierKey] = @"ProductIdentifier";
    mDictionary[kLocalizedTitleKey] = @"LocalizedTitle";
    mDictionary[kLocalizedDescriptionKey] = @"LocalizedDescription";
    mDictionary[kPriceKey] = [NSNumber numberWithDouble: 100.9];
    mDictionary[kPriceLocaleKey] = [NSLocale defaultTestData];
    mDictionary[kIsFamilyShareableKey] = [NSNumber numberWithBool: false];
    mDictionary[kIsDownloadableKey] = [NSNumber numberWithBool: false];

    if (@available(iOS 11.2, *)) {
        mDictionary[kSubscriptionPeriodKey] = [SKProductSubscriptionPeriod defaultTestData];
        mDictionary[kIntroductoryPriceKey] = [SKProductDiscount defaultTestData];
        mDictionary[kDiscountsKey] = @[[SKProductDiscount defaultTestData]];
    }

    return mDictionary;
}

@end
