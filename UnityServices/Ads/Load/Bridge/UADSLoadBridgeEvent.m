#import "UADSLoadBridgeEvent.h"

NSString *loadPlacements = @"LOAD_PLACEMENTS";

NSString *NSStringFromUADSLoadBridgeEvent(UADSLoadBridgeEvent event) {
    switch (event) {
        case UADSLoadEventLoadPlacements:
            return loadPlacements;
        default:
            return @"";
    }
}
