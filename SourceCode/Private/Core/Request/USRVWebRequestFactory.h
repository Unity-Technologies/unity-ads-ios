#import "USRVWebRequest.h"

typedef NS_ENUM (NSInteger, USRVWebRequestType) {
    kUnityAdsWebRequestUrlConnection
};

@protocol IUSRVWebRequestFactoryStatic<NSObject>
+ (id<USRVWebRequest>)create: (NSString *)url
                 requestType: (NSString *)requestType
                     headers: (NSDictionary<NSString *, NSArray<NSString *> *> *)headers
              connectTimeout: (int)connectTimeout;
@end

@protocol IUSRVWebRequestFactory<NSObject>
- (id<USRVWebRequest>)create: (NSString *)url
                 requestType: (NSString *)requestType
                     headers: (NSDictionary<NSString *, NSArray<NSString *> *> *)headers
              connectTimeout: (int)connectTimeout;
@end

@interface USRVWebRequestFactory : NSObject <IUSRVWebRequestFactoryStatic, IUSRVWebRequestFactory>

+ (void)setImplementationType: (USRVWebRequestType)type;
+ (id<USRVWebRequest>)create: (NSString *)url requestType: (NSString *)requestType headers: (NSDictionary<NSString *, NSArray<NSString *> *> *)headers connectTimeout: (int)connectTimeout;

@end
