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

    [UADSWebRequestQueue requestUrl:url type:@"GET" headers:[UADSApiRequest getHeadersMap:headers] completeBlock:completeBlock connectTimeout:[connectTimeout intValue]];
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

    [UADSWebRequestQueue requestUrl:url type:@"HEAD" headers:[UADSApiRequest getHeadersMap:headers] completeBlock:completeBlock connectTimeout:[connectTimeout intValue]];
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

+ (void)sendSuccess:(NSString *)requestId url:(NSString *)url response:(NSString *)response responseCode:(long)responseCode headers:(NSDictionary<NSString*,NSString*> *)headers {
    [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromWebRequestEvent(kUnityAdsWebRequestEventComplete)
                                         category:webRequestEventCategory
                                           param1:requestId,
            url,
            response,
            [NSNumber numberWithLong:responseCode],
            headers,
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