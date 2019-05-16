#import "UMONWebViewEventCategory.h"

static NSString *webviewEventCategoryPlacementContent = @"PLACEMENT_CONTENT";
static NSString *webviewEventCategoryCustomPurchasing = @"CUSTOM_PURCHASING";

NSString *NSStringFromMonetizationWebViewEventCategory(UMONWebViewEventCategory category) {
    switch (category) {
        case kWebViewEventCategoryPlacementContent:
            return webviewEventCategoryPlacementContent;
        case kWebViewEventCategoryCustomPurchasing:
            return webviewEventCategoryCustomPurchasing;
        default:
            return nil;
    }
}
