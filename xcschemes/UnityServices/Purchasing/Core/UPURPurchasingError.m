#import "UPURPurchasingError.h"

NSString *NSStringFromUPURPurchasingError(UPURPurchasingError error) {
    switch (error) {
        case UPURPurchasingErrorRetrieveProductsError:
            return @"UPURPurchasingErrorRetrieveProductsError";
        case UPURPurchasingErrorPurchasingAdapterNull:
            return @"UPURPurchasingErrorPurchasingAdapterNull";
    }
}
