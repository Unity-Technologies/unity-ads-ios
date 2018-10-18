#import "USRVApiRequest.h"
#import "USRVWebViewCallback.h"
#import "USRVWebRequestQueue.h"
#import "USRVWebViewApp.h"
#import "USRVWebRequestError.h"
#import "USRVWebRequestEvent.h"

@implementation USRVApiRequest

static NSString *webRequestEventCategory = @"REQUEST";

+ (void)WebViewExposed_get:(NSString *)requestId url:(NSString *)url headers:(NSArray *)headers connectTimeout:(NSNumber *)connectTimeout callback:(USRVWebViewCallback *)callback {
    if (headers && headers.count == 0) {
        headers = NULL;
    }

    UnityServicesWebRequestCompletion completeBlock = ^(NSString *url, NSError *error, NSString *response, long responseCode, NSDictionary<NSString*,NSString*> *headers) {
        if (!error) {
            [USRVApiRequest sendSuccess:requestId url:url response:response responseCode:responseCode headers:headers];
        }
        else {
            [USRVApiRequest sendFailed:requestId url:url error:error];
        }
    };

    NSDictionary *mappedHeaders = [USRVApiRequest getHeadersMap:headers];

    if (!mappedHeaders) {
        [callback error:NSStringFromWebRequestError(kUnityServicesWebRequestErrorMappingHeadersFailed) arg1:nil];
        return;
    }

    [USRVWebRequestQueue requestUrl:url type:@"GET" headers:mappedHeaders completeBlock:completeBlock connectTimeout:[connectTimeout intValue]];
    [callback invoke:requestId, nil];
}

+ (void)WebViewExposed_head:(NSString *)requestId url:(NSString *)url headers:(NSArray *)headers connectTimeout:(NSNumber *)connectTimeout callback:(USRVWebViewCallback *)callback {
    if (headers && headers.count == 0) {
        headers = NULL;
    }

    UnityServicesWebRequestCompletion completeBlock = ^(NSString *url, NSError *error, NSString *response, long responseCode, NSDictionary<NSString*,NSString*> *headers) {
        if (!error) {
            [USRVApiRequest sendSuccess:requestId url:url response:response responseCode:responseCode headers:headers];
        }
        else {
            [USRVApiRequest sendFailed:requestId url:url error:error];
        }
    };

    NSDictionary *mappedHeaders = [USRVApiRequest getHeadersMap:headers];

    if (!mappedHeaders) {
        [callback error:NSStringFromWebRequestError(kUnityServicesWebRequestErrorMappingHeadersFailed) arg1:nil];
        return;
    }

    [USRVWebRequestQueue requestUrl:url type:@"HEAD" headers:mappedHeaders completeBlock:completeBlock connectTimeout:[connectTimeout intValue]];
    [callback invoke:requestId, nil];
}

+ (void)WebViewExposed_post:(NSString *)requestId url:(NSString *)url body:(NSString *)body headers:(NSArray *)headers connectTimeout:(NSNumber *)connectTimeout callback:(USRVWebViewCallback *)callback {
    
    if (headers && headers.count == 0) {
        headers = NULL;
    }

    UnityServicesWebRequestCompletion completeBlock = ^(NSString *url, NSError *error, NSString *response, long responseCode, NSDictionary<NSString*,NSString*> *headers) {
        if (!error) {
            [USRVApiRequest sendSuccess:requestId url:url response:response responseCode:responseCode headers:headers];
        }
        else {
            [USRVApiRequest sendFailed:requestId url:url error:error];
        }
    };

    NSDictionary *mappedHeaders = [USRVApiRequest getHeadersMap:headers];

    if (!mappedHeaders) {
        [callback error:NSStringFromWebRequestError(kUnityServicesWebRequestErrorMappingHeadersFailed) arg1:nil];
        return;
    }

    [USRVWebRequestQueue requestUrl:url type:@"POST" headers:mappedHeaders body:body completeBlock:completeBlock connectTimeout:[connectTimeout intValue]];
    [callback invoke:requestId, nil];
}

+ (void)WebViewExposed_setConcurrentRequestCount: (NSNumber *) count callback:(USRVWebViewCallback *)callback {
    [USRVWebRequestQueue setConcurrentRequestCount: [count intValue]];
    [callback invoke:nil];
}

+ (NSDictionary<NSString*,NSArray*> *)getHeadersMap:(NSArray *)headers {
    NSMutableDictionary *mappedHeaders = [[NSMutableDictionary alloc] init];
    
    if (headers && headers.count > 0) {
        for (int idx = 0; idx < headers.count; idx++) {
            if (![[headers objectAtIndex:idx] isKindOfClass:[NSArray class]]) return NULL;

            NSArray *header = [headers objectAtIndex:idx];

            if ([header count] != 2) return NULL;
            if (![[header objectAtIndex:0] isKindOfClass:[NSString class]] || ![[header objectAtIndex:1] isKindOfClass:[NSString class]]) {
                return NULL;
            }

            NSString *headerKey = [header objectAtIndex:0];
            NSString *headerValue = [header objectAtIndex:1];

            if (headerKey.length < 1) return NULL;

            NSMutableArray *valueList = [[NSMutableArray alloc] initWithArray:[mappedHeaders objectForKey:headerKey]];
            [valueList addObject:headerValue];
            [mappedHeaders setObject:valueList forKey:headerKey];
        }
    }

    return mappedHeaders;
}

+ (NSArray<NSArray<NSString*>*> *)getHeadersArray:(NSDictionary<NSString*,NSString*> *)headersMap {
    __block NSArray *headersArray = [NSArray array];
    
    if (headersMap && headersMap.count > 0) {
        @try {
            [headersMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                headersArray = [headersArray arrayByAddingObject:@[key, obj]];
            }];
        }
        @catch (id exception) {
            return NULL;
        }
    }
    
    return headersArray;
}

+ (void)sendSuccess:(NSString *)requestId url:(NSString *)url response:(NSString *)response responseCode:(long)responseCode headers:(NSDictionary<NSString*,NSString*> *)headers {
    NSArray<NSArray<NSString*>*> *responseHeaders = [USRVApiRequest getHeadersArray:headers];

    if (!responseHeaders) {
        NSError *error = [NSError errorWithDomain:@"com.unity3d.ads.UnityServices.Error"
                                             code:kUnityServicesWebRequestGenericError
                                         userInfo:@{@"code":[NSNumber numberWithLong:kUnityServicesWebRequestGenericError], @"message":@"Error parsing response headers"}];
        [USRVApiRequest sendFailed:requestId url:url error:error];
        return;
    }

    [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromWebRequestEvent(kUnityServicesWebRequestEventComplete)
                                         category:webRequestEventCategory
                                           param1:requestId,
            url,
            response,
            [NSNumber numberWithLong:responseCode],
            responseHeaders,
         nil];
}

+ (void)sendFailed:(NSString *)requestId url:(NSString *)url error:(NSError *)error {
    NSNumber *errorCode = 0;
    NSString *errorMessage = @"";

    if (error.userInfo) {
        if ([error.userInfo objectForKey:@"code"]) {
            errorCode = [error.userInfo objectForKey:@"code"];
        }
        if ([error.userInfo objectForKey:@"message"]) {
            errorMessage = [error.userInfo objectForKey:@"message"];
        }
    }

    [[USRVWebViewApp getCurrentApp] sendEvent:NSStringFromWebRequestEvent(kUnityServicesWebRequestEventFailed)
                                     category:webRequestEventCategory
                                       param1:requestId,
        url,
        [NSString stringWithFormat:@"%@: %ld", errorMessage, [errorCode longValue]],
     nil];
}

@end
