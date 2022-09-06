#import "UADSWebRequestSwiftAdapterWithFallback.h"
#import "USRVWebRequestWithUrlConnection.h"
#import "USRVSDKMetrics.h"

NSString *const UADSSwiftErrorDomain = @"UnityAds.HTTPURLResponseError";

@interface UADSWebRequestSwiftAdapterWithFallback ()
@property (nonatomic, strong) id<USRVWebRequest> original;
@property (nonatomic, strong) id<ISDKMetrics> metricSender;
@property (nonatomic, strong) id<UADSConfigurationMetricTagsReader> tagsReader;
@property (nonatomic, strong) id<IUSRVWebRequestFactory> fallbackFactory;
@end

@implementation UADSWebRequestSwiftAdapterWithFallback

+ (instancetype)newWithOriginal: (id<USRVWebRequest>)original
                   metricSender: (id<ISDKMetrics>)metricSender {
    return [self newWithOriginal: original
                 fallbackFactory: [USRVWebRequestFactory new]
                    metricSender: metricSender];
}

+ (instancetype)newWithOriginal: (id<USRVWebRequest>)original
                fallbackFactory: (id<IUSRVWebRequestFactory>)fallbackFactory
                   metricSender: (id<ISDKMetrics>)metricSender {
    UADSWebRequestSwiftAdapterWithFallback *adapter = [UADSWebRequestSwiftAdapterWithFallback new];

    adapter.original = original;
    adapter.metricSender = metricSender;
    adapter.fallbackFactory = fallbackFactory;
    return adapter;
}

- (instancetype)initWithUrl: (NSString *)url requestType: (NSString *)requestType headers: (NSDictionary<NSString *, NSArray<NSString *> *> *)headers connectTimeout: (int)connectTimeout {
    SUPER_INIT;
    return self;
}

- (NSData *)makeRequest {
    NSData *data;
    BOOL shouldFallback = false;

    @try {
        data = [self.original makeRequest];
        shouldFallback = self.original.error && ![self.original.error.domain isEqualToString: UADSSwiftErrorDomain];
    } @catch (NSException *exception) {
        shouldFallback = true;
    }

    if (shouldFallback) {
        data = [self makeObjcRequest];
        [self sendMetricIfNeeded];
    }

    return data;
}

- (void)cancel {
}

- (BOOL)is2XXResponse {
    return [self.original is2XXResponse];
}

- (NSData *)makeObjcRequest {
    id<USRVWebRequest> request = [self.fallbackFactory create: self.original.url
                                                  requestType: self.original.requestType
                                                      headers: self.original.headers
                                               connectTimeout: self.original.connectTimeout];

    return [request makeRequest];
}

- (void)sendMetricIfNeeded {
    if (self.metricSender) {
        [self.metricSender sendMetric: [UADSMetric newWithName: @"native_request_objc_fallback"
                                                         value: nil
                                                          tags: self.tagsReader.metricTags]];
    }
}

- (void)setBody: (NSString *)body {
    _original.body = body;
}

- (NSString *)body {
    return _original.body;
}

- (NSData *)bodyData {
    return _original.bodyData;
}

- (void)setBodyData: (NSData *)bodyData {
    _original.bodyData = bodyData;
}

- (NSError *)error {
    return _original.error;
}

- (void)setError: (NSError *)error {
    _original.error = error;
}

- (long long)expectedContentLength {
    return _original.expectedContentLength;
}

- (void)setExpectedContentLength: (long long)expectedContentLength {
    _original.expectedContentLength = expectedContentLength;
}

- (NSMutableData *)receivedData {
    return _original.receivedData;
}

- (void)setReceivedData: (NSMutableData *)receivedData {
    _original.receivedData = receivedData;
}

- (long)responseCode {
    return _original.responseCode;
}

- (void)setResponseCode: (long)responseCode {
    _original.responseCode = responseCode;
}

- (NSDictionary<NSString *, NSString *> *)responseHeaders {
    return _original.responseHeaders;
}

- (void)setResponseHeaders: (NSDictionary<NSString *, NSString *> *)responseHeaders {
    _original.responseHeaders = responseHeaders;
}

- (NSCondition *)blockCondition {
    return _original.blockCondition;
}

- (void)setBlockCondition: (NSCondition *)blockCondition {
    _original.blockCondition = blockCondition;
}

- (BOOL)canceled {
    return _original.canceled;
}

- (void)setCanceled: (BOOL)canceled {
    _original.canceled = canceled;
}

- (NSURLConnection *)connection {
    return _original.connection;
}

- (void)setConnection: (NSURLConnection *)connection {
    _original.connection = connection;
}

- (int)connectTimeout {
    return _original.connectTimeout;
}

- (void)setConnectTimeout: (int)connectTimeout {
    _original.connectTimeout = connectTimeout;
}

- (BOOL)finished {
    return _original.finished;
}

- (void)setFinished: (BOOL)finished {
    _original.finished = finished;
}

- (NSDictionary<NSString *, NSArray *> *)headers {
    return _original.headers;
}

- (void)setHeaders: (NSDictionary<NSString *, NSArray *> *)headers {
    _original.headers = headers;
}

- (UnityServicesWebRequestProgress)progressBlock {
    return _original.progressBlock;
}

- (void)setProgressBlock: (UnityServicesWebRequestProgress)progressBlock {
    _original.progressBlock = progressBlock;
}

- (NSMutableURLRequest *)request {
    return _original.request;
}

- (void)setRequest: (NSMutableURLRequest *)request {
    _original.request = request;
}

- (NSString *)requestType {
    return _original.requestType;
}

- (void)setRequestType: (NSString *)requestType {
    _original.requestType = requestType;
}

- (UnityServicesWebRequestStart)startBlock {
    return _original.startBlock;
}

- (void)setStartBlock: (UnityServicesWebRequestStart)startBlock {
    _original.startBlock = startBlock;
}

- (NSString *)url {
    return _original.url;
}

- (void)setUrl: (NSString *)url {
    _original.url = url;
}

@end
