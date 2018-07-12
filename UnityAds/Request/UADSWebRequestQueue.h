#import "UADSWebRequestOperation.h"
#import "UADSResolveOperation.h"

@interface UADSWebRequestQueue : NSObject

+ (void)start;
+ (void)setConcurrentRequestCount: (int) count;
+ (void)requestUrl:(NSString *)url type:(NSString *)type headers:(NSDictionary<NSString*, NSArray*> *)headers body:(NSString *)body completeBlock:(UnityAdsWebRequestCompletion)completeBlock connectTimeout:(int)connectTimeout;
+ (void)requestUrl:(NSString *)url type:(NSString *)type headers:(NSDictionary<NSString*, NSArray*> *)headers completeBlock:(UnityAdsWebRequestCompletion)completeBlock connectTimeout:(int)connectTimeout;
+ (BOOL)resolve:(NSString *)host completeBlock:(UnityAdsResolveRequestCompletion)completeBlock;
+ (void)cancelAllOperations;

@end
