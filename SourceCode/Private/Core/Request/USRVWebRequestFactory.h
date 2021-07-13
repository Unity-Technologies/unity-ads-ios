#import "USRVWebRequest.h"

typedef NS_ENUM (NSInteger, USRVWebRequestType) {
    kUnityAdsWebRequestUrlConnection
};

@interface USRVWebRequestFactory : NSObject

+ (void)setImplementationType: (USRVWebRequestType)type;
+ (id<USRVWebRequest>)create: (NSString *)url requestType: (NSString *)requestType headers: (NSDictionary<NSString *, NSArray<NSString *> *> *)headers connectTimeout: (int)connectTimeout;

@end
