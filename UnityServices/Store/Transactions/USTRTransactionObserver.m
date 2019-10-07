#import "USTRTransactionObserver.h"
#import "USRVWebViewApp.h"
#import "USTRStore.h"

@implementation USTRTransactionObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    NSMutableArray<NSDictionary*> *transactionData = [[NSMutableArray alloc] init];

    for (SKPaymentTransaction *transaction in transactions) {
        SKPayment *payment = transaction.payment;
        NSData *receipt = [USTRStore getReceipt];
        NSString *encodedReceipt = [receipt base64EncodedStringWithOptions:0];
        BOOL hasOriginalTransaction = transaction.originalTransaction != nil;

        NSMutableDictionary *productDict = [[NSMutableDictionary alloc] init];

        if (transaction.payment.productIdentifier) {
            [productDict setObject:transaction.payment.productIdentifier forKey:@"productId"];
        }
        if (transaction.transactionState) {
            [productDict setObject:[NSNumber numberWithInteger:transaction.transactionState] forKey:@"transactionState"];
        }
        if (transaction.transactionDate) {
            [productDict setObject:[NSNumber numberWithDouble:[transaction.transactionDate timeIntervalSince1970]] forKey:@"transactionDate"];
        }
        if (transaction.transactionIdentifier) {
            [productDict setObject:transaction.transactionIdentifier forKey:@"transactionId"];
        }

        NSMutableDictionary *paymentDict = [[NSMutableDictionary alloc] init];

        if (payment.productIdentifier) {
            [paymentDict setObject:payment.productIdentifier forKey:@"productId"];
        }
        if (payment.quantity) {
            [paymentDict setObject:[NSNumber numberWithInteger:payment.quantity] forKey:@"numberOfItems"];
        }
        if (paymentDict) {
            [productDict setObject:paymentDict forKey:@"payment"];
        }
        if (encodedReceipt) {
            [productDict setObject:encodedReceipt forKey:@"receipt"];
        }

        [productDict setObject:[NSNumber numberWithBool:hasOriginalTransaction] forKey:@"hasOriginalTransaction"];

        [transactionData addObject:productDict];
    }
    
    [[USRVWebViewApp getCurrentApp] sendEvent:@"RECEIVED_TRANSACTION" category:@"STORE" param1:transactionData, nil];
}

@end
