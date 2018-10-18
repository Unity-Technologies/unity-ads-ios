#import "USRVApiResolve.h"
#import "USRVWebViewCallback.h"
#import "USRVWebRequestQueue.h"
#import "USRVWebViewApp.h"
#import "USRVResolveError.h"
#import "USRVResolveEvent.h"

@implementation USRVApiResolve

static NSString *resolveCategory = @"RESOLVE";

+ (void)WebViewExposed_resolve:(NSString *)resolveId hostName:(NSString *)hostName callback:(USRVWebViewCallback *)callback {
    UnityServicesResolveRequestCompletion completeBlock = ^(NSString *host, NSString *address, NSString *error, NSString *errorMessage) {
        USRVWebViewApp *webApp = [USRVWebViewApp getCurrentApp];

        if (!error && webApp) {
            [webApp sendEvent:NSStringFromResolveEvent(kUnityServicesResolveEventComplete) category:resolveCategory
                param1:resolveId,
                host,
                address,
             nil];
        }
        else if (webApp) {
            [webApp sendEvent:NSStringFromResolveEvent(kUnityServicesResolveEventFailed) category:resolveCategory
                param1:resolveId,
                host ? host : [NSNull null],
                error,
                errorMessage,
             nil];
        }
    };
    
    if ([USRVWebRequestQueue resolve:hostName completeBlock:completeBlock]) {
        [callback invoke:resolveId, nil];
    }
    else {
        [callback error:NSStringFromResolveError(kUnityServicesResolveErrorInvalidHost) arg1:resolveId, nil];
    }
}

@end
