#import "USRVWebAuthSession.h"
#import "USRVWebViewApp.h"
#import "USRVWebViewEventCategory.h"

typedef NS_ENUM(NSInteger, USRVWebAuthSessionEvent) {
    USRVWebAuthSessionEventSessionResult,
    USRVWebAuthSessionEventStartSessionResult
};

NSString *NSStringFromUSRVWebAuthSessionEvent(USRVWebAuthSessionEvent event) {
    switch (event) {
        case USRVWebAuthSessionEventSessionResult:
            return @"SESSION_RESULT";
        case USRVWebAuthSessionEventStartSessionResult:
            return @"START_SESSION_RESULT";
        default:
            return @"UNKNOWN";
    }
};

@implementation USRVWebAuthSession

+ (void)sendSessionResult:(NSString *)sessionId callbackUrl:(NSURL * __nullable)callbackUrl error:(NSError * __nullable)error {
    USRVWebViewApp *webViewApp = [USRVWebViewApp getCurrentApp];
    if (webViewApp) {
        [webViewApp sendEvent:NSStringFromUSRVWebAuthSessionEvent(USRVWebAuthSessionEventSessionResult) category:USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryWebAuthSession) params:@[sessionId, callbackUrl ? [callbackUrl absoluteString] : [NSNull null], error ? [error description] : [NSNull null]]];
    }
}

+ (void)sendStartSessionResult:(NSString *)sessionId didStart:(BOOL)didStart {
    USRVWebViewApp *webViewApp = [USRVWebViewApp getCurrentApp];
    if (webViewApp) {
        [webViewApp sendEvent:NSStringFromUSRVWebAuthSessionEvent(USRVWebAuthSessionEventStartSessionResult) category:USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryWebAuthSession) params:@[sessionId, [NSNumber numberWithBool:didStart]]];
    }
}

@end
