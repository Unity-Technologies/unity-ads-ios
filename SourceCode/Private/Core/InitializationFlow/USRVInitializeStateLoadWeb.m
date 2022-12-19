#import "USRVInitializeStateLoadWeb.h"
#import "USRVWebRequestFactory.h"
#import "USRVSdkProperties.h"
#import "UADSServiceProviderProxy.h"
#import "NSString+Hash.h"
#import "USRVInitializeStateCreate.h"
#import "USRVInitializeStateError.h"
#import "USRVInitializeStateRetry.h"
#import "USRVInitializeStateNetworkError.h"
#import "UADSServiceProvider.h"

@interface USRVInitializeStateLoadWeb ()

@property (nonatomic, assign) bool useNewDownloadNetwork;

@end

@implementation USRVInitializeStateLoadWeb : USRVInitializeState

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration retries: (int)retries retryDelay: (long)retryDelay {
    self = [super initWithConfiguration: configuration];
    
    if (self) {
        self.useNewDownloadNetwork = configuration.experiments.isSwiftDownloadEnabled;
        [self setRetries: retries];
        [self setRetryDelay: retryDelay];
        if (self.useNewDownloadNetwork) {
            self.networkLayer = UADSServiceProvider.sharedInstance.objBridge.nativeNetworkLayer;
        }
    }
    
    return self;
}

- (instancetype)execute {
    return self.useNewDownloadNetwork ? [self new_implementation] : [self old_implementation];
} /* execute */

- (instancetype)old_implementation {
    NSString *urlString = [NSString stringWithFormat: @"%@", [self.configuration webViewUrl]];
    
    USRVLogInfo(@"Unity Ads init: loading webapp from %@", urlString);
    
    NSURL *candidateURL = [NSURL URLWithString: urlString];
    bool validUrl = (candidateURL && candidateURL.scheme && candidateURL.host);
    
    if (!validUrl) {
        id nextState = [[USRVInitializeStateError alloc] initWithConfiguration: self.configuration
                                                                  erroredState: self
                                                                          code: kUADSErrorStateMalformedWebviewRequest
                                                                       message: @"Malformed URL when attempting to obtain the webview html"];
        return nextState;
    }
    
    id<USRVWebRequest> webRequest = [USRVWebRequestFactory create: urlString
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
        id retryState = [[USRVInitializeStateLoadWeb alloc] initWithConfiguration: self.configuration
                                                                          retries: self.retries
                                                                       retryDelay: self.retryDelay];
        id nextState = [[USRVInitializeStateRetry alloc] initWithConfiguration: self.configuration
                                                                    retryState: retryState
                                                                    retryDelay: self.retryDelay];
        return nextState;
    } else if (webRequest.error) {
        id erroredState = [[USRVInitializeStateLoadWeb alloc] initWithConfiguration: self.configuration
                                                                            retries: self.retries
                                                                         retryDelay: self.retryDelay];
        id nextState = [[USRVInitializeStateNetworkError alloc] initWithConfiguration: self.configuration
                                                                         erroredState: erroredState
                                                                                 code: kUADSErrorStateNetworkWebviewRequest
                                                                              message: @"Network error while loading WebApp from internet, waiting for connection"];
        return nextState;
    }
    
    NSString *responseString = [[NSString alloc] initWithData: responseData
                                                     encoding: NSUTF8StringEncoding];
    NSString *webViewHash = [self.configuration webViewHash];
    
    if (webViewHash != nil && ![[responseString uads_sha256] isEqualToString: webViewHash]) {
        id nextState = [[USRVInitializeStateError alloc] initWithConfiguration: self.configuration
                                                                  erroredState: self
                                                                          code: kUADSErrorStateInvalidHash
                                                                       message: @"Webview hash did not match returned hash in configuration"];
        return nextState;
    }
    
    id nextState = [[USRVInitializeStateCreate alloc] initWithConfiguration: self.configuration
                                                                webViewData: responseString];
    
    return nextState;
}

- (instancetype)new_implementation {
    __block NSError *downloadError = NULL;
    __block NSURL *webViewURL = NULL;
    id success = ^(NSURL *url) {
        webViewURL = url;
    };

    id error = ^(NSError *error) {
        downloadError = error;
    };
    
    [self.networkLayer downloadWebView: success andError: error];
    
    if (downloadError) {
        return [self errorState];
    }
    
    NSError *readingError;
    NSString *responseString = [NSString stringWithContentsOfURL: webViewURL
                                                        encoding: NSUTF8StringEncoding
                                                           error: &readingError];
    
    if (readingError) {
        return [self errorState];
    }
    
    id nextState = [[USRVInitializeStateCreate alloc] initWithConfiguration: self.configuration
                                                                webViewData: responseString];
    
    return nextState;
}


- (void)processError: (NSError *)error
      withCompletion:(void (^)(void))completion
               error:(void (^)(NSError * _Nonnull))errorCompletion {
    id nextState = [[USRVInitializeStateError alloc] initWithConfiguration: self.configuration
                                                              erroredState: self
                                                                      code: kUADSErrorStateNetworkWebviewRequest
                                                                   message: @"Network error while loading WebApp from internet, waiting for connection"];
    [nextState startWithCompletion:completion error: errorCompletion];
}

- (instancetype)errorState {
    
    id nextState = [[USRVInitializeStateError alloc] initWithConfiguration: self.configuration
                                                              erroredState: self
                                                                      code: kUADSErrorStateNetworkWebviewRequest
                                                                   message: @"Network error while loading WebApp from internet, waiting for connection"];
    
    return nextState;
}

- (void)startWithCompletion:(void (^)(void))completion error:(void (^)(NSError * _Nonnull))error {
    USRVInitializeState *nextState = [self execute];
    if ([nextState isKindOfClass:[USRVInitializeStateCreate class]]) {
        completion();
    } else {
        [nextState startWithCompletion:completion error:error]; // error or retry states
    }
}

@end
