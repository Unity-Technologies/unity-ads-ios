#import <objc/runtime.h>
#import <dlfcn.h>
#import "USTRStore.h"
#import "USRVDevice.h"
#import "USTRTransactionObserver.h"
#import "USTRProductRequest.h"

@implementation USTRStore

static USTRTransactionObserver *transactionObserver = NULL;
static USTRAppSheet *appSheet = NULL;

+ (USTRAppSheet *)appSheet {
    if (!appSheet) {
        appSheet = [[USTRAppSheet alloc] init];
    }
    
    return appSheet;
}

+ (void)startTransactionObserver {
    if (!transactionObserver) {
        transactionObserver = [[USTRTransactionObserver alloc] init];
        [[SKPaymentQueue defaultQueue] addTransactionObserver:transactionObserver];
    }
}

+ (void)stopTransactionObserver {
    if (transactionObserver) {
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:transactionObserver];
        transactionObserver = NULL;
    }
}

+ (void)requestProductInfos:(NSArray<NSString *>*)productIds requestId:(NSNumber *)requestId {
    USTRProductRequest *productRequest = [[USTRProductRequest alloc] initWithProductIds:productIds requestId:requestId];
    [productRequest requestProducts];
}

+ (NSData*)getReceipt {
    NSURL *receiptURL = [NSBundle bundleForClass:[self class]].appStoreReceiptURL;
    NSData *receipt = [NSData dataWithContentsOfURL:receiptURL];
    return receipt;
}

@end
