#import "USTRApiProducts.h"
#import "USRVWebViewCallback.h"
#import "USTRStore.h"
#import "USRVWebViewApp.h"

NSString *const kPRODUCT_REQUEST_COMPLETE_EVENT_TYPE = @"PRODUCT_REQUEST_COMPLETE";
NSString *const kPRODUCT_REQUEST_FAILED_EVENT_TYPE = @"PRODUCT_REQUEST_FAILED";
NSString *const kTRANSACTION_RECEIVED_EVENT_TYPE = @"RECEIVED_TRANSACTION";
NSString *const kPRODUCT_REQUEST_NO_PRODUCTS_EVENT_TYPE = @"PRODUCT_REQUEST_ERROR_NO_PRODUCTS";
NSString *const kSTORE_EVENT_CATEGORY = @"STORE";
NSString *const kRECEIPT_ERROR_STRING = @"NO_RECEIPT";


@implementation USTRApiProducts

+(USTRStore *)facade {
    return USTRStore.sharedInstance;
}

+(USRVWebViewApp *)eventSender {
    return [USRVWebViewApp getCurrentApp];
}

+ (void)WebViewExposed_requestProductInfos:(NSArray *)productIds requestId:(NSNumber *)requestId callback:(USRVWebViewCallback *)callback {
    
    [self.facade getProductsUsingIDs:productIds success:^(NSArray<NSDictionary *> *products) {
        
        NSString *eventType = products.count > 0 ? kPRODUCT_REQUEST_COMPLETE_EVENT_TYPE : kPRODUCT_REQUEST_NO_PRODUCTS_EVENT_TYPE;
        
        [self.eventSender sendEvent: eventType
                           category: kSTORE_EVENT_CATEGORY
                             param1: requestId, products, nil];
    } onError:^(NSError * _Nonnull error) {
        
        [self.eventSender sendEvent: kPRODUCT_REQUEST_FAILED_EVENT_TYPE
                           category: kSTORE_EVENT_CATEGORY
                             param1: requestId, [error description], nil];
    }];
    
    [callback invoke:nil];
}

+ (void)WebViewExposed_startTransactionObserver:(USRVWebViewCallback *)callback {
    [self.facade startTransactionObserverWithCompletion:^(NSArray<NSDictionary *> * _Nonnull result) {
        [self.eventSender sendEvent: kTRANSACTION_RECEIVED_EVENT_TYPE
                           category: kSTORE_EVENT_CATEGORY
                             param1: result, nil];
    }];
    [callback invoke:nil];
}

+ (void)WebViewExposed_stopTransactionObserver:(USRVWebViewCallback *)callback {
    [self.facade stopTransactionObserver];
    [callback invoke:nil];
}

+ (void)WebViewExposed_getReceipt:(USRVWebViewCallback *)callback {
    NSString *encodedReceipt = self.facade.encodedReceipt;
    if (encodedReceipt) {
        [callback invoke: encodedReceipt, nil];
    }
    else {
        [callback error: kRECEIPT_ERROR_STRING arg1:nil];
    }
}

@end
