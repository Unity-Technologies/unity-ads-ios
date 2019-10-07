#import "USRVWebViewApp.h"
#import "USRVSdkProperties.h"
#import "USRVURLProtocol.h"
#import "USRVJsonUtilities.h"
#import "USRVDevice.h"
#import "USRVSdkProperties.h"
#import "USRVWebViewMethodInvokeHandler.h"
#import "USRVWKWebViewUtilities.h"
#import "USRVJsonUtilities.h"
#import <dlfcn.h>
#import <objc/runtime.h>

@interface USRVWebViewApp ()

@property (nonatomic, assign) SEL evaluateJavaScriptSelector;
@property (nonatomic, assign) void (*evaluateJavaScriptFunc)(id, SEL, NSString *, id);

@end

@implementation USRVWebViewApp

static USRVWebViewApp *currentApp = NULL;

+ (USRVWebViewApp *)getCurrentApp {
    return currentApp;
}

+ (void)setCurrentApp:(USRVWebViewApp *)webViewApp {
    currentApp = webViewApp;
}

+ (void)create:(USRVConfiguration *)configuration view:(UIView *)view {
    USRVLogDebug(@"CREATING WKWEBVIEWAPP");
    NSString *frameworkLocation;
    
    USRVWebViewApp *webViewApp = [[USRVWebViewApp alloc] initWithConfiguration:configuration];
    
    if (![USRVWKWebViewUtilities isFrameworkPresent]) {
        USRVLogDebug(@"WebKit framework not present, trying to load it");
        if ([USRVDevice isSimulator]) {
            NSString *frameworkPath = [[NSProcessInfo processInfo] environment][@"DYLD_FALLBACK_FRAMEWORK_PATH"];
            if (frameworkPath) {
                frameworkLocation = [NSString pathWithComponents:@[frameworkPath, @"WebKit.framework", @"WebKit"]];
            }
        }
        else {
            frameworkLocation = [NSString stringWithFormat:@"/System/Library/Frameworks/WebKit.framework/WebKit"];
        }
        
        dlopen([frameworkLocation cStringUsingEncoding:NSUTF8StringEncoding], RTLD_LAZY);
        
        if (![USRVWKWebViewUtilities isFrameworkPresent]) {
            USRVLogError(@"WKWebKit still not present!");
            return;
        }
        else {
            USRVLogDebug(@"Succesfully loaded WKWebKit framework");
        }
    }
    else {
        USRVLogDebug(@"WebKit framework already present");
    }
    
    dispatch_sync(dispatch_get_main_queue(), ^(void) {
        id wkConfiguration = [USRVWKWebViewUtilities getObjectFromClass:"WKWebViewConfiguration"];
        if (wkConfiguration) {
            wkConfiguration = [USRVWKWebViewUtilities addUserContentControllerMessageHandlers:wkConfiguration delegate:webViewApp handledMessages:@[@"handleInvocation", @"handleCallback"]];
            
            if (!wkConfiguration) {
                return;
            }
        }
        else {
            return;
        }
        
        SEL setAllowsInlineMediaPlaybackSelector = NSSelectorFromString(@"setAllowsInlineMediaPlayback:");
        if ([wkConfiguration respondsToSelector:setAllowsInlineMediaPlaybackSelector]) {
            IMP setAllowsInlineMediaPlaybackImp = [wkConfiguration methodForSelector:setAllowsInlineMediaPlaybackSelector];
            if (setAllowsInlineMediaPlaybackImp) {
                void (*setAllowsInlineMediaPlaybackFunc)(id, SEL, BOOL) = (void *)setAllowsInlineMediaPlaybackImp;
                setAllowsInlineMediaPlaybackFunc(wkConfiguration, setAllowsInlineMediaPlaybackSelector, true);
                USRVLogDebug(@"Called setAllowsInlineMediaPlayback")
            }
        }
        
        SEL setMediaPlaybackRequiresUserActionSelector = NSSelectorFromString(@"setMediaPlaybackRequiresUserAction:");
        if ([wkConfiguration respondsToSelector:setMediaPlaybackRequiresUserActionSelector]) {
            IMP setMediaPlaybackRequiresUserActionImp = [wkConfiguration methodForSelector:setMediaPlaybackRequiresUserActionSelector];
            if (setMediaPlaybackRequiresUserActionImp) {
                void (*setMediaPlaybackRequiresUserActionFunc)(id, SEL, BOOL) = (void *)setMediaPlaybackRequiresUserActionImp;
                setMediaPlaybackRequiresUserActionFunc(wkConfiguration, setMediaPlaybackRequiresUserActionSelector, false);
                USRVLogDebug(@"Called setMediaPlaybackRequiresUserAction");
            }
        }
        
        SEL setMediaTypesRequiringUserActionForPlaybackSelector = NSSelectorFromString(@"setMediaTypesRequiringUserActionForPlayback:");
        if ([wkConfiguration respondsToSelector:setMediaTypesRequiringUserActionForPlaybackSelector]) {
            IMP setMediaTypesRequiringUserActionForPlaybackImp = [wkConfiguration methodForSelector:setMediaTypesRequiringUserActionForPlaybackSelector];
            if (setMediaTypesRequiringUserActionForPlaybackImp) {
                void (*setMediaTypesRequiringUserActionForPlaybackFunc)(id, SEL, int) = (void *)setMediaTypesRequiringUserActionForPlaybackImp;
                setMediaTypesRequiringUserActionForPlaybackFunc(wkConfiguration, setMediaTypesRequiringUserActionForPlaybackSelector, 0);
                USRVLogDebug(@"Called setMediaTypesRequiringUserActionForPlayback");
            }
        }
        
        id wkWebsiteDataStore = NSClassFromString(@"WKWebsiteDataStore");
        if(wkWebsiteDataStore) {
            SEL nonPersistentDataStoreSelector = NSSelectorFromString(@"nonPersistentDataStore");
            if([wkWebsiteDataStore respondsToSelector:nonPersistentDataStoreSelector]) {
                IMP nonPersistentDataStoreImp = [wkWebsiteDataStore methodForSelector:nonPersistentDataStoreSelector];
                id (*nonPersistentDataStoreFunc)(void) = (void *)nonPersistentDataStoreImp;
                id nonPersistentDataStore = nonPersistentDataStoreFunc();
                [wkConfiguration setValue:nonPersistentDataStore forKey:@"websiteDataStore"];
            }
        } else {
            return;
        }
        
        id webView = view;

        if (webView == NULL) {
            webView = [USRVWKWebViewUtilities initWebView:"WKWebView" frame:CGRectMake(0, 0, 1024, 768) configuration:wkConfiguration];
        }
        
        if (webView == NULL) {
            return;
        }
        
        USRVLogDebug(@"Got WebView");
        [(UIView *)webView setBackgroundColor:[UIColor clearColor]];
        [(UIView *)webView setOpaque:false];
        [webView setValue:@NO forKeyPath:@"scrollView.bounces"];
        
        [webViewApp setWebView:webView];
        
        NSString * const localWebViewUrl = [USRVSdkProperties getLocalWebViewFile];
        NSURL *url = [NSURL fileURLWithPath:localWebViewUrl];
        NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
        NSMutableArray *queryItems = [components.queryItems mutableCopy];
        if (!queryItems) {
            queryItems = [[NSMutableArray alloc] init];
        }
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"platform" value:@"ios"]];
        [queryItems addObject:[NSURLQueryItem queryItemWithName:@"origin" value:[configuration webViewUrl]]];
        
        if (configuration.webViewVersion) {
            [queryItems addObject:[NSURLQueryItem queryItemWithName:@"version" value:configuration.webViewVersion]];
        }
        
        components.queryItems = queryItems;
        url = components.URL;
        
        webViewApp.evaluateJavaScriptSelector = NSSelectorFromString(@"evaluateJavaScript:completionHandler:");
        if ([webView respondsToSelector:webViewApp.evaluateJavaScriptSelector]) {
            IMP evaluateJavaScriptImp = [webView methodForSelector:webViewApp.evaluateJavaScriptSelector];
            if (evaluateJavaScriptImp) {
                webViewApp.evaluateJavaScriptFunc = (void *)evaluateJavaScriptImp;
                USRVLogDebug(@"Cached selector and function for evaluateJavaScript");
            }
            else {
                return;
            }
        }
        else {
            return;
        }
        
        if ([USRVWKWebViewUtilities loadFileUrl:webView url:url allowReadAccess:[NSURL fileURLWithPath:[USRVSdkProperties getCacheDirectory]]]) {
            [webViewApp createBackgroundView];
            [webViewApp.backgroundView placeViewToBackground];
            [webViewApp placeWebViewToBackgroundView];
            [USRVWebViewApp setCurrentApp:webViewApp];
        }
    });
}


