#import "UMONNotAvailablePlacementContent.h"

@implementation UMONNotAvailablePlacementContent
-(BOOL)isReady {
    return NO;
}

-(void)sendCustomEvent:(UMONCustomEvent*)customEvent {
    // no-op
}

-(UnityMonetizationPlacementContentState)getState {
    return kPlacementContentStateNotAvailable;
}
@end
