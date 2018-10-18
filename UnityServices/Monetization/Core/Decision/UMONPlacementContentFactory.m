#import "UMONPlacementContentFactory.h"
#import "UMONShowAdPlacementContent.h"
#import "UMONPromoAdPlacementContent.h"
#import "UMONNoFillPlacementContent.h"

static NSString *placementContentTypeShowAd = @"SHOW_AD";
static NSString *placementContentTypePromoAd = @"PROMO_AD";
static NSString *placementContentTypeUndecided = @"UNDECIDED";

UMONPlacementContentType PlacementContentTypeFromNSString(NSString *type) {
    if (type) {
        if ([type isEqualToString:placementContentTypeShowAd]) {
            return kPlacementContentTypeShowAd;
        } else if ([type isEqualToString:placementContentTypePromoAd]) {
            return kPlacementContentTypePromoAd;
        } else if ([type isEqualToString:placementContentTypeUndecided]) {
            return kPlacementContentTypeNoFill;
        }
    }
    return kPlacementContentTypeCustom;
}

@implementation UMONPlacementContentFactory
+(UMONPlacementContent *)create:(NSString *)placementId withParams:(NSMutableDictionary *)params {
    NSString *typeString = [params valueForKey:@"type"];
    UMONPlacementContentType type = PlacementContentTypeFromNSString(typeString);

    switch (type) {
        case kPlacementContentTypeShowAd:
            return [[UMONShowAdPlacementContent alloc] initWithPlacementId:placementId withParams:params];
        case kPlacementContentTypePromoAd:
            return [[UMONPromoAdPlacementContent alloc] initWithPlacementId:placementId withParams:params];
        case kPlacementContentTypeNoFill:
            return [[UMONNoFillPlacementContent alloc] initWithPlacementId:placementId withParams:params];
        case kPlacementContentTypeCustom:
        default:
            return [[UMONPlacementContent alloc] initWithPlacementId:placementId withParams:params];
    }
}
@end
