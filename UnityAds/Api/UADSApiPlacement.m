#import "UADSApiPlacement.h"
#import "UADSWebViewApp.h"
#import "UADSPlacement.h"

@implementation UADSApiPlacement

+ (void)WebViewExposed_setDefaultPlacement:(NSString *)placement webViewCallback:(UADSWebViewCallback *)callback {
    [UADSPlacement setDefaultPlacement:placement];
 
    [callback invoke:nil];
}

+ (void)WebViewExposed_setPlacementState:(NSString *)placement placementState:(NSString *)placementState webViewCallback:(UADSWebViewCallback *)callback {
    [UADSPlacement setPlacementState:placement placementState:placementState];
    
    [callback invoke:nil];
}

@end
