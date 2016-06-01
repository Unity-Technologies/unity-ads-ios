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
            [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromWebRequestEvent(kUnityAdsWebRequestEventComplete)
                                             category:webRequestEventCategory
                                               param1:requestId,
                url,
                response,
                [NSNumber numberWithLong:responseCode],
                headers,
             nil];
        }
        else {
            [UADSApiRequest sendFailed:requestId url:url errorCode:error.code errorDomain:error.domain];
        }
    };

    [UADSWebRequestQueue requestUrl:url type:@"GET" headers:[UADSApiRequest getHeadersMap:headers] completeBlock:completeBlock connectTimeout:[connectTimeout intValue]];
    [callback invoke:requestId, nil];
}

+ (void)WebViewExposed_head:(NSString *)requestId url:(NSString *)url headers:(NSArray *)headers connectTimeout:(NSNumber *)connectTimeout callback:(UADSWebViewCallback *)callback {
    if (headers && headers.count == 0) {
        headers = NULL;
    }

    UnityAdsWebRequestCompletion completeBlock = ^(NSString *url, NSError *error, NSString *response, long responseCode, NSDictionary<NSString*,NSString*> *headers) {
        if (!error) {
            [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromWebRequestEvent(kUnityAdsWebRequestEventComplete)
                                             category:webRequestEventCategory
                                               param1:requestId,
                url,
                response,
                [NSNumber numberWithLong:responseCode],
                headers,
             nil];
        }
        else {
            [UADSApiRequest sendFailed:requestId url:url errorCode:error.code errorDomain:error.domain];
        }
    };

    [UADSWebRequestQueue requestUrl:url type:@"HEAD" headers:[UADSApiRequest getHeadersMap:headers] completeBlock:completeBlock connectTimeout:[connectTimeout intValue]];
    [callback invoke:requestId, nil];
}

+ (void)WebViewExposed_post:(NSString *)requestId url:(NSString *)url body:(NSString *)body headers:(NSArray *)headers connectTimeout:(NSNumber *)connectTimeout callback:(UADSWebViewCallback *)callback {
    
    if (headers && headers.count == 0) {
        headers = NULL;
    }

    UnityAdsWebRequestCompletion completeBlock = ^(NSString *url, NSError *error, NSString *response, long responseCode, NSDictionary<NSString*,NSString*> *headers) {
        if (!error) {
            [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromWebRequestEvent(kUnityAdsWebRequestEventComplete)
                                             category:webRequestEventCategory
                                               param1:requestId,
                url,
                response,
                [NSNumber numberWithLong:responseCode],
                headers,
             nil];
        }
        else {
            [UADSApiRequest sendFailed:requestId url:url errorCode:error.code errorDomain:error.domain];
        }
    };

    [UADSWebRequestQueue requestUrl:url type:@"POST" headers:[UADSApiRequest getHeadersMap:headers] body:body completeBlock:completeBlock connectTimeout:[connectTimeout intValue]];

    [callback invoke:requestId, nil];
}

+ (NSDictionary<NSString*,NSArray*> *)getHeadersMap:(NSArray *)headers {
    NSMutableDictionary *mappedHeaders;
    
    if (headers && headers.count > 0) {
        mappedHeaders = [[NSMutableDictionary alloc] init];
        
        for (int idx = 0; idx < headers.count; idx++) {
            NSArray *header = [headers objectAtIndex:idx];
            NSMutableArray *valueList = [[NSMutableArray alloc] initWithArray:[mappedHeaders objectForKey:[header objectAtIndex:0]]];
            [valueList addObject:[header objectAtIndex:1]];
            [mappedHeaders setObject:valueList forKey:[header objectAtIndex:0]];
        }
    }

    return mappedHeaders;
}

+ (void)sendFailed:(NSString *)requestId url:(NSString *)url errorCode:(NSInteger)errorCode errorDomain:(NSString *)errorDomain {
    [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromWebRequestEvent(kUnityAdsWebRequestEventFailed)
                                     category:webRequestEventCategory
                                       param1:requestId,
        url,
     [NSString stringWithFormat:@"%@: %ld", errorDomain, (long)errorCode],
     nil];
}

@end