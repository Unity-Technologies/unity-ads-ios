#import "SKPayment+Dictionary.h"
#import "NSMutableDictionary+SafeOperations.h"

static NSString *const kSKPaymentProductIDKey = @"productIdentifier";
static NSString *const kSKPaymentQuantityKey = @"quantity";
static NSString *const kSKPaymentApplicationUsernameKey = @"applicationUsername";

@implementation SKPayment (Dictionary)

- (NSDictionary *_Nonnull)uads_Dictionary {
    NSMutableDictionary *paymentDictionary = [[NSMutableDictionary alloc] init];

    [paymentDictionary uads_setValueIfNotNil: self.productIdentifier
                                      forKey: kSKPaymentProductIDKey];

    [paymentDictionary uads_setValueIfNotNil: self.applicationUsername
                                      forKey: kSKPaymentApplicationUsernameKey];

    [paymentDictionary uads_setValueIfNotNil: [NSNumber numberWithInteger: self.quantity]
                                      forKey: kSKPaymentQuantityKey];

    return paymentDictionary;
}

@end
