#import "USRVInitializeStateUpdateCache.h"
#import "USRVSdkProperties.h"
@implementation USRVInitializeStateUpdateCache : USRVInitializeState

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration webViewData: (NSString *)localWebViewData {
    self = [super initWithConfiguration: configuration];

    if (self) {
        [self setLocalWebViewData: localWebViewData];
    }

    return self;
}

- (instancetype)execute {
    if (_localWebViewData != nil && ![_localWebViewData isEqualToString: @""]) {
        [_localWebViewData writeToFile: [USRVSdkProperties getLocalWebViewFile]
                            atomically: YES];
    }

    if (self.configuration != nil) {
        [[self.configuration toJson] writeToFile: [USRVSdkProperties getLocalConfigFilepath]
                                      atomically: YES];
    }

    return NULL;
}

@end
