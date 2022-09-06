#import "USRVInitializeStateLoadCache.h"
#import "USRVSdkProperties.h"
#import "NSString+Hash.h"
#import "USRVInitializeStateLoadWeb.h"
#import "USRVInitializeStateCreate.h"

@implementation USRVInitializeStateLoadCache : USRVInitializeState

- (instancetype)execute {
    NSString *localWebViewFile = [USRVSdkProperties getLocalWebViewFile];

    if ([[NSFileManager defaultManager] fileExistsAtPath: localWebViewFile]) {
        NSData *fileData = [NSData dataWithContentsOfFile: localWebViewFile
                                                  options: NSDataReadingUncached
                                                    error: nil];
        NSString *fileString = [[NSString alloc] initWithBytesNoCopy: (void *)[fileData bytes]
                                                              length: [fileData length]
                                                            encoding: NSUTF8StringEncoding
                                                        freeWhenDone: NO];
        NSString *localWebViewHash = [fileString uads_sha256];

        if (localWebViewHash && [localWebViewHash isEqualToString: self.configuration.webViewHash]) {
            USRVLogInfo(@"Unity Ads init: webapp loaded from local cache");
            id nextState = [[USRVInitializeStateCreate alloc] initWithConfiguration: self.configuration
                                                                        webViewData: fileString];
            return nextState;
        }
    }

    id nextState = [[USRVInitializeStateLoadWeb alloc] initWithConfiguration: self.configuration
                                                                     retries: 0
                                                                  retryDelay: [self.configuration retryDelay]];

    return nextState;
} /* execute */

@end
