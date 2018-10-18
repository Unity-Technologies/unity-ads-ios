#import "USRVWebRequestOperation.h"
#import "USRVResolveOperation.h"

@interface USRVWebRequestQueue : NSObject

+ (void)start;
+ (void)setConcurrentRequestCount: (int) count;
+ (void)requestUrl:(NSString *)url type:(NSString *)type headers:(NSDictionary<NSString*, NSArray*> *)headers body:(NSString *)body completeBlock:(UnityServicesWebRequestCompletion)completeBlock connectTimeout:(int)connectTimeout;
+ (void)requestUrl:(NSString *)url type:(NSString *)type headers:(NSDictionary<NSString*, NSArray*> *)headers completeBlock:(UnityServicesWebRequestCompletion)completeBlock connectTimeout:(int)connectTimeout;
+ (BOOL)resolve:(NSString *)host completeBlock:(UnityServicesResolveRequestCompletion)completeBlock;
+ (void)cancelAllOperations;

@end
