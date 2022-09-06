#import "WebRequestMock.h"

@implementation WebRequestMock

- (void)cancel {
}

- (instancetype)initWithUrl: (NSString *)url requestType: (NSString *)requestType headers: (NSDictionary<NSString *, NSArray<NSString *> *> *)headers connectTimeout: (int)connectTimeout {
    self = [super init];
    self.url = url;
    self.requestType = requestType;
    self.headers = headers;
    self.connectTimeout = connectTimeout;
    return self;
}

- (NSData *)makeRequest {
    self.makeRequestCount += 1;
    
    if (_sleepTime && !NSThread.isMainThread) {
        [NSThread sleepForTimeInterval: _sleepTime];
    }
    
    if (_throwExceptionOnMakeRequest) {
        @throw [NSException exceptionWithName: @"Test exception on make request"
                                       reason: @""
                                     userInfo: nil];
    }
    
    [_exp fulfill];

    return _expectedData;
}

- (BOOL)is2XXResponse {
    return !self.isResponseCodeInvalid;
}

@end
