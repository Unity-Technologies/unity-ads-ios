@import CoreTelephony;

#import "USRVConnectivityMonitor.h"
#import "USRVWebViewApp.h"
#import "USRVWebViewEventCategory.h"
#import "USRVConnectivityUtils.h"

NSString *Connected = @"CONNECTED";
NSString *Disconnected = @"DISCONNECTED";
NSString *NetworkChange = @"NETWORK_CHANGE";


static NSMutableArray <id<USRVConnectivityDelegate>> *connectivityDelegates;
static BOOL webAppMonitoring = NO;
static BOOL listening = NO;

@implementation USRVConnectivityMonitor

static SCNetworkReachabilityRef reachabilityRef;

static void ReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) {
    if (flags & kSCNetworkReachabilityFlagsReachable) {
        for (id<USRVConnectivityDelegate> delegate in connectivityDelegates) {
            if (delegate != nil) {
                [delegate connected];
            }
        }
    } else {
        for (id<USRVConnectivityDelegate> delegate in connectivityDelegates) {
            if (delegate != nil) {
                [delegate disconnected];
            }
        }
    }
    
    [USRVConnectivityMonitor sendToWebview:target flags:flags];
}

+ (void)setConnectionMonitoring:(BOOL)status {
    webAppMonitoring = status;
    [self updateListeningStatus];
}

+ (void)startListening:(id<USRVConnectivityDelegate>)connectivityDelegate {
    if (!connectivityDelegates) {
        connectivityDelegates = [[NSMutableArray alloc]init];
    }
    [connectivityDelegates addObject:connectivityDelegate];
    
    [self updateListeningStatus];
}

+ (void)stopListening:(id<USRVConnectivityDelegate>)connectivitydelegate {
    if (connectivityDelegates) {
        [connectivityDelegates removeObject:connectivitydelegate];
    }
    [self updateListeningStatus];
}

+(void)stopAll {
    webAppMonitoring = NO;
    listening = NO;
    [connectivityDelegates removeAllObjects];
    
    [self updateListeningStatus];
}

+ (void)updateListeningStatus {
    if (webAppMonitoring || (connectivityDelegates && connectivityDelegates.count)) {
        [self startReachabilityListener];
    } else {
        [self stopReachabilityListener];
    }
}

+ (void) startReachabilityListener {
    if (listening) {
        return;
    }
    
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    reachabilityRef = SCNetworkReachabilityCreateWithAddress(NULL, (const struct sockaddr *)&zeroAddress);
    
    SCNetworkReachabilityContext context = {0, (__bridge void *)(self), NULL, NULL, NULL};
    
    if (SCNetworkReachabilitySetCallback(reachabilityRef, ReachabilityCallback, &context)) {
        if (SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode)) {
            listening = YES;
        }
    }
}

+ (void) stopReachabilityListener {
    listening = NO;
    if (reachabilityRef) {
        SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}

+ (void)dealloc {
    [self stopReachabilityListener];
    if (reachabilityRef != NULL) {
        CFRelease(reachabilityRef);
    }
}

+ (void)sendToWebview:(SCNetworkReachabilityRef)reachabilityRef flags:(SCNetworkReachabilityFlags)flags {
    if (!webAppMonitoring) {
        return;
    }
    
    USRVWebViewApp *webViewApp = [USRVWebViewApp getCurrentApp];
    if (!webViewApp) {
        return;
    }
    
    switch ([USRVConnectivityUtils networkStatusForFlags:flags]) {
        case NotReachable:
            [webViewApp sendEvent:Disconnected category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryConnectivity) param1:nil];
            break;
        case ReachableViaWiFi:
            [webViewApp sendEvent:Connected category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryConnectivity) param1:[NSNumber numberWithBool:TRUE], [NSNumber numberWithInt:0], nil];
            break;
        case ReachableViaWWAN:
            [webViewApp sendEvent:Connected category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryConnectivity) param1:[NSNumber numberWithBool:FALSE], [NSNumber numberWithInteger:[USRVConnectivityUtils getNetworkType]], nil];
            break;
        default:
            break;
    }
}

@end
