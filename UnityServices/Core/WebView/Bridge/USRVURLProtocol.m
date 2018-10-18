#import "USRVURLProtocol.h"
#import "USRVWebViewMethodInvokeHandler.h"

static NSString* const kUnityServicesURLProtocolHostname = @"webviewbridge.unityads.unity3d.com";

@implementation USRVURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSURL *url = [request URL];
    
    if (([[request HTTPMethod] isEqualToString:@"POST"] || [[request HTTPMethod] isEqualToString:@"OPTIONS"]) && [[url host] isEqualToString:(NSString *)kUnityServicesURLProtocolHostname]) {
        return TRUE;
    }
    return FALSE;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

- (void)startLoading {
    NSURLRequest *request = [self request];
    NSData *reqData = [request HTTPBody];
    USRVWebViewMethodInvokeHandler *handler = [[USRVWebViewMethodInvokeHandler alloc] init];
    
    if(reqData != nil) {
        NSURL *url = [request URL];
        [handler handleData:reqData invocationType:[url lastPathComponent]];
    }
    
    // Create the response
    NSData *responseData = [@"{\"status\":\"ok\"}" dataUsingEncoding:NSUTF8StringEncoding];
    
    NSDictionary *headers = @{
                              @"Access-Control-Allow-Origin":@"*",
                              @"Access-Control-Allow-Headers":@"origin, content-type",
                              @"Content-Type":@"application/json",
                              @"Content-Length":[NSString stringWithFormat:@"%lu", (unsigned long)responseData.length]
                              };
    
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:[request URL] statusCode:200 HTTPVersion:@"1.1" headerFields:headers];
    
    // get a reference to the client so we can hand off the data
    id<NSURLProtocolClient> client = [self client];
    
    // turn off caching for this response data
    [client URLProtocol:self didReceiveResponse:response
     cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    // set the data in the response to our response data
    [client URLProtocol:self didLoadData:responseData];
    
    // notify that we completed loading
    [client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading {
}




@end
