#import "UADSApiResolve.h"
#import "UADSWebViewCallback.h"
#import "UADSWebRequestQueue.h"
#import "UADSWebViewApp.h"
#import "UADSResolveError.h"
#import "UADSResolveEvent.h"

@implementation UADSApiResolve

static NSString *resolveCategory = @"RESOLVE";

+ (void)WebViewExposed_resolve:(NSString *)resolveId hostName:(NSString *)hostName callback:(UADSWebViewCallback *)callback {
    UnityAdsResolveRequestCompletion completeBlock = ^(NSString *host, NSString *address, NSString *error, NSString *errorMessage) {
        UADSWebViewApp *webApp = [UADSWebViewApp getCurrentApp];

        if (!error && webApp) {
            [webApp sendEvent:NSStringFromResolveEvent(kUnityAdsResolveEventComplete) category:resolveCategory
                param1:resolveId,
                host,
                address,
             nil];
        }
        else if (webApp) {
            [webApp sendEvent:NSStringFromResolveEvent(kUnityAdsResolveEventFailed) category:resolveCategory
                param1:resolveId,
                host ? host : [NSNull null],
                error,
                errorMessage,
             nil];
        }
    };
    
    if ([UADSWebRequestQueue resolve:hostName completeBlock:completeBlock]) {
        [callback invoke:resolveId, nil];
    }
    else {
        [callback error:NSStringFromResolveError(kUnityAdsResolveErrorInvalidHost) arg1:resolveId, nil];
    }
}

@end
