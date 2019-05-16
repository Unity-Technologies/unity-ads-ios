#import "USRVUnityPurchasingDelegate.h"
#import "UPURClientProperties.h"
#import "UPURApiCustomPurchasing.h"
#import "USRVWebViewCallback.h"
#import "UPURPurchasingError.h"
#import "USRVWebViewApp.h"
#import "UPURWebViewEventCategory.h"
#import "UPURPurchasingEvent.h"
#import "UPURTransactionDetails+JsonAdditions.h"
#import "UPURTransactionErrorDetails+JsonAdditions.h"

@implementation UPURProduct (JsonAdditions)
-(NSDictionary *)getProductJSONDictionary {
    return @{
            @"productId": self.productId ? self.productId : [NSNull null],
            @"localizedPriceString": self.localizedPriceString ? self.localizedPriceString : [NSNull null],
            @"localizedTitle": self.localizedTitle ? self.localizedTitle : [NSNull null],
            @"isoCurrencyCode": self.isoCurrencyCode ? self.isoCurrencyCode : [NSNull null],
            @"localizedPrice": self.localizedPrice ? self.localizedPrice : [NSNull null],
            @"localizedDescription": self.localizedDescription ? self.localizedDescription : [NSNull null],
            @"productType": self.productType ? self.productType : [NSNull null]
    };
}
@end

NSArray<NSDictionary *> *getJSONArrayFromProductList(NSArray<UPURProduct *> *list) {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (id product in list) {
        @try {
            [array addObject:[product getProductJSONDictionary]];
        }
        @catch (NSException *exception) {
            USRVLogError(@"getJSONArrayFromProductList %@", [exception reason]);
        }
    }
    return [NSArray arrayWithArray:array];
}

@implementation UPURApiCustomPurchasing
+(void)WebViewExposed_available:(USRVWebViewCallback *)callback {
    id <USRVUnityPurchasingDelegate> adapter = [UPURClientProperties getDelegate];
    [callback invoke:@(adapter != nil), nil];
}
+(void)WebViewExposed_refreshCatalog:(USRVWebViewCallback *)callback {
    id <USRVUnityPurchasingDelegate> delegate = [UPURClientProperties getDelegate];
    if (delegate) {
        @try {
            [delegate loadProducts:^(NSArray<UPURProduct *> *products) {
                USRVWebViewApp *app = [USRVWebViewApp getCurrentApp];
                if (app) {
                    [app sendEvent:NSStringFromUPURPurchasingEvent(kUPURPurchasingEventProductsRetrieved)
                          category:NSStringFromUPURWebViewEventCategory(kUPURWebViewEventCategoryCustomPurchasing)
                            param1:getJSONArrayFromProductList(products), nil];
                }
            }];
            [callback invoke:nil];
        }
        @catch (NSException *exception) {
            [callback error:NSStringFromUPURPurchasingError(UPURPurchasingErrorRetrieveProductsError) arg1:nil, exception];
        }
    } else {
        [callback error:NSStringFromUPURPurchasingError(UPURPurchasingErrorRetrieveProductsError) arg1:nil];
    }
}
+(void)WebViewExposed_purchaseItem:(NSString *)productId withExtras:(NSDictionary*)extras withCallBack:(USRVWebViewCallback *)callback {
    id <USRVUnityPurchasingDelegate> adapter = [UPURClientProperties getDelegate];
    if (adapter) {
        UnityPurchasingTransactionCompletionHandler completionHandler = ^(UPURTransactionDetails *details) {
            USRVWebViewApp *app = [USRVWebViewApp getCurrentApp];

            if (details && app) {
                [app sendEvent:NSStringFromUPURPurchasingEvent(kUPURPurchasingEventTransactionComplete)
                      category:NSStringFromUPURWebViewEventCategory(kUPURWebViewEventCategoryCustomPurchasing)
                        param1:[details getJSONDictionary], nil];
            }
        };
        UnityPurchasingTransactionErrorHandler
         errorHandler = ^(UPURTransactionErrorDetails *details) {
            USRVWebViewApp *app = [USRVWebViewApp getCurrentApp];
            if (app) {
                [app sendEvent:NSStringFromUPURPurchasingEvent(kUPURPurchasingEventTransactionError)
                      category:NSStringFromUPURWebViewEventCategory(kUPURWebViewEventCategoryCustomPurchasing)
                        param1:[details getJSONDictionary], nil];
            }
        };

        if ([adapter respondsToSelector:@selector(purchaseProduct:completionHandler:errorHandler:userInfo:)]) {
            [adapter purchaseProduct:productId
                   completionHandler:completionHandler
                        errorHandler:errorHandler
                            userInfo:extras];
        }
        
    } else {
        [callback error:NSStringFromUPURPurchasingError(UPURPurchasingErrorPurchasingAdapterNull) arg1:nil];
    }
}
@end
