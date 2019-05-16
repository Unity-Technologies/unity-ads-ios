#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, UMONWebViewEventCategory) {
    kWebViewEventCategoryPlacementContent,
    kWebViewEventCategoryCustomPurchasing
};

NSString *NSStringFromMonetizationWebViewEventCategory(UMONWebViewEventCategory);
