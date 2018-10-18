#import "USRVWebRequest.h"
#import "USRVWebRequestError.h"

@interface USRVWebRequest () <NSURLConnectionDelegate>

@end

@implementation USRVWebRequest

- (instancetype)initWithUrl:(NSString *)url requestType:(NSString *)requestType headers:(NSDictionary<NSString*,NSArray<NSString*>*> *)headers connectTimeout:(int)connectTimeout {
    self = [super init];
    
    if (self) {
        [self setUrl:url];
        [self setRequestType:requestType];
        [self setHeaders:headers];
        [self setFinished:false];
        [self setConnectTimeout:connectTimeout / 1000];
    }
    
    return self;
}

- (NSData *)makeRequest {
    NSURL *url = [NSURL URLWithString:self.url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [self setRequest:request];
    [request setURL:url];
    [request setHTTPMethod:self.requestType];
    [request setTimeoutInterval:self.connectTimeout];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    
    if ([self.requestType isEqualToString:@"POST"]) {
        NSString *post = self.body;
        if (!post) {
            post = @"";
        }
        
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding];
        NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
    }
    
    if (self.headers) {
        for (NSString *key in [self.headers allKeys]) {
            NSArray *contents = [self.headers objectForKey:key];
            for (NSString *value in contents) {
                [request setValue:value forHTTPHeaderField:key];
            }
        }
    }
    
    self.receivedData = [[NSMutableData alloc] init];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:false];
    [self setConnection:connection];
    [connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    self.blockCondition = [[NSCondition alloc] init];
    [self.blockCondition lock];

    [connection start];

    [self.blockCondition wait];
    [self.blockCondition unlock];

    if (self.canceled) {
    }

    return self.receivedData;
}

- (void)receiveTimerTimedOut {
    [self.blockCondition lock];
    [self setError:[NSError errorWithDomain:@"com.unity3d.ads.UnityAds.Error"
                                       code:kUnityServicesWebRequestErrorRequestTimedOut
                                   userInfo:[self makeUserInfoDictionary:kUnityServicesWebRequestErrorRequestTimedOut message:@"Request timed out"]]];
    self.finished = true;
    [self.blockCondition signal];
    [self.blockCondition unlock];
    
}

- (void)cancel {
    [self.blockCondition lock];
    self.canceled = true;
    self.finished = true;
    [self.connection cancel];
    [self.blockCondition signal];
    [self.blockCondition unlock];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.receivedData setLength:0];
    self.expectedContentLength = [response expectedContentLength];
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        self.responseCode = [httpResponse statusCode];
        self.responseHeaders = [httpResponse allHeaderFields];
    }

    if (!self.responseHeaders) {
        self.responseHeaders = [[NSDictionary alloc] init];
    }

    if (self.startBlock) {
        self.startBlock(self.url, self.expectedContentLength);
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
    
    if (self.progressBlock) {
        self.progressBlock(self.url, (long long)self.receivedData.length, self.expectedContentLength);
    }
}

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse {
    if (!redirectResponse) {
        return request;
    }

    return nil;
}

- (NSDictionary *)makeUserInfoDictionary:(long)errorCode message:(NSString *)message {
    return @{@"code":[NSNumber numberWithLong:errorCode], @"message":message};
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.blockCondition lock];
    [self setError:[NSError errorWithDomain:@"com.unity3d.ads.UnityAds.Error"
                                       code:kUnityServicesWebRequestGenericError
                                   userInfo:[self makeUserInfoDictionary:error.code message:error.description]]];
    self.finished = true;
    [self.blockCondition signal];
    [self.blockCondition unlock];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.blockCondition lock];
    self.finished = true;
    [self.blockCondition signal];
    [self.blockCondition unlock];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

@end
