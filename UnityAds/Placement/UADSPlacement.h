#import "UnityAds.h"

@interface UADSPlacement : NSObject

+ (BOOL)isReady:(NSString *)placement;

+ (BOOL)isReady;

+ (void)setDefaultPlacement:(NSString *)placement;

+ (NSString *)getDefaultPlacement;

+ (void)setPlacementState:(NSString *)placement placementState:(NSString *)placementState;

+ (UnityAdsPlacementState)getPlacementState;

+ (UnityAdsPlacementState)getPlacementState: (NSString *)placement;

+ (void)reset;

@end
