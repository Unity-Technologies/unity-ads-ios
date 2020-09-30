#import "UADSApiLoad.h"
#import "USRVWebViewCallback.h"
#import "UADSLoadModule.h"

@implementation UADSApiLoad

+(void)WebViewExposed_sendAdLoaded:(NSString*)placementId listenerId:(NSString*)listenerId callback:(USRVWebViewCallback *)callback {
    [[UADSLoadModule sharedInstance] sendAdLoaded:placementId listenerId:listenerId];
    [callback invoke:nil];
}

+(void)WebViewExposed_sendAdFailedToLoad:(NSString*)placementId listenerId:(NSString*)listenerId callback:(USRVWebViewCallback *)callback {
    [[UADSLoadModule sharedInstance] sendAdFailedToLoad:placementId listenerId:listenerId];
    [callback invoke:nil];
}

@end
