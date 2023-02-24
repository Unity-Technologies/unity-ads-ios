#import "UADSApiToken.h"
#import "USRVWebViewCallback.h"
#import "UADSTokenStorage.h"
#import "UADSServiceProviderContainer.h"
#import "UADSWebViewEvent.h"

NSString *const kTokenEventName = @"TOKEN_NATIVE_DATA";
NSString *const kTokenCategoryName = @"TOKEN";

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

+ (void)WebViewExposed_getNativeGeneratedToken: (USRVWebViewCallback *)callback {
    [self.serviceProvider.nativeTokenGenerator getToken:^(UADSHeaderBiddingToken *_Nullable token) {
        UADSWebViewEventBase *event = [UADSWebViewEventBase newWithCategory: kTokenCategoryName
                                                                  withEvent: kTokenEventName
                                                                 withParams: @[token.value]];
        [self.webViewEventSender sendEvent: event];
    }];
    [callback invoke: nil];
}

+ (id<UADSHeaderBiddingTokenCRUD>)tokenStorage {
    return self.serviceProvider.hbTokenReader;
}

+ (UADSServiceProvider *)serviceProvider {
    return UADSServiceProviderContainer.sharedInstance.serviceProvider;
}

+ (id<UADSWebViewEventSender>)webViewEventSender {
    return self.serviceProvider.webViewEventSender;
}

@end
