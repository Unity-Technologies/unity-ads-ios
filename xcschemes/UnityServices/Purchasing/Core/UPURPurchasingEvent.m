#import "UPURPurchasingEvent.h"

NSString *NSStringFromUPURPurchasingEvent(UPURPurchasingEvent event) {
    switch (event) {
        case kUPURPurchasingEventProductsRetrieved:
            return @"PRODUCTS_RETRIEVED";
        case kUPURPurchasingEventTransactionComplete:
            return @"TRANSACTION_COMPLETE";
        case kUPURPurchasingEventTransactionError:
            return @"TRANSACTION_ERROR";
    }
}
