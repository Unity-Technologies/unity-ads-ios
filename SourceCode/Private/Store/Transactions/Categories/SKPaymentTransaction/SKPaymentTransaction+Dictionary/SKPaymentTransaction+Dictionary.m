#import "SKPayment+Dictionary.h"
#import "SKPaymentTransaction+Dictionary.h"
#import "NSMutableDictionary+SafeOperations.h"
#import "NSDate+NSNumber.h"


static NSString *const kSKPaymentTransactionStateKey = @"transactionState";
static NSString *const kSKPaymentTransactionDateKey = @"transactionDate";
static NSString *const kSKPaymentTransactionIDKey = @"transactionIdentifier";
static NSString *const kSKPaymentOriginalTransactionKey = @"originalTransaction";
static NSString *const kSKPaymentTransactionPaymentKey = @"payment";

@implementation SKPaymentTransaction (Dictionary)

- (NSDictionary *)uads_Dictionary {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];

    [dictionary uads_setValueIfNotNil: self.transactionIdentifier
                               forKey: kSKPaymentTransactionIDKey];

    [dictionary uads_setValueIfNotNil: [NSNumber numberWithInteger: self.transactionState]
                               forKey: kSKPaymentTransactionStateKey];

    [dictionary uads_setValueIfNotNil: self.transactionDate.uads_timeIntervalSince1970
                               forKey: kSKPaymentTransactionDateKey];

    [dictionary uads_setValueIfNotNil: self.originalTransaction.uads_Dictionary
                               forKey: kSKPaymentOriginalTransactionKey];

    [dictionary uads_setValueIfNotNil: self.payment.uads_Dictionary
                               forKey: kSKPaymentTransactionPaymentKey];

    return dictionary;
}

@end
