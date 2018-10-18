#import "USRVWebRequestQueue.h"
#import "USRVWebRequest.h"
#import "USRVResolveError.h"

@implementation USRVWebRequestQueue

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

+ (void)requestUrl:(NSString *)url type:(NSString *)type headers:(NSDictionary<NSString*, NSArray*> *)headers completeBlock:(UnityServicesWebRequestCompletion)completeBlock connectTimeout:(int)connectTimeout {
    [USRVWebRequestQueue requestUrl:url type:type headers:headers body:NULL completeBlock:completeBlock connectTimeout:connectTimeout];
}

+ (void)requestUrl:(NSString *)url type:(NSString *)type headers:(NSDictionary<NSString*, NSArray*> *)headers body:(NSString *)body completeBlock:(UnityServicesWebRequestCompletion) completeBlock connectTimeout:(int)connectTimeout {
    
    if (requestQueue && url && type && completeBlock) {
        USRVWebRequestOperation *operation = [[USRVWebRequestOperation alloc] initWithUrl:url requestType:type headers:headers body:body completeBlock:completeBlock connectTimeout:connectTimeout];
        [requestQueue addOperation:operation];
    }
}

+ (BOOL)resolve:(NSString *)host completeBlock:(UnityServicesResolveRequestCompletion)completeBlock {
    if (!host || host.length < 3 || [host isEqual:[NSNull null]]) {
        completeBlock(host, NULL, NSStringFromResolveError(kUnityServicesResolveErrorInvalidHost), @"Invalid host");
        return false;
    }

    USRVResolveOperation *operation = [[USRVResolveOperation alloc] initWithHostName:host completeBlock:completeBlock];
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
