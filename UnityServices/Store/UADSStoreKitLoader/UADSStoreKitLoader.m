#import "UADSStoreKitLoader.h"

@implementation UADSStoreKitLoader

+ (NSString *)frameworkName {
    return @"StoreKit";
}

+ (NSString *)classNameForCheck {
    return @"SKPaymentQueue";
}

@end
