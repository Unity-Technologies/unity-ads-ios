#import "UPURTransactionError.h"

NSString *NSStringFromUPURTransactionError(UPURTransactionError error) {
    switch (error) {
        case kUPURTransactionErrorNotSupported:
            return @"NOT_SUPPORTED";
        case kUPURTransactionErrorItemUnavailable:
            return @"ITEM_UNAVAILABLE";
        case kUPURTransactionErrorUserCancelled:
            return @"USER_CANCELLED";
        case kUPURTransactionErrorNetworkError:
            return @"NETWORK_ERROR";
        case kUPURTransactionErrorServerError:
            return @"SERVER_ERROR";
        case kUPURTransactionErrorUnknownError:
            return @"UNKNOWN_ERROR";
    }
}
