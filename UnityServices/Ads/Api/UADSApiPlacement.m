#import "UADSApiPlacement.h"
#import "USRVWebViewCallback.h"
#import "UADSPlacement.h"

@implementation UADSApiPlacement

+ (void)WebViewExposed_setDefaultBannerPlacement:(NSString *)placement webViewCallback:(USRVWebViewCallback *)callback {
    [UADSPlacement setDefaultBannerPlacement:placement];

    [callback invoke:nil];
}

+ (void)WebViewExposed_setDefaultPlacement:(NSString *)placement webViewCallback:(USRVWebViewCallback *)callback {
    [UADSPlacement setDefaultPlacement:placement];

    [callback invoke:nil];
}

+ (void)WebViewExposed_setPlacementState:(NSString *)placement placementState:(NSString *)placementState webViewCallback:(USRVWebViewCallback *)callback {
    [UADSPlacement setPlacementState:placement placementState:placementState];

    [callback invoke:nil];
}

@end
