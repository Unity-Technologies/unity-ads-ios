#import "UMONPlacementContent.h"

typedef NS_ENUM(NSInteger, UMONPlacementContentType) {
    kPlacementContentTypeShowAd,
    kPlacementContentTypePromoAd,
    kPlacementContentTypeCustom,
    kPlacementContentTypeNoFill
};

@interface UMONPlacementContentFactory : NSObject
+(UMONPlacementContent *)create:(NSString *)placementId withParams:(NSMutableDictionary *)params;
@end
