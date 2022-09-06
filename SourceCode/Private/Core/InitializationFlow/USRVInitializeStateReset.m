#import "USRVInitializeStateReset.h"
#import "USRVCacheQueue.h"
#import "USRVWebRequestQueue.h"
#import "USRVWebViewApp.h"
#import "USRVModuleConfiguration.h"
#import "USRVInitializeStateInitModules.h"
#import "USRVInitializeStateError.h"

@implementation USRVInitializeStateReset : USRVInitializeState

- (instancetype)execute {
    [USRVCacheQueue start];
    [USRVWebRequestQueue start];
    USRVWebViewApp *currentWebViewApp = [USRVWebViewApp getCurrentApp];

    if (currentWebViewApp != NULL) {
        [currentWebViewApp resetWebViewAppInitialization];
        NSCondition *blockCondition = [[NSCondition alloc] init];
        [blockCondition lock];

        if ([currentWebViewApp webView] != NULL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([currentWebViewApp webView] && [[currentWebViewApp webView] superview]) {
                    [[currentWebViewApp webView] removeFromSuperview];
                }

                [currentWebViewApp setWebView: NULL];
                [blockCondition lock];
                [blockCondition signal];
                [blockCondition unlock];
            });
        }

        double resetWebAppTimeoutInSeconds = [self.configuration resetWebAppTimeout] / (double)1000;
        BOOL success = [blockCondition waitUntilDate: [[NSDate alloc] initWithTimeIntervalSinceNow: resetWebAppTimeoutInSeconds]];
        [blockCondition unlock];

        if (!success) {
            USRVLogError(@"Unity Ads init: dispatch async did not run through while resetting SDK");
            id nextState = [[USRVInitializeStateError alloc] initWithConfiguration: self.configuration
                                                                      erroredState: self
                                                                              code: kUADSErrorStateCreateWebview
                                                                           message: @"Failure to reset the webapp"];
            return nextState;
        }

        [USRVWebViewApp setCurrentApp: NULL];
    }

    for (NSString *moduleName in [self.configuration getModuleConfigurationList]) {
        USRVModuleConfiguration *moduleConfiguration = [self.configuration getModuleConfiguration: moduleName];

        if (moduleConfiguration) {
            [moduleConfiguration resetState: self.configuration];
        }
    }

    id nextState = [[USRVInitializeStateInitModules alloc] initWithConfiguration: self.configuration];

    return nextState;
} /* execute */

@end
