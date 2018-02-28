#import "UADSPurchasing.h"

@interface UADSApiPurchasing : NSObject

+ (id<UADSPurchasingDelegate>)getPurchasingDelegate;

+ (void)setPurchasingDelegate:(id<UADSPurchasingDelegate>)purchasingDelegate;

@end
