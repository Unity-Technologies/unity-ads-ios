#import "USRVApiRequest.h"
#import "USRVWebViewCallback.h"
#import "USRVWebRequestQueue.h"
#import "USRVWebViewApp.h"
#import "USRVWebRequestError.h"
#import "USRVWebRequestEvent.h"
#import "UADSServiceProviderProxy.h"
#import "NSMutableDictionary+SafeOperations.h"
#import "UADSServiceProviderProxy.h"
#import "UADSBaseOptions.h"
#import "UADSCommonNetworkErrorProxy.h"
#import "UADSCorePresenceChecker.h"
#import "NSDictionary+Headers.h"

@implementation USRVApiRequest
static NSString *webRequestEventCategory = @"REQUEST";

+ (USRVWebViewApp *)eventSender {
    return [USRVWebViewApp getCurrentApp];
}

+ (void)WebViewExposed_supportsURLSession: (USRVWebViewCallback *)callback {
    [callback invoke: [NSNumber numberWithBool: UADSCorePresenceChecker.isPresent], nil];
}

+ (void)WebViewExposed_get: (NSString *)requestId url: (NSString *)url headers: (NSArray *)headers connectTimeout: (NSNumber *)connectTimeout callback: (USRVWebViewCallback *)callback {
    if (headers && headers.count == 0) {
        headers = NULL;
    }

    UnityServicesWebRequestCompletion completeBlock = ^(NSString *url, NSError *error, NSString *response, long responseCode, NSDictionary<NSString *, NSString *> *headers) {
        if (!error) {
            [USRVApiRequest sendSuccess: requestId
                                    url: url
                               response: response
                           responseCode: responseCode
                                headers: headers];
        } else {
            [USRVApiRequest sendFailed: requestId
                                   url: url
                                 error: error];
        }
    };

    NSDictionary *mappedHeaders = [NSDictionary uads_getHeadersMap: headers];

    if (!mappedHeaders) {
        [callback error: USRVNSStringFromWebRequestError(kUnityServicesWebRequestErrorMappingHeadersFailed)
                   arg1: nil];
        return;
    }

    [USRVWebRequestQueue requestUrl: url
                               type: @"GET"
                            headers: mappedHeaders
                      completeBlock: completeBlock
                     connectTimeout: [connectTimeout intValue]];
    [callback invoke: requestId, nil];
} /* WebViewExposed_get */

+ (void)WebViewExposed_head: (NSString *)requestId url: (NSString *)url headers: (NSArray *)headers connectTimeout: (NSNumber *)connectTimeout callback: (USRVWebViewCallback *)callback {
    if (headers && headers.count == 0) {
        headers = NULL;
    }

    UnityServicesWebRequestCompletion completeBlock = ^(NSString *url, NSError *error, NSString *response, long responseCode, NSDictionary<NSString *, NSString *> *headers) {
        if (!error) {
            [USRVApiRequest sendSuccess: requestId
                                    url: url
                               response: response
                           responseCode: responseCode
                                headers: headers];
        } else {
            [USRVApiRequest sendFailed: requestId
                                   url: url
                                 error: error];
        }
    };

    NSDictionary *mappedHeaders = [NSDictionary uads_getHeadersMap: headers];

    if (!mappedHeaders) {
        [callback error: USRVNSStringFromWebRequestError(kUnityServicesWebRequestErrorMappingHeadersFailed)
                   arg1: nil];
        return;
    }

    [USRVWebRequestQueue requestUrl: url
                               type: @"HEAD"
                            headers: mappedHeaders
                      completeBlock: completeBlock
                     connectTimeout: [connectTimeout intValue]];
    [callback invoke: requestId, nil];
} /* WebViewExposed_head */

