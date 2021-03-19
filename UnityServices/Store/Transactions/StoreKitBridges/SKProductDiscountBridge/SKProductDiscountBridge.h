#import "UADSStoreKitReflection.h"
#import "SKProductSubscriptionPeriodBridge.h"
NS_ASSUME_NONNULL_BEGIN

static NSString *const kSKProductDiscountIDKey = @"identifier";
static NSString *const kSKProductDiscountSubscriptionPeriodKey = @"subscriptionPeriod";
static NSString *const kSKProductDiscountPriceLocaleKey = @"priceLocale";
static NSString *const kSKProductDiscountPriceKey = @"price";
static NSString *const kSKProductDiscountPaymentModeKey = @"paymentMode";
static NSString *const kSKProductDiscountNumberOfPeriodsKey = @"numberOfPeriods";
static NSString *const kSKProductDiscountTypeKey = @"type";

@interface SKProductDiscountBridge : UADSStoreKitReflection
@property(nonatomic, readonly) NSDecimalNumber *price;
@property(nonatomic, readonly) NSLocale *priceLocale;
@property(nonatomic, readonly, nullable) NSString *identifier;
@property(nonatomic, readonly) SKProductSubscriptionPeriodBridge *subscriptionPeriod;
@property(nonatomic, readonly) NSNumber *numberOfPeriodsNumber;
@property(nonatomic, readonly) NSNumber *paymentModeNumber;
@property(nonatomic, readonly) NSNumber *typeNumber;
@end

NS_ASSUME_NONNULL_END
