#import "UANAWebViewEventCategory.h"

NSString *NSStringFromUANAWebViewEventCategory(UANAWebViewEventCategory category) {
    switch (category) {
        case kWebViewEventCategoryAnalytics:
            return @"ANALYTICS";
    }
}
