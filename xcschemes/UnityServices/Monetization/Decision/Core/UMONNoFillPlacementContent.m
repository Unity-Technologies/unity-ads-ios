#import "UMONNoFillPlacementContent.h"

@implementation UMONNoFillPlacementContent
-(BOOL)isReady {
    return NO;
}

-(void)sendCustomEvent:(UMONCustomEvent*)customEvent {
    // no-op
}

-(UnityMonetizationPlacementContentState)getState {
    return kPlacementContentStateNoFill;
}
@end
