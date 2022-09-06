#import "USRVInitializeStateDownloadLatestWebView.h"
#import "USRVWebRequestFactory.h"
#import "USRVInitializeStateRetry.h"
#import "USRVSdkProperties.h"
#import "USRVInitializeStateUpdateCache.h"
#import "NSString+Hash.h"

@implementation USRVInitializeStateDownloadLatestWebView : USRVInitializeState

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration retries: (int)retries retryDelay: (long)retryDelay {
    self = [super initWithConfiguration: configuration];

    if (self) {
        [self setRetries: retries];
        [self setRetryDelay: retryDelay];
    }

    return self;
}

- (instancetype)execute {
    NSString *urlString = [NSString stringWithFormat: @"%@", [self.configuration webViewUrl]];

    USRVLogInfo(@"Unity Ads init: loading webapp from %@", urlString);

    NSURL *candidateURL = [NSURL URLWithString: urlString];
    bool validUrl = (candidateURL && candidateURL.scheme && candidateURL.host);

    if (!validUrl) {
        return NULL;
    }

    id<USRVWebRequest> webRequest = [[USRVWebRequestFactory new] create: urlString
                                                            requestType: @"GET"
                                                                headers: NULL
                                                         connectTimeout: 30000];
    NSData *responseData = [webRequest makeRequest];

    if (!webRequest.error) {
        [responseData writeToFile: [USRVSdkProperties getLocalWebViewFile]
                       atomically: YES];
    } else if (webRequest.error && self.retries < [self.configuration maxRetries]) {
        self.retryDelay = self.retryDelay * [self.configuration retryScalingFactor];
        self.retries++;
        id retryState = [[USRVInitializeStateDownloadLatestWebView alloc] initWithConfiguration: self.configuration
                                                                                        retries: self.retries
                                                                                     retryDelay: self.retryDelay];
        id nextState = [[USRVInitializeStateRetry alloc] initWithConfiguration: self.configuration
                                                                    retryState: retryState
                                                                    retryDelay: self.retryDelay];
        return nextState;
    } else if (webRequest.error) {
        return NULL;
    }

    NSString *responseString = [[NSString alloc] initWithData: responseData
                                                     encoding: NSUTF8StringEncoding];

    NSString *webViewHash = [self.configuration webViewHash];

    if (webViewHash != nil && ![[responseString uads_sha256] isEqualToString: webViewHash]) {
        return NULL;
    }

    id nextState = [[USRVInitializeStateUpdateCache alloc] initWithConfiguration: self.configuration
                                                                     webViewData: responseString];

    return nextState;
} /* execute */

@end
