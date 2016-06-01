#import "UADSApiConnectivity.h"
#import "UADSConnectivityMonitor.h"
#import "UADSWebViewCallback.h"

@implementation UADSApiConnectivity

+ (void)WebViewExposed_setConnectionMonitoring:(NSNumber *)monitoring callback:(UADSWebViewCallback *)callback {
    [UADSConnectivityMonitor setConnectionMonitoring:[monitoring boolValue]];
    [callback invoke:nil];
}

@end
