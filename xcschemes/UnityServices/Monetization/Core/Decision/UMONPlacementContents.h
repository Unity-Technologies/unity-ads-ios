#import "UnityMonetizationPlacementContentState.h"
#import "UMONPlacementContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface UMONPlacementContents : NSObject
+(nullable UMONPlacementContent *)getPlacementContent:(NSString *)placementId;

+(UMONPlacementContent *)putPlacementContent:(NSString *)placementId withPlacementContent:(UMONPlacementContent *)placementContent;

+(BOOL)isReady:(NSString *)placementId;

+(void)removePlacementContent:(NSString *)placementId;

+(void)setPlacementContentState:(NSString *)placementId withPlacementContentState:(UnityMonetizationPlacementContentState)state;
@end

NS_ASSUME_NONNULL_END
