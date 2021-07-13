#import "UADSApiToken.h"
#import "USRVWebViewCallback.h"
#import "UADSTokenStorage.h"

@implementation UADSApiToken

+ (void)WebViewExposed_createTokens: (NSArray *)tokens callback: (USRVWebViewCallback *)callback {
    [[UADSTokenStorage sharedInstance] createTokens: tokens];
    [callback invoke: nil];
}

+ (void)WebViewExposed_appendTokens: (NSArray *)tokens callback: (USRVWebViewCallback *)callback {
    [[UADSTokenStorage sharedInstance] appendTokens: tokens];
    [callback invoke: nil];
}

+ (void)WebViewExposed_deleteTokens: (USRVWebViewCallback *)callback {
    [[UADSTokenStorage sharedInstance] deleteTokens];
    [callback invoke: nil];
}

+ (void)WebViewExposed_setPeekMode: (NSNumber *)value callback: (USRVWebViewCallback *)callback {
    [[UADSTokenStorage sharedInstance] setPeekMode: [value boolValue]];
    [callback invoke: nil];
}

@end