+ (void)WebViewExposed_post: (NSString *)requestId url: (NSString *)url body: (NSString *)body headers: (NSArray *)headers connectTimeout: (NSNumber *)connectTimeout callback: (USRVWebViewCallback *)callback {
    if (headers && headers.count == 0) {
        headers = NULL;
    }

    UnityServicesWebRequestCompletion completeBlock = ^(NSString *url, NSError *error, NSString *response, long responseCode, NSDictionary<NSString *, NSString *> *headers) {
        if (!error) {
            [USRVApiRequest sendSuccess: requestId
                                    url: url
                               response: response
                           responseCode: responseCode
                                headers: headers];
        } else {
            [USRVApiRequest sendFailed: requestId
                                   url: url
                                 error: error];
        }
    };

    NSDictionary *mappedHeaders = [NSDictionary uads_getHeadersMap: headers];

    if (!mappedHeaders) {
        [callback error: USRVNSStringFromWebRequestError(kUnityServicesWebRequestErrorMappingHeadersFailed)
                   arg1: nil];
        return;
    }

    [USRVWebRequestQueue requestUrl: url
                               type: @"POST"
                            headers: mappedHeaders
                               body: body
                      completeBlock: completeBlock
                     connectTimeout: [connectTimeout intValue]];
    [callback invoke: requestId, nil];
} /* WebViewExposed_post */

+ (void)WebViewExposed_setConcurrentRequestCount: (NSNumber *)count callback: (USRVWebViewCallback *)callback {
    [USRVWebRequestQueue setConcurrentRequestCount: [count intValue]];
    [callback invoke: nil];
}

+ (void)sendSuccess: (NSString *)requestId url: (NSString *)url response: (NSString *)response responseCode: (long)responseCode headers: (NSDictionary<NSString *, NSString *> *)headers {
    NSArray<NSArray<NSString *> *> *responseHeaders = [NSDictionary uads_getHeadersArray: headers];

    if (!responseHeaders) {
        NSError *error = [NSError errorWithDomain: @"com.unity3d.ads.UnityServices.Error"
                                             code: kUnityServicesWebRequestGenericError
                                         userInfo: @{ @"code": [NSNumber numberWithLong: kUnityServicesWebRequestGenericError], @"message": @"Error parsing response headers" }];
        [USRVApiRequest sendFailed: requestId
                               url: url
                             error: error];
        return;
    }

    [[USRVWebViewApp getCurrentApp] sendEvent: USRVNSStringFromWebRequestEvent(kUnityServicesWebRequestEventComplete)
                                     category: webRequestEventCategory
                                       param1: requestId,
     url,
     response,
     [NSNumber numberWithLong: responseCode],
     responseHeaders,
     nil];
} /* sendSuccess */

+ (void)sendFailed: (NSString *)requestId url: (NSString *)url error: (NSError *)error {
    NSNumber *errorCode = 0;
    NSString *errorMessage = @"";

    if (error.userInfo) {
        if ([error.userInfo objectForKey: @"code"]) {
            errorCode = [error.userInfo objectForKey: @"code"];
        }

        if ([error.userInfo objectForKey: @"message"]) {
            errorMessage = [error.userInfo objectForKey: @"message"];
        }
    }

    [[USRVWebViewApp getCurrentApp] sendEvent: USRVNSStringFromWebRequestEvent(kUnityServicesWebRequestEventFailed)
                                     category: webRequestEventCategory
                                       param1: requestId,
     url,
     [NSString stringWithFormat: @"%@: %ld", errorMessage, [errorCode longValue]],
     nil];
} /* sendFailed */

+ (void)sendResponseToWebView: (NSDictionary *)dictionary
                     category: (UnityServicesWebRequestEvent)event {
    [self.eventSender sendEvent: USRVNSStringFromWebRequestEvent(event)
                       category: webRequestEventCategory
                         param1: dictionary, nil];
}

+ (void)WebViewExposed_sendRequest: (NSDictionary *)requestDictionary
                          callback: (USRVWebViewCallback *)callback {
    id errorCompletion = ^(NSDictionary *_Nonnull error) {
        [self sendResponseToWebView: error
                           category: kUnityServicesWebRequestEventFailed];
    };

    id successCompletion = ^(NSDictionary *_Nonnull response) {
        [self sendResponseToWebView: response
                           category: kUnityServicesWebRequestEventComplete];
    };


    [self.network sendRequestUsing: requestDictionary
                 successCompletion: successCompletion
                andErrorCompletion: errorCompletion];

    [callback invoke: requestDictionary[@"id"] ? : @"", nil];
}

+ (UADSCommonNetworkProxy *)network {
    return [UADSServiceProviderProxy shared].mainNetworkLayer;
}

@end
