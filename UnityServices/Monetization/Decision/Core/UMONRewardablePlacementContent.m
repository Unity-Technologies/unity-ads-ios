#import "UMONRewardablePlacementContent.h"

@implementation UMONRewardablePlacementContent
-(instancetype)initWithPlacementId:(NSString *)placementId params:(NSMutableDictionary *)params {
    if (self = [super initWithPlacementId:placementId withParams:params]) {
        if ([params valueForKey:@"rewarded"]) {
            self.rewarded = [[params valueForKey:@"rewarded"] boolValue];
        }
        if ([params valueForKey:@"rewardId"]) {
            self.rewardId = [params valueForKey:@"rewardId"];
        }
    }
    return self;
}
@end
