#import "UnityAds.h"
#import "UADSWebViewApp.h"
#import "UADSSdkProperties.h"

@implementation UADSWebViewApp

static UADSWebViewApp *currentApp = NULL;

+ (UADSWebViewApp *)getCurrentApp {
    return currentApp;
}

+ (void)setCurrentApp:(UADSWebViewApp *)webViewApp {
    currentApp = webViewApp;
}

+ (void)create:(UADSConfiguration *)configuration; {
    UADSWebViewApp *webViewApp = [[UADSWebViewApp alloc] initWithConfiguration:configuration];

    dispatch_sync(dispatch_get_main_queue(), ^(void) {
        UIWebView *webView = NULL;
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1024,768)];
        webView.mediaPlaybackRequiresUserAction = NO;
        webView.allowsInlineMediaPlayback = YES;
        [webView setBackgroundColor:[UIColor clearColor]];
        [webView setOpaque:false];
        webView.scrollView.bounces = NO;
        [webViewApp setWebView:webView];
        NSString * const localWebViewUrl = [UADSSdkProperties getLocalWebViewFile];
        NSString *queryString = [NSString stringWithFormat:@"%1$@?platform=ios&origin=%2$@", localWebViewUrl, [UADSWebViewApp urlEncode:[configuration webViewUrl]]];
        
        if (configuration.webViewVersion) {
            queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@"&version=%1@", [UADSWebViewApp urlEncode:configuration.webViewVersion]]];
        }
        
        [[webViewApp webView] loadData:[NSData dataWithContentsOfFile:localWebViewUrl] MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:[NSURL URLWithString:queryString]];
    });

    [UADSWebViewApp setCurrentApp:webViewApp];
}

+ (NSString *)urlEncode:(NSString *)url {
    NSString *unreserved = @"-._";
    NSMutableCharacterSet *allowed = [NSMutableCharacterSet alphanumericCharacterSet];
    [allowed addCharactersInString:unreserved];
    
    return [url stringByAddingPercentEncodingWithAllowedCharacters:allowed];
}

- (instancetype)initWithConfiguration:(UADSConfiguration *)configuration {
    self = [super init];
    
    if (self) {
        [self setConfiguration:configuration];
        [UADSInvocation setClassTable:configuration.webAppApiClassList];
    }
    
    return self;
}

- (void)invokeJavascriptMethod:(NSString *)methodName className:(NSString *)className params:(NSArray *)params {
    BOOL isValid = [NSJSONSerialization isValidJSONObject:params];
    
    if (isValid) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
        NSString *paramStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *javaScriptString = [[NSString alloc] initWithFormat:@"window.%@.%@(%@);", className, methodName, paramStr];
        UADSLogDebug(@"JS_STRING: %@", javaScriptString);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.webView stringByEvaluatingJavaScriptFromString:javaScriptString];
        });
    }
    else {
        UADSLogError(@"FATAL_ERROR: Tried to invoke javascript with data that could not be parsed to JSON: %@", [params description]);
    }
}

- (BOOL)sendEvent:(NSString *)eventId category:(NSString *)category param1:(id)param1, ... {
    if (self.webAppLoaded) {
        va_list args;
        va_start(args, param1);

        NSMutableArray *params = [[NSMutableArray alloc] init];
        __unsafe_unretained id arg = nil;

        if (param1) {
            [params addObject:param1];

            while ((arg = va_arg(args, id)) != nil) {
                [params addObject:arg];
            }

            va_end(args);
        }

        return [self sendEvent:eventId category:category params:params];
    }

    return false;
}

- (BOOL)sendEvent:(NSString *)eventId category:(NSString *)category params:(NSArray *)params {
    if (self.webAppLoaded) {
        NSMutableArray *combinedParams = [[NSMutableArray alloc] init];
        [combinedParams addObject:category];
        [combinedParams addObject:eventId];
        [combinedParams addObjectsFromArray:params];

        [self invokeJavascriptMethod:@"handleEvent" className:@"nativebridge" params:[[NSArray alloc] initWithArray:combinedParams]];

        return true;
    }

    return false;
}

- (BOOL)invokeMethod:(NSString *)methodName className:(NSString *)className receiverClass:(NSString *)receiverClass callback:(NSString *)callback params:(NSArray *)params {
    if (self.webAppLoaded) {
        NSMutableArray *combinedParams = [[NSMutableArray alloc] init];
        [combinedParams addObject:className];
        [combinedParams addObject:methodName];

        if (receiverClass && callback) {
            UADSNativeCallback *nativeCallback = [[UADSNativeCallback alloc] initWithCallback:callback receiverClass:receiverClass];
            if ([nativeCallback callbackId]) {
                [self addCallback:nativeCallback];
                [combinedParams addObject:[nativeCallback callbackId]];
            }
        }
        [combinedParams addObjectsFromArray:params];

        [self invokeJavascriptMethod:@"handleInvocation" className:@"nativebridge" params:combinedParams];
        return true;
    }

    return false;
}

- (BOOL)invokeCallback:(UADSInvocation *)invocation {
    if (self.webAppLoaded) {
        NSMutableArray *responseList = [[NSMutableArray alloc] init];

        for (NSArray *response in [invocation responses]) {
            NSArray *params = [response objectAtIndex:2];
            NSString *callbackId = [params objectAtIndex:0];
            params = [params subarrayWithRange:NSMakeRange(1, params.count -1)];
            NSString *status = [response objectAtIndex:0];
            NSMutableArray *combinedResponse = [[NSMutableArray alloc] init];
            
            [combinedResponse addObject:callbackId];
            [combinedResponse addObject:status];
            NSMutableArray *paramArray = [[NSMutableArray alloc] init];

            // Check for error and add it to response if there is one
            NSString *error = [response objectAtIndex:1];
            if (error != NULL && [error length] > 0) {
                [paramArray addObject:error];
            }
            
            [paramArray addObjectsFromArray:params];
            [combinedResponse addObject:paramArray];
            [responseList addObject:[[NSArray alloc] initWithArray:combinedResponse]];
        }
        
        [self invokeJavascriptMethod:@"handleCallback" className:@"nativebridge" params:responseList];

        return true;
    }
    else {
        UADSLogDebug(@"WebApp not loaded!");
    }

    return false;
}

- (void)addCallback:(UADSNativeCallback *)callback {
    if (callback) {
        if (!self.nativeCallbacks) {
            self.nativeCallbacks = [[NSMutableDictionary alloc] init];
        }

        [self.nativeCallbacks setObject:callback forKey:[callback callbackId]];
    }
}

- (void)removeCallback:(UADSNativeCallback *)callback {
    if (self.nativeCallbacks && callback) {
        [self.nativeCallbacks removeObjectForKey:[callback callbackId]];
    }
}

- (UADSNativeCallback *)getCallbackWithId:(NSString *)callbackId {
    if (self.nativeCallbacks && callbackId) {
        return [self.nativeCallbacks objectForKey:callbackId];
    }

    return NULL;
}

@end
