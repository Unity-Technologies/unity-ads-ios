#import "UPURWebViewEventCategory.h"

NSString *NSStringFromUPURWebViewEventCategory(UPURWebViewEventCategory event) {
    switch (event) {
        case kUPURWebViewEventCategoryCustomPurchasing:
            return @"CUSTOM_PURCHASING";
    }
}
