#import "USRVWebViewApp.h"
#import "USRVSdkProperties.h"
#import "USRVURLProtocol.h"

@implementation USRVWebViewApp

static USRVWebViewApp *currentApp = NULL;

+ (USRVWebViewApp *)getCurrentApp {
    return currentApp;
}

+ (void)setCurrentApp:(USRVWebViewApp *)webViewApp {
    currentApp = webViewApp;
}

+ (void)create:(USRVConfiguration *)configuration; {
    [NSURLProtocol registerClass:[USRVURLProtocol class]];
    USRVWebViewApp *webViewApp = [[USRVWebViewApp alloc] initWithConfiguration:configuration];

    dispatch_sync(dispatch_get_main_queue(), ^(void) {
        UIWebView *webView = NULL;
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1024,768)];
        webView.mediaPlaybackRequiresUserAction = NO;
        webView.allowsInlineMediaPlayback = YES;
        [webView setBackgroundColor:[UIColor clearColor]];
        [webView setOpaque:false];
        webView.scrollView.bounces = NO;
        [webViewApp setWebView:webView];
        NSString * const localWebViewUrl = [USRVSdkProperties getLocalWebViewFile];
        NSString *queryString = [NSString stringWithFormat:@"%1$@?platform=ios&origin=%2$@", localWebViewUrl, [USRVWebViewApp urlEncode:[configuration webViewUrl]]];
        
        if (configuration.webViewVersion) {
            queryString = [queryString stringByAppendingString:[NSString stringWithFormat:@"&version=%1@", [USRVWebViewApp urlEncode:configuration.webViewVersion]]];
        }
        
        [(UIWebView *)[webViewApp webView] loadData:[NSData dataWithContentsOfFile:localWebViewUrl] MIMEType:@"text/html" textEncodingName:@"utf-8" baseURL:[NSURL URLWithString:queryString]];

        [webViewApp createBackgroundView];
        [webViewApp.backgroundView placeViewToBackground];
        [webViewApp placeWebViewToBackgroundView];
    });

    [USRVWebViewApp setCurrentApp:webViewApp];
}

+ (NSString *)urlEncode:(NSString *)url {
    NSString *unreserved = @"-._";
    NSMutableCharacterSet *allowed = [NSMutableCharacterSet alphanumericCharacterSet];
    [allowed addCharactersInString:unreserved];
    
    return [url stringByAddingPercentEncodingWithAllowedCharacters:allowed];
}

- (instancetype)initWithConfiguration:(USRVConfiguration *)configuration {
    self = [super init];
    
    if (self) {
        [self setConfiguration:configuration];
        [USRVInvocation setClassTable:[configuration getWebAppApiClassList]];
    }
    
    return self;
}

- (void)invokeJavascriptMethod:(NSString *)methodName className:(NSString *)className params:(NSArray *)params {
    BOOL isValid = [NSJSONSerialization isValidJSONObject:params];
    
    if (isValid) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
        NSString *paramStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *javaScriptString = [[NSString alloc] initWithFormat:@"window.%@.%@(%@);", className, methodName, paramStr];
        USRVLogDebug(@"JS_STRING: %@", javaScriptString);
        [self invokeJavascriptString:javaScriptString];
    }
    else {
        USRVLogError(@"FATAL_ERROR: Tried to invoke javascript with data that could not be parsed to JSON: %@", [params description]);
    }
}

- (void)invokeJavascriptString:(NSString *)javaScriptString {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.webView) {
            [(UIWebView *)self.webView stringByEvaluatingJavaScriptFromString:javaScriptString];
        }
    });
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
            USRVNativeCallback *nativeCallback = [[USRVNativeCallback alloc] initWithCallback:callback receiverClass:receiverClass];
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

- (BOOL)invokeCallback:(USRVInvocation *)invocation {
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
        USRVLogDebug(@"WebApp not loaded!");
    }

    return false;
}

- (void)addCallback:(USRVNativeCallback *)callback {
    if (callback) {
        if (!self.nativeCallbacks) {
            self.nativeCallbacks = [[NSMutableDictionary alloc] init];
        }

        [self.nativeCallbacks setObject:callback forKey:[callback callbackId]];
    }
}

- (void)removeCallback:(USRVNativeCallback *)callback {
    if (self.nativeCallbacks && callback) {
        [self.nativeCallbacks removeObjectForKey:[callback callbackId]];
    }
}

- (USRVNativeCallback *)getCallbackWithId:(NSString *)callbackId {
    if (self.nativeCallbacks && callbackId) {
        return [self.nativeCallbacks objectForKey:callbackId];
    }

    return NULL;
}

- (void)placeWebViewToBackgroundView {
    if (self.webView && self.backgroundView) {
        if ([self.webView superview]) {
            [self.webView removeFromSuperview];
        }

        [self.webView setHidden:YES];
        [self.backgroundView addSubview:self.webView];
    }
}

- (void)createBackgroundView {
    self.backgroundView = [[USRVWebViewBackgroundView alloc] initWithFrame:CGRectMake(0, 0, 1024,768)];
    [self.backgroundView setBackgroundColor:[UIColor clearColor]];
}

@end
