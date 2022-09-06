#import "USRVInitializeStateCleanCache.h"
#import "USRVSdkProperties.h"

@implementation USRVInitializeStateCleanCache : USRVInitializeState

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration nextState: (USRVInitializeState *)nextState {
    self = [super initWithConfiguration: configuration];

    if (self) {
        [self setNextState: nextState];
    }

    return self;
}

- (instancetype)execute {
    NSString *localConfigFilepath = [USRVSdkProperties getLocalConfigFilepath];
    NSString *localWebViewFilepath = [USRVSdkProperties getLocalWebViewFile];
    NSError *error = nil;

    if ([[NSFileManager defaultManager] fileExistsAtPath: localConfigFilepath]) {
        [[NSFileManager defaultManager] removeItemAtPath: localConfigFilepath
                                                   error: &error];

        if (error != nil) {
            USRVLogError(@"Unity Ads init: failed to delete file from cache: %@", localConfigFilepath)
            error = nil;
        }
    }

    if ([[NSFileManager defaultManager] fileExistsAtPath: localWebViewFilepath]) {
        [[NSFileManager defaultManager] removeItemAtPath: localWebViewFilepath
                                                   error: &error];

        if (error != nil) {
            USRVLogError(@"Unity Ads init: failed to delete file from cache: %@", localWebViewFilepath)
        }
    }

    return _nextState;
} /* execute */

@end
