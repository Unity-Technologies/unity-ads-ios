#import "USRVInitializeStateCreate.h"
#import "USRVWebViewApp.h"
#import "USRVInitializeStateComplete.h"
#import "USRVInitializeStateError.h"

@implementation USRVInitializeStateCreate : USRVInitializeState
- (instancetype)execute {
    USRVLogDebug(@"Unity Ads init: creating webapp");

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

@end
