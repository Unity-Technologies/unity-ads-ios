#import "UMONPlacementContentEvent.h"

static NSString *placementContentEventCustom = @"CUSTOM";

NSString *NSStringFromPlacementContentEvent(UMONPlacementContentEvent error) {
    switch (error) {
        case kPlacementContentEventCustom:
            return placementContentEventCustom;
    }
}
