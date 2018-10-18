#import "UnityMonetizationPlacementContentState.h"

static NSString *placementContentStateNoFill        = @"NO_FILL";
static NSString *placementContentStateReady         = @"READY";
static NSString *placementContentStateWaiting       = @"WAITING";
static NSString *placementContentStateNotAvailable  = @"NOT_AVAILABLE";
static NSString *placementContentStateDisabled      = @"DISABLED";

NSString* NSStringFromPlacementContentState(UnityMonetizationPlacementContentState state) {
    switch (state) {
        case kPlacementContentStateNoFill:
            return placementContentStateNoFill;
        case kPlacementContentStateNotAvailable:
            return placementContentStateNotAvailable;
        case kPlacementContentStateWaiting:
            return placementContentStateWaiting;
        case kPlacementContentStateDisabled:
            return placementContentStateDisabled;
        case kPlacementContentStateReady:
            return placementContentStateReady;
    }
}

UnityMonetizationPlacementContentState PlacementContentStateFromNSString(NSString *stateString) {
    if (stateString) {
        if ([stateString isEqualToString:placementContentStateNoFill]) {
            return kPlacementContentStateNoFill;
        } else if ([stateString isEqualToString:placementContentStateReady]) {
            return kPlacementContentStateReady;
        } else if ([stateString isEqualToString:placementContentStateWaiting]) {
            return kPlacementContentStateWaiting;
        } else if ([stateString isEqualToString:placementContentStateNotAvailable]) {
            return kPlacementContentStateNotAvailable;
        } else if ([stateString isEqualToString:placementContentStateDisabled]) {
            return kPlacementContentStateDisabled;
        }
    }
    return kPlacementContentStateNotAvailable;
}
