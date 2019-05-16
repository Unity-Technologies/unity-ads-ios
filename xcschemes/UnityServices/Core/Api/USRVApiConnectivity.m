#import "USRVApiConnectivity.h"
#import "USRVConnectivityMonitor.h"
#import "USRVWebViewCallback.h"

@implementation USRVApiConnectivity

+ (void)WebViewExposed_setConnectionMonitoring:(NSNumber *)monitoring callback:(USRVWebViewCallback *)callback {
    [USRVConnectivityMonitor setConnectionMonitoring:[monitoring boolValue]];
    [callback invoke:nil];
}

@end
