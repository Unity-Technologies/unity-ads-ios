#import "USRVInitializeStateCreate.h"
#import "USRVWebViewApp.h"
#import "USRVInitializeStateComplete.h"
#import "USRVInitializeStateError.h"

static BOOL isMocked = false;

@implementation USRVInitializeStateCreate : USRVInitializeState
+ (void)setMocked: (BOOL)isMockedValue {
    isMocked = isMockedValue;
}
- (instancetype)execute {
    USRVLogDebug(@"Unity Ads init: creating webapp");
    if (isMocked) {
        id nextState = [[USRVInitializeStateComplete alloc] initWithConfiguration: self.configuration];
        return nextState;
    }
   
    [self.configuration setWebViewData: [self webViewData]];
    NSNumber *errorState = [USRVWebViewApp create: self.configuration
                                             view: nil];

    if (!errorState) {
        id nextState = [[USRVInitializeStateComplete alloc] initWithConfiguration: self.configuration];
        return nextState;
    } else {
        id erroredState = [[USRVInitializeStateCreate alloc] init];
        NSString *errorMessage = @"Unity Ads WebApp creation failed";

        if ([[USRVWebViewApp getCurrentApp] getWebAppFailureMessage] != nil) {
            errorMessage = [[USRVWebViewApp getCurrentApp] getWebAppFailureMessage];
        }

        id nextState = [[USRVInitializeStateError alloc] initWithConfiguration: self.configuration
                                                                  erroredState: erroredState
                                                                          code: [errorState intValue]
                                                                       message: errorMessage];
        return nextState;
    }
} /* execute */

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration webViewData: (NSString *)webViewData {
    self = [super initWithConfiguration: configuration];

    if (self) {
        [self setWebViewData: webViewData];
    }

    return self;
}

- (void)startWithCompletion:(void (^)(void))completion error:(void (^)(NSError * _Nonnull))error {
    USRVLogDebug(@"Unity Ads init: creating webapp");
    if (isMocked) {
        completion();
        return;
    }

    [self.configuration setWebViewData: [self webViewData]];
    NSNumber *errorState = [USRVWebViewApp create: self.configuration
                                             view: nil];

    if (!errorState) {
        completion();
    } else {
        id erroredState = [[USRVInitializeStateCreate alloc] init];
        NSString *errorMessage = @"Unity Ads WebApp creation failed";

        if ([[USRVWebViewApp getCurrentApp] getWebAppFailureMessage] != nil) {
            errorMessage = [[USRVWebViewApp getCurrentApp] getWebAppFailureMessage];
        }

        id nextState = [[USRVInitializeStateError alloc] initWithConfiguration: self.configuration
                                                                  erroredState: erroredState
                                                                          code: [errorState intValue]
                                                                       message: errorMessage];
        [nextState startWithCompletion: completion error: error];
    }
}

@end
