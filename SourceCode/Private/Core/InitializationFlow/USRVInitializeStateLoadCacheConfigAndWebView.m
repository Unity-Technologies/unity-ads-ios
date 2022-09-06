#import "USRVInitializeStateLoadCacheConfigAndWebView.h"
#import "USRVSdkProperties.h"
#import "USRVInitializeStateCheckForUpdatedWebView.h"
#import "USRVInitializeStateLoadWeb.h"
#import "USRVInitializeStateCleanCache.h"

@implementation USRVInitializeStateLoadCacheConfigAndWebView : USRVInitializeState

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration localConfig: (USRVConfiguration *)localConfig {
    self = [super initWithConfiguration: configuration];

    if (self) {
        [self setLocalConfig: localConfig];
    }

    return self;
}

- (instancetype)execute {
    @try {
        if ([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalWebViewFile]]) {
            id nextState = [[USRVInitializeStateCheckForUpdatedWebView alloc] initWithConfiguration: self.configuration
                                                                                 localConfiguration: _localConfig];
            return nextState;
        }
    } @catch (NSException *exception) {
        // If we are unable to load cached webview data, then bail out, clean up whatever is in the cache, and load from the web
    }

    id loadWebState = [[USRVInitializeStateLoadWeb alloc] initWithConfiguration: self.configuration
                                                                        retries: 0
                                                                     retryDelay: [self.configuration retryDelay]];
    id nextState = [[USRVInitializeStateCleanCache alloc] initWithConfiguration: self.configuration
                                                                      nextState: loadWebState];

    return nextState;
}

@end
