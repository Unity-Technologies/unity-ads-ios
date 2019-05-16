#import "USRVApiWebAuth.h"
#import "USRVWebViewCallback.h"
#import "USRVASWebAuthenticationSessionManager.h"
#import "USRVWebAuthSession.h"

@implementation USRVApiWebAuth

+ (void)WebViewExposed_createSession:(NSString *)authUrlString callbackUrlSchemeString:(NSString *)callbackUrlSchemeString callback:(USRVWebViewCallback *)callback {
    if (authUrlString && ![authUrlString isKindOfClass:[NSNull class]] && callbackUrlSchemeString && ![callbackUrlSchemeString isKindOfClass:[NSNull class]]) {
        NSURL *authUrl = [[NSURL alloc] initWithString:authUrlString];
        if (authUrl) {
            USRVASWebAuthenticationSession *session = [[USRVASWebAuthenticationSessionManager sharedInstance] createSession:authUrl callbackUrlScheme:callbackUrlSchemeString];
            [callback invoke:[session getSessionId], nil];
        } else {
            [callback error:[NSString stringWithFormat:@"Invalid authUrlString parameter [authUrlString : %@, callbackUrlSchemeString : %@]", authUrlString, callbackUrlSchemeString] arg1:nil];
        }
    } else {
        [callback error:[NSString stringWithFormat:@"Invalid parameters [authUrlString : %@, callbackUrlSchemeString : %@]", authUrlString, callbackUrlSchemeString] arg1:nil];
    }
}

+ (void)WebViewExposed_startSession:(NSString *)sessionId callback:(USRVWebViewCallback *)callback {
    [[USRVASWebAuthenticationSessionManager sharedInstance] startSession:sessionId callback:^(BOOL didStart){
        [USRVWebAuthSession sendStartSessionResult:sessionId didStart:didStart];
    }];
    [callback invoke: nil];
}

+ (void)WebViewExposed_cancelSession:(NSString *)sessionId callback:(USRVWebViewCallback *)callback {
    [[USRVASWebAuthenticationSessionManager sharedInstance] cancelSession:sessionId];
    [callback invoke:nil];
}

+ (void)WebViewExposed_removeSession:(NSString *)sessionId callback:(USRVWebViewCallback *)callback {
    [[USRVASWebAuthenticationSessionManager sharedInstance] removeSession:sessionId];
    [callback invoke:nil];
}

@end
