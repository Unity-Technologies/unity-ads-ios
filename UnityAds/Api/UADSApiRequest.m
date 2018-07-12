#import "UADSApiRequest.h"
#import "UADSWebViewCallback.h"
#import "UADSWebRequestQueue.h"
#import "UADSWebViewApp.h"
#import "UADSWebRequestError.h"
#import "UADSWebRequestEvent.h"

@implementation UADSApiRequest

static NSString *webRequestEventCategory = @"REQUEST";

+ (void)WebViewExposed_get:(NSString *)requestId url:(NSString *)url headers:(NSArray *)headers connectTimeout:(NSNumber *)connectTimeout callback:(UADSWebViewCallback *)callback {
    if (headers && headers.count == 0) {
        headers = NULL;
    }

    UnityAdsWebRequestCompletion completeBlock = ^(NSString *url, NSError *error, NSString *response, long responseCode, NSDictionary<NSString*,NSString*> *headers) {
        if (!error) {
            [UADSApiRequest sendSuccess:requestId url:url response:response responseCode:responseCode headers:headers];
        }
        else {
            [UADSApiRequest sendFailed:requestId url:url error:error];
        }
    };

    NSDictionary *mappedHeaders = [UADSApiRequest getHeadersMap:headers];

    if (!mappedHeaders) {
        [callback error:NSStringFromWebRequestError(kUnityAdsWebRequestErrorMappingHeadersFailed) arg1:nil];
        return;
    }

    [UADSWebRequestQueue requestUrl:url type:@"GET" headers:mappedHeaders completeBlock:completeBlock connectTimeout:[connectTimeout intValue]];
    [callback invoke:requestId, nil];
}

+ (void)WebViewExposed_head:(NSString *)requestId url:(NSString *)url headers:(NSArray *)headers connectTimeout:(NSNumber *)connectTimeout callback:(UADSWebViewCallback *)callback {
    if (headers && headers.count == 0) {
        headers = NULL;
    }

    UnityAdsWebRequestCompletion completeBlock = ^(NSString *url, NSError *error, NSString *response, long responseCode, NSDictionary<NSString*,NSString*> *headers) {
        if (!error) {
            [UADSApiRequest sendSuccess:requestId url:url response:response responseCode:responseCode headers:headers];
        }
        else {
            [UADSApiRequest sendFailed:requestId url:url error:error];
        }
    };

    NSDictionary *mappedHeaders = [UADSApiRequest getHeadersMap:headers];

    if (!mappedHeaders) {
        [callback error:NSStringFromWebRequestError(kUnityAdsWebRequestErrorMappingHeadersFailed) arg1:nil];
        return;
    }

    [UADSWebRequestQueue requestUrl:url type:@"HEAD" headers:mappedHeaders completeBlock:completeBlock connectTimeout:[connectTimeout intValue]];
    [callback invoke:requestId, nil];
}

+ (void)WebViewExposed_post:(NSString *)requestId url:(NSString *)url body:(NSString *)body headers:(NSArray *)headers connectTimeout:(NSNumber *)connectTimeout callback:(UADSWebViewCallback *)callback {
    
    if (headers && headers.count == 0) {
        headers = NULL;
    }

    UnityAdsWebRequestCompletion completeBlock = ^(NSString *url, NSError *error, NSString *response, long responseCode, NSDictionary<NSString*,NSString*> *headers) {
        if (!error) {
            [UADSApiRequest sendSuccess:requestId url:url response:response responseCode:responseCode headers:headers];
        }
        else {
            [UADSApiRequest sendFailed:requestId url:url error:error];
        }
    };

    NSDictionary *mappedHeaders = [UADSApiRequest getHeadersMap:headers];

    if (!mappedHeaders) {
        [callback error:NSStringFromWebRequestError(kUnityAdsWebRequestErrorMappingHeadersFailed) arg1:nil];
        return;
    }

    [UADSWebRequestQueue requestUrl:url type:@"POST" headers:mappedHeaders body:body completeBlock:completeBlock connectTimeout:[connectTimeout intValue]];
    [callback invoke:requestId, nil];
}

+ (void)WebViewExposed_setConcurrentRequestCount: (int) count callback:(UADSWebViewCallback *)callback {
    [UADSWebRequestQueue setConcurrentRequestCount: count];
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
    NSArray<NSArray<NSString*>*> *responseHeaders = [UADSApiRequest getHeadersArray:headers];

    if (!responseHeaders) {
        NSError *error = [NSError errorWithDomain:@"com.unity3d.ads.UnityAds.Error"
                                             code:kUnityAdsWebRequestGenericError
                                         userInfo:@{@"code":[NSNumber numberWithLong:kUnityAdsWebRequestGenericError], @"message":@"Error parsing response headers"}];
        [UADSApiRequest sendFailed:requestId url:url error:error];
        return;
    }

    [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromWebRequestEvent(kUnityAdsWebRequestEventComplete)
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

    [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromWebRequestEvent(kUnityAdsWebRequestEventFailed)
                                     category:webRequestEventCategory
                                       param1:requestId,
        url,
        [NSString stringWithFormat:@"%@: %ld", errorMessage, [errorCode longValue]],
     nil];
}

@end
