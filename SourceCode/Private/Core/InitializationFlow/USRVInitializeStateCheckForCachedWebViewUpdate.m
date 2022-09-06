#import "USRVInitializeStateCheckForCachedWebViewUpdate.h"
#import "USRVSdkProperties.h"
#import "USRVInitializeStateUpdateCache.h"
#import "USRVInitializeStateDownloadLatestWebView.h"
#import "NSString+Hash.h"

@implementation USRVInitializeStateCheckForCachedWebViewUpdate : USRVInitializeState

- (instancetype)execute {
    // check to see if we have data in webview
    NSData *fileData = [NSData dataWithContentsOfFile: [USRVSdkProperties getLocalWebViewFile]
                                              options: NSDataReadingUncached
                                                error: nil];
    NSString *fileString = [[NSString alloc] initWithBytesNoCopy: (void *)[fileData bytes]
                                                          length: [fileData length]
                                                        encoding: NSUTF8StringEncoding
                                                    freeWhenDone: NO];
    NSString *localWebViewHash = [fileString uads_sha256];

    if ([localWebViewHash isEqualToString: self.configuration.webViewHash]) {
        id nextState = [[USRVInitializeStateUpdateCache alloc] initWithConfiguration: self.configuration];
        return nextState;
    } else {
        id nextState = [[USRVInitializeStateDownloadLatestWebView alloc] initWithConfiguration: self.configuration];
        return nextState;
    }
}

@end
