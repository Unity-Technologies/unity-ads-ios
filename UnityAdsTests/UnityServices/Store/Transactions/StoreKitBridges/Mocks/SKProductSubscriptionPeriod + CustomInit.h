#import <StoreKit/StoreKit.h>
#import "SKProductSubscriptionPeriodBridge.h"

NS_ASSUME_NONNULL_BEGIN

@interface SKProductSubscriptionPeriod(CustomInit)
+(instancetype)newFromDictionary: (NSDictionary *)dictionary;
+(NSDictionary *)defaultTestData;
@end

NS_ASSUME_NONNULL_END
