#import "USRVApiTrackingManager.h"
#import "USRVWebViewCallback.h"
#import "USRVTrackingManagerProxy.h"

@implementation USRVApiTrackingManager

+ (void)WebViewExposed_getTrackingAuthorizationStatus: (USRVWebViewCallback *)callback {
    NSUInteger status = [[USRVTrackingManagerProxy sharedInstance] trackingAuthorizationStatus];

    [callback invoke: [NSNumber numberWithUnsignedLong: status], nil];
}

+ (void)WebViewExposed_requestTrackingAuthorization: (USRVWebViewCallback *)callback {
    [[USRVTrackingManagerProxy sharedInstance] requestTrackingAuthorization];
    [callback invoke: nil];
}

+ (void)WebViewExposed_available: (USRVWebViewCallback *)callback {
    BOOL available = [[USRVTrackingManagerProxy sharedInstance] available];

    [callback invoke: [NSNumber numberWithBool: available], nil];
}

@end
