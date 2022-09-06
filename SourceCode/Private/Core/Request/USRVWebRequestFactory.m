#import "USRVWebRequestFactory.h"
#import "USRVWebRequestError.h"
#import "USRVWebRequestWithUrlConnection.h"

@interface USRVWebRequestFactory () <NSObject>

@end

@implementation USRVWebRequestFactory

- (id<USRVWebRequest>)create: (NSString *)url
                 requestType: (NSString *)requestType
                     headers: (NSDictionary<NSString *, NSArray<NSString *> *> *)headers
              connectTimeout: (int)connectTimeout {
    return [[USRVWebRequestWithUrlConnection alloc] initWithUrl: url
                                                    requestType: requestType
                                                        headers: headers
                                                 connectTimeout: connectTimeout];
}

+ (id<USRVWebRequest>)create:(NSString *)url
                 requestType:(NSString *)requestType
                     headers:(NSDictionary<NSString *,NSArray<NSString *> *> *)headers
              connectTimeout:(int)connectTimeout {
    return [[self new] create: url requestType: requestType headers: headers connectTimeout: connectTimeout];
}

@end
