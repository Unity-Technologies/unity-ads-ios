#import "UnityAds.h"

@interface UADSPlacement : NSObject

+ (BOOL)isReady:(NSString *)placement;

+ (BOOL)isReady;

+ (void)setDefaultPlacement:(NSString *)placement;
+ (NSString *)getDefaultPlacement;

+ (void)setDefaultBannerPlacement:(NSString *)placement;
+ (NSString *)getDefaultBannerPlacement;

+ (void)setPlacementState:(NSString *)placement placementState:(NSString *)placementState;

+ (UnityAdsPlacementState)getPlacementState;

+ (UnityAdsPlacementState)getPlacementState: (NSString *)placement;

+ (void)reset;

+ (UnityAdsPlacementState)formatStringToPlacementState:(NSString *)placementState;

@end
