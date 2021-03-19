#import "UADSStoreKitReflection.h"
#import "SKProductSubscriptionPeriodBridge.h"
#import "SKProductDiscountBridge.h"

NS_ASSUME_NONNULL_BEGIN

static NSString *const kProductIdentifierKey = @"productIdentifier";
static NSString *const kLocalizedTitleKey = @"localizedTitle";
static NSString *const kLocalizedDescriptionKey = @"localizedDescription";
static NSString *const kIsFamilyShareableKey = @"isFamilyShareable";
static NSString *const kIsDownloadableKey = @"isDownloadable";
static NSString *const kSubscriptionGroupIdentifierKey = @"subscriptionGroupIdentifier";
static NSString *const kPriceKey = @"price";
static NSString *const kPriceLocaleKey = @"priceLocale";
static NSString *const kSubscriptionPeriodKey = @"subscriptionPeriod";
static NSString *const kIntroductoryPriceKey = @"introductoryPrice";
static NSString *const kDiscountsKey = @"discounts";

@interface SKProductBridge : UADSStoreKitReflection
@property(nonatomic, readonly) NSString* productIdentifier;
@property(nonatomic, readonly) NSString* localizedDescription;
@property(nonatomic, readonly) NSString* localizedTitle;
@property(nonatomic, readonly) NSNumber* isDownloadableNumber;
@property(nonatomic, readonly) NSNumber* isFamilyShareableNumber;
@property(nonatomic, readonly) NSString* subscriptionGroupIdentifier;
@property(nonatomic, readonly) NSDecimalNumber  *price;
@property(nonatomic, readonly) NSLocale* priceLocale;
@property(nonatomic, readonly, nullable) SKProductSubscriptionPeriodBridge *subscriptionPeriod;
@property(nonatomic, readonly, nullable) SKProductDiscountBridge *introductoryPrice;
@property(nonatomic, readonly, nullable) NSArray<SKProductDiscountBridge *> *discounts;
@end

NS_ASSUME_NONNULL_END
