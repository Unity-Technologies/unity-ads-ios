#import <objc/runtime.h>
#import <dlfcn.h>
#import "USTRStore.h"
#import "USRVDevice.h"
#import "UADSTools.h"
#import "NSArray + Map.h"
#import "SKProductBridge + Dictionary.h"

@interface USTRStore()
@property (nonatomic, nonnull, strong) id<UADSAppStoreReceiptReader> receiptReader;
@property (nonatomic, nonnull, strong) id<UADSSKProductReader> productsReader;
@property (nonatomic, strong) UADSTransactionObserver* transactionObserver;
@property (nonatomic, strong) SKPaymentQueue* queue;
@end


@implementation USTRStore

static USTRAppSheet *appSheet = NULL;

+ (instancetype)newWithProductReader:(id<UADSSKProductReader>)productsReader
                    andReceiptReader:(id<UADSAppStoreReceiptReader>)receiptReader {

    USTRStore *obj = [[self alloc] init];
    obj.receiptReader = receiptReader;
    obj.queue = SKPaymentQueue.defaultQueue;
    obj.productsReader = productsReader;
    return obj;
}

+ (USTRAppSheet *)appSheet {
    if (!appSheet) {
        appSheet = [[USTRAppSheet alloc] init];
    }
    
    return appSheet;
}

+(instancetype)sharedInstance {
    static USTRStore *sharedStoreKit = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UADSAppStoreReceiptReaderImp *defaultReceiptReader =  [UADSAppStoreReceiptReaderImp new];
        UADSSKProductReaderImp *productsReader = [UADSSKProductReaderImp new];
        sharedStoreKit = [USTRStore newWithProductReader: productsReader
                                        andReceiptReader: defaultReceiptReader];
    });
    return sharedStoreKit;
}

- (void)startTransactionObserverWithCompletion: (UADSTransactionObserverCompletion) completion {
    GUARD(!self.transactionObserver)

    _transactionObserver = [UADSTransactionObserver newWithReceiptReader:_receiptReader
                                                           andCompletion: completion];
    [_queue addTransactionObserver: _transactionObserver];
}

- (void)stopTransactionObserver {
    GUARD(self.transactionObserver)
    [_queue removeTransactionObserver: _transactionObserver];
    self.transactionObserver = nil;
}

- (void)getProductsUsingIDs: (NSArray<NSString *> *)productIDs
                    success: (USTRStoreProductsCompletion)completion
                    onError: (UADSSKProductReaderErrorCompletion)onError {
    
    [_productsReader fetchProductsUsingIDS: productIDs
                                completion: ^(NSArray<SKProduct *> * _Nonnull products) {
        
        NSArray *arrayOfDictionaries = [products uads_mapObjectsUsingBlock:^id _Nonnull(SKProduct *  _Nonnull obj) {
            return [SKProductBridge getProxyWithObject: obj].uads_Dictionary;
        }];
        completion(arrayOfDictionaries);
        
    } onErrorCompletion:onError];
}

- (NSString *)encodedReceipt {
    return _receiptReader.encodedReceipt;
}


@end
