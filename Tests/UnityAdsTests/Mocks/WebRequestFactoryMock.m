#import "WebRequestFactoryMock.h"


@implementation WebRequestFactoryMock
+ (instancetype)shared {
    static WebRequestFactoryMock *sharedInstance = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        sharedInstance = [[WebRequestFactoryMock alloc] init];
    });
    return sharedInstance;
}

+ (id<USRVWebRequest>)create: (NSString *)url requestType: (NSString *)requestType headers: (NSDictionary<NSString *, NSArray<NSString *> *> *)headers connectTimeout: (int)connectTimeout {
    id<USRVWebRequest> mockRequest = [[WebRequestFactoryMock shared] mockRequest];

    mockRequest.url = url;
    mockRequest.requestType = requestType;
    mockRequest.headers = headers;
    mockRequest.connectTimeout = connectTimeout;
    return mockRequest;
}

- (id<USRVWebRequest>)create: (NSString *)url
                 requestType: (NSString *)requestType
                     headers: (NSDictionary<NSString *, NSArray<NSString *> *> *)headers
              connectTimeout: (int)connectTimeout {
    if (_createdRequests == nil) {
        _createdRequests = @[];
    }

    WebRequestMock *requestToSaveForTesting = [WebRequestMock new];

    requestToSaveForTesting.url = url;
    requestToSaveForTesting.requestType = requestType;
    requestToSaveForTesting.headers = headers;
    requestToSaveForTesting.connectTimeout = connectTimeout;
    _createdRequests = [_createdRequests arrayByAddingObjectsFromArray: @[requestToSaveForTesting]];

    if (_mockRequest) {
        return _mockRequest;
    }

    requestToSaveForTesting.expectedData = _expectedRequestData[_createdRequests.count - 1];
    return requestToSaveForTesting;
}

@end
