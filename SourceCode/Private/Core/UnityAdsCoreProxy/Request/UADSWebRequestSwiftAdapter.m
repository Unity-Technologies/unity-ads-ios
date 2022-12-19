#import "UADSWebRequestSwiftAdapter.h"
#import "NSDictionary+Headers.h"
#import "NSError+RequestDictionary.h"
#import "UADSServiceProviderProxy.h"

@interface UADSWebRequestSwiftAdapter()
@property (nonatomic, strong) UADSCommonNetworkProxy* networkLayer;
@end

@implementation UADSWebRequestSwiftAdapter

- (instancetype)initWithUrl: (NSString *)url requestType: (NSString *)requestType headers: (NSDictionary<NSString *, NSArray<NSString *> *> *)headers connectTimeout: (int)connectTimeout {
    SUPER_INIT;
    _url = url;
    _requestType = requestType;
    _headers = headers;
    _connectTimeout = connectTimeout;
    return self;
}

- (NSData *)makeRequest {
    dispatch_semaphore_t sem = dispatch_semaphore_create(0);

    [_networkLayer sendRequestUsing: [self dictionaryRequest]
                  successCompletion:^(NSDictionary<NSString *, id> *_Nonnull success) {
                                self.responseHeaders = success[@"headers"];
                                self.responseCode = [success[@"responseCode"] longValue];
                                self.receivedData = [NSMutableData dataWithData: [success[@"response"] dataUsingEncoding: NSUTF8StringEncoding]];
                                self.expectedContentLength =  [[self.responseHeaders objectForKey: @"X-OrigLength"] intValue];

                                dispatch_semaphore_signal(sem);
                           }
                 andErrorCompletion:^(NSDictionary<NSString *, id> *_Nonnull failure) {
                                self.responseCode = [failure[@"code"] longValue];
                                self.error = [NSError errorWithFailureDictionary: failure];

                                dispatch_semaphore_signal(sem);
                            }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return self.receivedData;
}

- (void)setNativeNetworkBuilder:(UADSCommonNetworkProxy *)networkLayer {
    self.networkLayer = networkLayer;
}

- (void)cancel {
}

- (BOOL)is2XXResponse {
    return (int)[self responseCode] / 100 == 2;
}

- (NSDictionary *)dictionaryRequest {
    NSMutableDictionary *request = [NSMutableDictionary dictionary];

    request[@"id"] = [[NSUUID UUID] UUIDString];
    request[@"baseURL"] = self.url;
    request[@"headers"] = [NSDictionary uads_getRequestHeaders: self.headers];
    request[@"body"] = self.body ?: self.bodyData;
    request[@"requestTimeout"] = @(self.connectTimeout / 1000); // swift requests in ms
    request[@"method"] = self.requestType;

    return request;
}

@end
