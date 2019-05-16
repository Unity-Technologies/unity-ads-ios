#import "USTRApiProducts.h"
#import "USRVWebViewCallback.h"
#import "USTRStore.h"

@implementation USTRApiProducts

+ (void)WebViewExposed_requestProductInfos:(NSArray *)productIds requestId:(NSNumber *)requestId callback:(USRVWebViewCallback *)callback {
    [USTRStore requestProductInfos:productIds requestId:requestId];
    [callback invoke:nil];
}

+ (void)WebViewExposed_startTransactionObserver:(USRVWebViewCallback *)callback {
    [USTRStore startTransactionObserver];
    [callback invoke:nil];
}

+ (void)WebViewExposed_stopTransactionObserver:(USRVWebViewCallback *)callback {
    [USTRStore stopTransactionObserver];
    [callback invoke:nil];
}

+ (void)WebViewExposed_getReceipt:(USRVWebViewCallback *)callback {
    NSData* receipt = [USTRStore getReceipt];
    if (receipt) {
        NSString *encodedReceipt = [receipt base64EncodedStringWithOptions:0];
        [callback invoke:encodedReceipt, nil];
    }
    else {
        [callback error:@"NO_RECEIPT" arg1:nil];
    }
}

@end
