#import "UMONPromoAdPlacementContent.h"
#import "UMONPromoMetaDataUtilities.h"

@interface UMONPromoAdPlacementContent ()
@property(strong, nonatomic) UMONPromoMetaData *metadata;
@end

@implementation UMONPromoAdPlacementContent
-(instancetype)initWithPlacementId:(NSString *)placementId withParams:(NSDictionary *)params {
    if (self = [super initWithPlacementId:placementId withParams:params]) {
        self.metadata = [UMONPromoMetaDataUtilities createPromoMetadataFromParamsMap:params];
    }
    return self;
}
-(NSString*)defaultEventCategory {
    return @"PROMO";
}
@end
