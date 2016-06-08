#import "UnityAds.h"
#import "UADSURLProtocol.h"
#import "UADSInvocation.h"
#import "UADSWebViewCallback.h"
#import "UADSWebViewBridge.h"

static NSString* const kUnityAdsURLProtocolHostname = @"webviewbridge.unityads.unity3d.com";

@implementation UADSURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    NSURL *url = [request URL];
    
    if (([[request HTTPMethod] isEqualToString:@"POST"] || [[request HTTPMethod] isEqualToString:@"OPTIONS"]) && [[url host] isEqualToString:(NSString *)kUnityAdsURLProtocolHostname]) {
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
    
    if(reqData != nil) {
        NSURL *url = [request URL];
        [self actOnJSONResults:reqData invocationType:[url lastPathComponent]];
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

- (void)actOnJSONResults:(NSData *)jsonData invocationType:(NSString *)invocationType {
    NSError* jsonError;

    if (invocationType) {
        if ([invocationType isEqualToString:@"handleInvocation"]) {
            NSArray* jsonArray = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];

            if (jsonError) {
                UADSLogError(@"JSON ERROR: %@", [jsonError description]);
            }
            else if (!jsonArray || ![jsonArray isKindOfClass:[NSArray class]]) {
                UADSLogError(@"ERROR PARSING JSON TO ARRAY: %@", jsonError);
                return;
            }

            [self handleInvocation:jsonArray];
        }
        else if ([invocationType isEqualToString:@"handleCallback"]) {
            NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&jsonError];

            if (jsonError) {
                UADSLogError(@"JSON ERROR: %@", [jsonError description]);
            }
            else if (!jsonDictionary || ![jsonDictionary isKindOfClass:[NSDictionary class]]) {
                UADSLogError(@"ERROR PARSING JSON TO DICTIONARY: %@", jsonError);
                return;
            }

            [self handleCallback:jsonDictionary];
        }
    }
}

- (void)handleInvocation:(NSArray *)invocations {
    UADSInvocation *batch = [[UADSInvocation alloc] init];
    
    UADSLogDebug(@"%@", invocations);
    NSMutableDictionary *failedIndices = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *failedCallbacks = [[NSMutableDictionary alloc] init];
    
    for (int idx = 0; idx < [invocations count]; idx++) {
        NSArray* invocation = [invocations objectAtIndex:idx];
        NSString *className = [invocation objectAtIndex:0];
        NSString *methodName = [invocation objectAtIndex:1];
        NSArray *parameters = [invocation objectAtIndex:2];

        if (!parameters || ![parameters isKindOfClass:[NSArray class]]) {
            NSException* exception = [NSException
                                      exceptionWithName:@"InvalidInvocationException"
                                      reason:@"Parameters NULL or not NSArray"
                                      userInfo:nil];
            @throw exception;
        }

        NSString *callback = [invocation objectAtIndex:3];
        UADSWebViewCallback *webViewCallback = [[UADSWebViewCallback alloc] initWithCallbackId:callback invocationId:[batch invocationId]];

        @try {
            [batch addInvocation:className methodName:methodName parameters:parameters callback:webViewCallback];
        }
        @catch (NSException *exception) {
            UADSLogError(@"Error while adding invocation: %@", [exception reason]);
            [failedIndices setObject:exception forKey:[NSNumber numberWithInt:idx]];
            [failedCallbacks setObject:webViewCallback forKey:[NSNumber numberWithInt:idx]];
        }
    }

    for (int idx = 0; idx < [invocations count]; idx++) {
        if ([failedIndices objectForKey:[NSNumber numberWithInt:idx]]) {
            NSException *exception = [failedIndices objectForKey:[NSNumber numberWithInt:idx]];
            UADSWebViewCallback *webViewCallback = [failedCallbacks objectForKey:[NSNumber numberWithInt:idx]];

            if (webViewCallback) {
                [webViewCallback error:[exception name] arg1:[exception reason], nil];
            }
        }
        else {
            [batch nextInvocation];
        }
    }

    [batch sendInvocationCallback];
}

- (void)handleCallback:(NSDictionary *)callback {
    NSString *callbackId = [callback objectForKey:@"id"];
    NSString *callbackStatus = [callback objectForKey:@"status"];
    NSArray *parameters = [callback objectForKey:@"parameters"];

    if (!parameters || ![parameters isKindOfClass:[NSArray class]]) {
        NSException* exception = [NSException
                                  exceptionWithName:@"InvalidArgumentException"
                                  reason:@"Parameters NULL or wrong format"
                                  userInfo:nil];
        @throw exception;
    }

    [UADSWebViewBridge handleCallback:callbackId callbackStatus:callbackStatus params:parameters];
}

@end