- (void)invokeJavascriptString:(NSString *)javaScriptString {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.webView && self.evaluateJavaScriptFunc && self.evaluateJavaScriptSelector) {
            self.evaluateJavaScriptFunc(self.webView, self.evaluateJavaScriptSelector, javaScriptString, nil);
        }
    });
}

- (void)userContentController:(id)userContentController didReceiveScriptMessage:(id)message {
    NSString *name = [message valueForKey:@"name"];
    id body = [message valueForKey:@"body"];
    NSData *data = NULL;
    
    if ([body isKindOfClass:[NSString class]]) {
        data = [body dataUsingEncoding:NSUTF8StringEncoding];
    }
    else if ([body isKindOfClass:[NSDictionary class]]) {
        data = [USRVJsonUtilities dataWithJSONObject:body options:0 error:nil];
    }
    
    if (data) {
        USRVWebViewMethodInvokeHandler *handler = [[USRVWebViewMethodInvokeHandler alloc] init];
        [handler handleData:data invocationType:name];
    }
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
    NSData *jsonData = [USRVJsonUtilities dataWithJSONObject:params options:0 error:nil];
    if (jsonData) {
        NSString *paramStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *javaScriptString = [[NSString alloc] initWithFormat:@"window.%@.%@(%@);", className, methodName, paramStr];
        USRVLogDebug(@"JS_STRING: %@", javaScriptString);
        [self invokeJavascriptString:javaScriptString];
    } else {
        USRVLogError(@"FATAL_ERROR: Tried to invoke javascript with data that could not be parsed to JSON: %@", [params description]);
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

-(BOOL)invokeMethod:(NSString *)methodName className:(NSString *)className context:(NSString *)context callback:(USRVNativeCallbackBlock)callback params:(NSArray *)params {
    USRVNativeCallback *nativeCallback = [[USRVNativeCallback alloc] initWithCallback:callback context:context];
    return [self invokeMethod:methodName className:className params:params nativeCallback:nativeCallback];
}

- (BOOL)invokeMethod:(NSString *)methodName className:(NSString *)className receiverClass:(NSString *)receiverClass callback:(NSString *)callback params:(NSArray *)params {
    USRVNativeCallback *nativeCallback = nil;
    if (receiverClass && callback) {
        nativeCallback = [[USRVNativeCallback alloc] initWithMethod:callback receiverClass:receiverClass];
    }

    return [self invokeMethod:methodName className:className params:params nativeCallback:nativeCallback];
}

- (BOOL)invokeMethod:(NSString *)methodName className:(NSString *)className params:(NSArray *)params nativeCallback:(USRVNativeCallback *)nativeCallback {
    if (self.webAppLoaded) {
        NSMutableArray *combinedParams = [[NSMutableArray alloc] init];
        [combinedParams addObject:className];
        [combinedParams addObject:methodName];

        if ([nativeCallback callbackId]) {
            [self addCallback:nativeCallback];
            [combinedParams addObject:[nativeCallback callbackId]];
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
