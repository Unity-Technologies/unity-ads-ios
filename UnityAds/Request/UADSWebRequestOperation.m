#import "UADSWebRequestOperation.h"

@implementation UADSWebRequestOperation

- (instancetype)initWithUrl:(NSString *)url requestType:(NSString *)requestType headers:(NSDictionary<NSString*,NSArray<NSString*>*> *)headers body:(NSString *)body completeBlock:(UnityAdsWebRequestCompletion)completeBlock connectTimeout:(int)connectTimeout{
    
    self = [super init];
    
    if (self) {
        [self setRequest:[[UADSWebRequest alloc] initWithUrl:url requestType:requestType headers:headers connectTimeout:connectTimeout]];
        [self.request setBody:body];
        
        [self setCompleteBlock:completeBlock];
    }
    
    return self;
}

- (void)main {
    NSData *data = [self.request makeRequest];
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (self.completeBlock) {
        self.completeBlock(self.request.url, self.request.error, responseString, self.request.responseCode, self.request.responseHeaders);
    }
}

@end