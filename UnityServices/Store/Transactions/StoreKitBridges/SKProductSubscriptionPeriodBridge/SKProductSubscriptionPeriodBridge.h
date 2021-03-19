#import "UADSStoreKitReflection.h"

NS_ASSUME_NONNULL_BEGIN
static NSString *const kSKProductSubscriptionNumberOfUnitsKey = @"numberOfUnits";
static NSString *const kSKProductSubscriptionUnitKey = @"unit";

@interface SKProductSubscriptionPeriodBridge: UADSStoreKitReflection
@property(nonatomic, readonly) NSNumber *numberOfUnitsNumber;
@property(nonatomic, readonly) NSNumber *unitNumber;
@end

NS_ASSUME_NONNULL_END
