#import "USRVInitializeStateCheckForUpdatedWebView.h"
#import "USRVSdkProperties.h"
#import "USRVInitializeStateCreate.h"
#import "USRVInitializeStateLoadWeb.h"
#import <CommonCrypto/CommonDigest.h>
#import <sys/mman.h>

@implementation USRVInitializeStateCheckForUpdatedWebView : USRVInitializeState

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration localConfiguration: (USRVConfiguration *)localConfiguration {
    self = [super initWithConfiguration: configuration];

    if (self) {
        [self setLocalWebViewConfiguration: localConfiguration];
    }

    return self;
}

- (instancetype)execute {
    NSString *localWebViewHash = [self getHashFromFile: [USRVSdkProperties getLocalWebViewFile]];

    if (![localWebViewHash isEqualToString: self.configuration.webViewHash]) {
        [USRVSdkProperties setLatestConfiguration: self.configuration];
    }

    // Prepare to load the WebView from cache.  We will first see if there is cached config to use to load with our cached webViewData
    // If there is no cached config, or its invalid, we will next attempt to use the downloaded config to load with the cached webViewData
    // If both of those options fail, we will attempt to clean whatever garbage is in the cache and load from web.
    if (localWebViewHash != nil && ![localWebViewHash isEqualToString: @""]) {
        if (_localWebViewConfiguration != NULL && [localWebViewHash isEqualToString: _localWebViewConfiguration.webViewHash] && [[USRVSdkProperties getVersionName] isEqualToString: _localWebViewConfiguration.sdkVersion]) {
            id nextState = [[USRVInitializeStateCreate alloc] initWithConfiguration: _localWebViewConfiguration
                                                                        webViewData: @""];
            return nextState;
        } else if (self.configuration != NULL && [localWebViewHash isEqualToString: self.configuration.webViewHash]) {
            id nextState = [[USRVInitializeStateCreate alloc] initWithConfiguration: self.configuration
                                                                        webViewData: @""];
            return nextState;
        }
    }

    id nextState = [[USRVInitializeStateLoadWeb alloc] initWithConfiguration: self.configuration
                                                                     retries: 0
                                                                  retryDelay: [self.configuration retryDelay]];

    return nextState;
} /* execute */

- (NSString *)getHashFromFile: (NSString *)filepath {
    unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath: filepath
                                                                                    error: nil] fileSize];
    int fd = open([filepath UTF8String], O_RDONLY);

    if (fd == -1) {
        USRVLogWarning(@"Unity Ads init: unable to hash cached WebView data: Bad File Descriptor.  Initialization will continue");
        return @"";
    }

    char *buffer = mmap((caddr_t)0, fileSize, PROT_READ, MAP_SHARED, fd, 0);

    if (buffer == MAP_FAILED) {
        USRVLogWarning(@"Unity Ads init: unable to hash cached WebView data: Failed to allocate buffer.  Initialization will continue");
        close(fd);
        return @"";
    }

    unsigned char result[CC_SHA256_DIGEST_LENGTH];

    CC_SHA256(buffer, (CC_LONG)fileSize, result);
    munmap(buffer, fileSize);
    close(fd);

    NSMutableString *ret = [NSMutableString stringWithCapacity: CC_SHA256_DIGEST_LENGTH * 2];

    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [ret appendFormat: @"%02x", result[i]];
    }

    NSString *localWebViewHash = ret;

    return localWebViewHash;
} /* getHashFromFile */

@end
