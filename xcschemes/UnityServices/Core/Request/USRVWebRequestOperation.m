#import "USRVWebRequestOperation.h"

@implementation USRVWebRequestOperation

- (instancetype)initWithUrl:(NSString *)url requestType:(NSString *)requestType headers:(NSDictionary<NSString*,NSArray<NSString*>*> *)headers body:(NSString *)body completeBlock:(UnityServicesWebRequestCompletion)completeBlock connectTimeout:(int)connectTimeout{
    
    self = [super init];
    
    if (self) {
        [self setRequest:[[USRVWebRequest alloc] initWithUrl:url requestType:requestType headers:headers connectTimeout:connectTimeout]];
        [self.request setBody:body];
        
        [self setCompleteBlock:completeBlock];
    }
    
    return self;
}

- (void)main {
    [self startObserving];

    NSData *data = [self.request makeRequest];
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    if (!responseString) {
        responseString = [NSString stringWithFormat:@""];
    }

    [self stopObserving];

    if (self.completeBlock && self.request && !self.request.canceled) {
        self.completeBlock(self.request.url, self.request.error, responseString, self.request.responseCode, self.request.responseHeaders);
    }
}

- (void)startObserving {
    @try {
        [self addObserver:self forKeyPath:@"isCancelled" options:NSKeyValueObservingOptionNew context:nil];
    }
    @catch (id exception) {
    }
}

- (void)stopObserving {
    @try {
        [self removeObserver:self forKeyPath:@"isCancelled"];
    }
    @catch (id exception) {
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"isCancelled"]) {
        if (self.request && !self.request.finished) {
            [self.request cancel];
        }
    }
}

@end
