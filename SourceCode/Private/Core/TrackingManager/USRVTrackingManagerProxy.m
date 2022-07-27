#import <dlfcn.h>
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import "UADSTools.h"

#import "USRVDevice.h"
#import "USRVTrackingManagerProxy.h"
#import "USRVWebViewApp.h"

#import <AppTrackingTransparency/AppTrackingTransparency.h>

@interface USRVTrackingManagerProxy ()
@end

@implementation USRVTrackingManagerProxy

_uads_default_singleton_imp(USRVTrackingManagerProxy);

- (BOOL)available {
    if (@available(iOS 14, *)) {
        return [[NSBundle mainBundle] objectForInfoDictionaryKey: @"NSUserTrackingUsageDescription"] != nil;
    }

    return false;
}

- (void)requestTrackingAuthorization {
    if (!self.available) {
        return;
    }

    id handler = ^(NSUInteger result) {
        [[USRVWebViewApp getCurrentApp] sendEvent: @"TRACKING_AUTHORIZATION_RESPONSE"
                                         category: @"TRACKING_MANAGER"
                                           param1: [NSNumber numberWithUnsignedInteger: result], nil];
    };

    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler: handler];
    }
}

- (NSUInteger)trackingAuthorizationStatus {
    if (@available(iOS 14, *)) {
        return [ATTrackingManager trackingAuthorizationStatus];
    } else {
        return 0;
    }
}

@end
