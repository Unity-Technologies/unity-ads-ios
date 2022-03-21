#import "UADSApiOverlay.h"
#import "UADSOverlay.h"
#import "USRVWebViewCallback.h"

@implementation UADSApiOverlay

+ (void)WebViewExposed_show: (NSDictionary *)parameters callback: (USRVWebViewCallback *)callback {
    [[UADSOverlay sharedInstance] show: parameters];

    [callback invoke: nil];
}

+ (void)WebViewExposed_hide: (USRVWebViewCallback *)callback {
    [[UADSOverlay sharedInstance] hide];
    [callback invoke: nil];
}

@end
