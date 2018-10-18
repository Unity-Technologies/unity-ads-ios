#import "UADSPlacement.h"
#import "USRVWebViewApp.h"

static NSString *defaultPlacement;
static NSString *defaultBannerPlacement;

static NSMutableDictionary *placementStateDictionary;

@implementation UADSPlacement

+ (BOOL)isReady: (NSString *) placement {
    return [self getPlacementState:placement] == kUnityAdsPlacementStateReady;
}

+ (BOOL)isReady {
    return self.getPlacementState == kUnityAdsPlacementStateReady;
}

+ (void)setDefaultPlacement:(NSString *)placement {
    defaultPlacement = placement;
}

+ (NSString *)getDefaultPlacement {
    return defaultPlacement;
}

+ (void)setDefaultBannerPlacement:(NSString *)placement {
    defaultBannerPlacement = placement;
}

+ (NSString *)getDefaultBannerPlacement {
    return defaultBannerPlacement;
}

+ (void)setPlacementState:(NSString *)placement placementState:(NSString *)placementState {
    if (!placementStateDictionary) {
        placementStateDictionary = [[NSMutableDictionary alloc] init];
    }
    
    [placementStateDictionary setObject:placementState forKey:placement];
}

+ (UnityAdsPlacementState)getPlacementState {
    if (!defaultPlacement) {
        return kUnityAdsPlacementStateNotAvailable;
    }
    
    return [self currentState:defaultPlacement];
}

+ (UnityAdsPlacementState)getPlacementState:(NSString *)placement {
    return [self currentState:placement];
}

+ (void)reset {
    defaultPlacement = nil;
    defaultBannerPlacement = nil;
    placementStateDictionary = nil;
}

+ (UnityAdsPlacementState)currentState:(NSString *)placement {
    if (!placementStateDictionary || ![placementStateDictionary valueForKey:placement]) {
        return kUnityAdsPlacementStateNotAvailable;
    }
    return [self formatStringToPlacementState:[placementStateDictionary valueForKey:placement]];
}

+ (UnityAdsPlacementState)formatStringToPlacementState:(NSString *)placementState {
    UnityAdsPlacementState state = kUnityAdsPlacementStateNotAvailable;
    
    if ([placementState isEqualToString:@"READY"]) {
        return kUnityAdsPlacementStateReady;
    } else if ([placementState isEqualToString:@"NOT_AVAILABLE"]) {
        return kUnityAdsPlacementStateNotAvailable;
    } else if ([placementState isEqualToString:@"DISABLED"]) {
        return kUnityAdsPlacementStateDisabled;
    } else if ([placementState isEqualToString:@"WAITING"]) {
        return kUnityAdsPlacementStateWaiting;
    } else if ([placementState isEqualToString:@"NO_FILL"]) {
        return kUnityAdsPlacementStateNoFill;
    }
    
    return state;
}

@end
