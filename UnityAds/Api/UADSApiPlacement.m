#import "UADSApiPlacement.h"
#import "UADSWebViewApp.h"

static NSString *defaultPlacement;

static NSMutableDictionary *placementStateDictionary;
static NSMutableArray<NSString *> *placementAnalyticsSent;
static BOOL sendAnalyticsBool = NO;

@implementation UADSApiPlacement

+ (void)WebViewExposed_setDefaultPlacement:(NSString *)placement webViewCallback:(UADSWebViewCallback *)callback {
    defaultPlacement = placement;
    
    [callback invoke:nil];
}

+ (void)WebViewExposed_setPlacementState:(NSString *)placement placementState:(NSString *)placementState webViewCallback:(UADSWebViewCallback *)callback {
    if (!placementStateDictionary) {
        placementStateDictionary = [[NSMutableDictionary alloc] init];
    }
    
    if (!placementAnalyticsSent) {
        placementAnalyticsSent = [[NSMutableArray alloc] init];
    }
    
    if([placementAnalyticsSent containsObject:placement] ) {
        [placementAnalyticsSent removeObject:placement];
    }

    
    [placementStateDictionary setObject:placementState forKey:placement];
    
    [callback invoke:nil];
}

+ (void)WebViewExposed_setPlacementAnalytics:(BOOL)sendAnalytics webViewCallback:(UADSWebViewCallback *)callback {
    sendAnalyticsBool = sendAnalytics;
    
    [callback invoke:nil];
}

+ (BOOL)isReady: (NSString *) placement {
    return [self getPlacementState:placement] == kUnityAdsPlacementStateReady;
}

+ (BOOL)isReady {
    return self.getPlacementState == kUnityAdsPlacementStateReady;
}

+ (NSString *)getDefaultPlacement {
    return defaultPlacement;
}

+ (UnityAdsPlacementState)getPlacementState {
    if (!defaultPlacement) {
        return kUnityAdsPlacementStateNotAvailable;
    }
    
    return [self currentState:defaultPlacement];
}

+ (UnityAdsPlacementState)getPlacementState:(NSString *)placement {
    UnityAdsPlacementState state = [self currentState:placement];

    if (sendAnalyticsBool && placementAnalyticsSent && ![placementAnalyticsSent containsObject:placement]) {
        [placementAnalyticsSent addObject:placement];
        NSArray *params = @[placement, [placementStateDictionary valueForKey:placement]];
        [[UADSWebViewApp getCurrentApp] invokeMethod:@"webview" className:@"placementAnalytics" receiverClass:nil callback:nil params:params];
    }
    
    return state;
}

+ (void)reset {
    defaultPlacement = nil;
    placementStateDictionary = nil;
    placementAnalyticsSent = nil;
    sendAnalyticsBool = NO;
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
