#import "UADSLoadBridge.h"
#import "UADSLoadBridgeEvent.h"
#import "USRVWebViewApp.h"
#import "USRVWebviewEventCategory.h"

@implementation UADSLoadBridge

-(void)loadPlacements:(NSDictionary<NSString *, NSNumber *> *)placements {
    if ([USRVWebViewApp getCurrentApp]) {
        [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromUADSLoadBridgeEvent(UADSLoadEventLoadPlacements) category:USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryLoadApi) params:@[placements]];
    } else {
        USRVLogError(@"Load postEvent failed - No webapp available");
    }
}

@end
