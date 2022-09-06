#import "UADSWebRequestSwiftAdapter.h"
#import <UnityAds/UnityAds-Swift.h>
#import "NSDictionary+Headers.h"
#import "NSError+RequestDictionary.h"

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
    NetworkLayerObjCBridge *networkLayer = [[ServiceProviderObjCBridge shared] nativeNetworkLayer];

    [networkLayer sendRequestUsing: [self dictionaryRequest]
                           success:^(NSDictionary<NSString *, id> *_Nonnull success) {
                               self.responseHeaders = success[@"headers"];
                               self.responseCode = [success[@"responseCode"] longValue];
                               self.receivedData = [NSMutableData dataWithData: [success[@"response"] dataUsingEncoding: NSUTF8StringEncoding]];
                               self.expectedContentLength =  [[self.responseHeaders objectForKey: @"X-OrigLength"] intValue];

                               dispatch_semaphore_signal(sem);
                           }
                           failure:^(NSDictionary<NSString *, id> *_Nonnull failure) {
                               self.responseCode = [failure[@"code"] longValue];
                               self.error = [NSError errorWithFailureDictionary: failure];

                               dispatch_semaphore_signal(sem);
                           }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return self.receivedData;
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
    request[@"body"] = self.body;
    request[@"requestTimeout"] = @(self.connectTimeout);
    request[@"method"] = self.requestType;

    return request;
}

@end
