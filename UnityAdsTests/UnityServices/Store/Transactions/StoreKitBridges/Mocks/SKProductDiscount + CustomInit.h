#import <StoreKit/StoreKit.h>
#import "SKProductDiscountBridge.h"
NS_ASSUME_NONNULL_BEGIN

@interface SKProductDiscount(CustomInit)
+(instancetype)newFromDictionary: (NSDictionary *)dictionary;
+(NSDictionary *)defaultTestData;
@end

NS_ASSUME_NONNULL_END
