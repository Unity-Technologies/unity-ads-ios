#import "USRVWebRequestFactory.h"
#import "USRVWebRequestError.h"
#import "USRVWebRequestWithUrlConnection.h"

static USRVWebRequestType s_ImplementationType = kUnityAdsWebRequestUrlConnection;

@interface USRVWebRequestFactory () <NSObject>

@end

@implementation USRVWebRequestFactory

+ (void)setImplementationType: (USRVWebRequestType)type {
    s_ImplementationType = type;
}

+ (id<USRVWebRequest>)create: (NSString *)url requestType: (NSString *)requestType headers: (NSDictionary<NSString *, NSArray<NSString *> *> *)headers connectTimeout: (int)connectTimeout {
    return [[USRVWebRequestWithUrlConnection alloc] initWithUrl: url
                                                    requestType: requestType
                                                        headers: headers
                                                 connectTimeout: connectTimeout];
}

@end
