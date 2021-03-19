#import "UADSTransactionObserver.h"
#import "NSMutableDictionary + SafeOperations.h"
#import "SKPaymentTransaction + Dictionary.h"
#import "NSArray + Map.h"
static NSString *const kSKPaymentTransactionReceiptKey = @"receipt";

@interface UADSTransactionObserver()
@property (nonatomic, nonnull, strong) UADSTransactionObserverCompletion completion;
@property (nonatomic, nonnull, strong) id<UADSAppStoreReceiptReader> reader;
@end

@implementation UADSTransactionObserver

+(instancetype)newWithReceiptReader: (id<UADSAppStoreReceiptReader>) reader
                      andCompletion: (UADSTransactionObserverCompletion) completion {
    UADSTransactionObserver *obj = [[self alloc] init];
    obj.completion = completion;
    obj.reader = reader;
    return obj;
}

- (void)paymentQueue:(nonnull SKPaymentQueue *)queue
 updatedTransactions:(nonnull NSArray<SKPaymentTransaction *> *)transactions {

    NSArray<NSDictionary*> *transactionData = [transactions uads_mapObjectsUsingBlock:^id _Nonnull(id  _Nonnull obj) {
       return [self convertToDictionary: obj];
    }];
    
    _completion(transactionData);
    
}

-(NSDictionary *)convertToDictionary: (SKPaymentTransaction *)transaction {
    return [self attachReceiptTo: transaction.uads_Dictionary];
}

-(NSDictionary *)attachReceiptTo: (NSDictionary *)transactionData {
    NSMutableDictionary *transactionMutable = [[NSMutableDictionary alloc] initWithDictionary: transactionData];
     [transactionMutable uads_setValueIfNotNil: self.reader.encodedReceipt
                                   forKey: kSKPaymentTransactionReceiptKey];
    return transactionMutable;
}

@end
