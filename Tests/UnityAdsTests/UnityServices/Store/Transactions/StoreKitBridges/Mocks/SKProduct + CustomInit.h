#import <StoreKit/StoreKit.h>
#import "SKProductBridge + Dictionary.h"
NS_ASSUME_NONNULL_BEGIN

@interface SKProduct (CustomInit)
+ (instancetype)newFromDictionary: (NSDictionary *)dictionary;
+ (NSDictionary *)defaultTestData;
@end

NS_ASSUME_NONNULL_END
