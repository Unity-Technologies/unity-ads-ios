#import "UADSWebRequestQueue.h"
#import "UADSWebRequest.h"
#import "UADSResolveError.h"

@implementation UADSWebRequestQueue

static NSOperationQueue *requestQueue;
static NSOperationQueue *resolveQueue;
static dispatch_once_t onceToken;

+ (void)start {
    dispatch_once(&onceToken, ^{
        if (!requestQueue) {
            requestQueue = [[NSOperationQueue alloc] init];
            requestQueue.maxConcurrentOperationCount = 1;
        }

        if (!resolveQueue) {
            resolveQueue = [[NSOperationQueue alloc] init];
            resolveQueue.maxConcurrentOperationCount = 1;
        }
    });
}

+ (void)setConcurrentRequestCount: (int) count {
    requestQueue.maxConcurrentOperationCount = count;
}

+ (void)requestUrl:(NSString *)url type:(NSString *)type headers:(NSDictionary<NSString*, NSArray*> *)headers completeBlock:(UnityAdsWebRequestCompletion)completeBlock connectTimeout:(int)connectTimeout {
    [UADSWebRequestQueue requestUrl:url type:type headers:headers body:NULL completeBlock:completeBlock connectTimeout:connectTimeout];
}

+ (void)requestUrl:(NSString *)url type:(NSString *)type headers:(NSDictionary<NSString*, NSArray*> *)headers body:(NSString *)body completeBlock:(UnityAdsWebRequestCompletion) completeBlock connectTimeout:(int)connectTimeout {
    
    if (requestQueue && url && type && completeBlock) {
        UADSWebRequestOperation *operation = [[UADSWebRequestOperation alloc] initWithUrl:url requestType:type headers:headers body:body completeBlock:completeBlock connectTimeout:connectTimeout];
        [requestQueue addOperation:operation];
    }
}

+ (BOOL)resolve:(NSString *)host completeBlock:(UnityAdsResolveRequestCompletion)completeBlock {
    if (!host || host.length < 3 || [host isEqual:[NSNull null]]) {
        completeBlock(host, NULL, NSStringFromResolveError(kUnityAdsResolveErrorInvalidHost), @"Invalid host");
        return false;
    }

    UADSResolveOperation *operation = [[UADSResolveOperation alloc] initWithHostName:host completeBlock:completeBlock];
    [resolveQueue addOperation:operation];

    return true;
}

+ (void)cancelAllOperations {
    if (requestQueue) {
        [requestQueue cancelAllOperations];
    }
    if (resolveQueue) {
        [resolveQueue cancelAllOperations];
    }
}

@end
