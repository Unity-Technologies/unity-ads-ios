#import "UADSApiToken.h"
#import "USRVWebViewCallback.h"
#import "UADSTokenStorage.h"
#import "UADSHeaderBiddingTokenReaderBuilder.h"

@implementation UADSApiToken

+ (void)WebViewExposed_createTokens: (NSArray *)tokens callback: (USRVWebViewCallback *)callback {
    [self.tokenStorage createTokens: tokens];
    [callback invoke: nil];
}

+ (void)WebViewExposed_appendTokens: (NSArray *)tokens callback: (USRVWebViewCallback *)callback {
    [self.tokenStorage appendTokens: tokens];
    [callback invoke: nil];
}

+ (void)WebViewExposed_deleteTokens: (USRVWebViewCallback *)callback {
    [self.tokenStorage deleteTokens];
    [callback invoke: nil];
}

+ (void)WebViewExposed_setPeekMode: (NSNumber *)value callback: (USRVWebViewCallback *)callback {
    [self.tokenStorage setPeekMode: [value boolValue]];
    [callback invoke: nil];
}

+ (id<UADSHeaderBiddingTokenCRUD>)tokenStorage {
    return UADSHeaderBiddingTokenReaderBuilder.sharedInstance.defaultReader;
}

@end
