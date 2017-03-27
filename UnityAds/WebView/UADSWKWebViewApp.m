#import "UADSWKWebViewApp.h"
#import "UADSDevice.h"
#import "UADSSdkProperties.h"
#import "UADSWebViewMethodInvokeHandler.h"
#import <dlfcn.h>
#import <objc/runtime.h>

@interface UADSWKWebViewApp ()

@property (nonatomic, assign) SEL evaluateJavaScriptSelector;
@property (nonatomic, assign) void (*evaluateJavaScriptFunc)(id, SEL, NSString *, id);

@end

@implementation UADSWKWebViewApp

+ (void)create:(UADSConfiguration *)configuration {
    UADSLogDebug(@"CREATING WKWEBVIEWAPP");
    NSString *frameworkLocation;
    
    UADSWKWebViewApp *webViewApp = [[UADSWKWebViewApp alloc] initWithConfiguration:configuration];

    if (![UADSWKWebViewApp isFrameworkPresent]) {
        UADSLogDebug(@"WebKit framework not present, trying to load it");
        if ([UADSDevice isSimulator]) {
            NSString *frameworkPath = [[NSProcessInfo processInfo] environment][@"DYLD_FALLBACK_FRAMEWORK_PATH"];
            if (frameworkPath) {
                frameworkLocation = [NSString pathWithComponents:@[frameworkPath, @"WebKit.framework", @"WebKit"]];
            }
        }
        else {
            frameworkLocation = [NSString stringWithFormat:@"/System/Library/Frameworks/WebKit.framework/WebKit"];
        }

        dlopen([frameworkLocation cStringUsingEncoding:NSUTF8StringEncoding], RTLD_LAZY);

        if (![UADSWKWebViewApp isFrameworkPresent]) {
            UADSLogError(@"WKWebKit still not present!");
            return;
        }
        else {
            UADSLogError(@"Succesfully loaded WKWebKit framework");
        }
    }
    else {
        UADSLogDebug(@"WebKit framework already present");
    }

    dispatch_sync(dispatch_get_main_queue(), ^(void) {
        id wkConfiguration = [UADSWKWebViewApp getObjectFromClass:"WKWebViewConfiguration"];
        if (wkConfiguration) {
            wkConfiguration = [UADSWKWebViewApp addUserContentControllerMessageHandlers:wkConfiguration delegate:webViewApp handledMessages:@[@"handleInvocation", @"handleCallback"]];
        
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
                UADSLogDebug(@"Called setAllowsInlineMediaPlayback")
            }
        }

        SEL setMediaPlaybackRequiresUserActionSelector = NSSelectorFromString(@"setMediaPlaybackRequiresUserAction:");
        if ([wkConfiguration respondsToSelector:setMediaPlaybackRequiresUserActionSelector]) {
            IMP setMediaPlaybackRequiresUserActionImp = [wkConfiguration methodForSelector:setMediaPlaybackRequiresUserActionSelector];
            if (setMediaPlaybackRequiresUserActionImp) {
                void (*setMediaPlaybackRequiresUserActionFunc)(id, SEL, BOOL) = (void *)setMediaPlaybackRequiresUserActionImp;
                setMediaPlaybackRequiresUserActionFunc(wkConfiguration, setMediaPlaybackRequiresUserActionSelector, false);
                UADSLogDebug(@"Called setMediaPlaybackRequiresUserAction");
            }
        }

        SEL setMediaTypesRequiringUserActionForPlaybackSelector = NSSelectorFromString(@"setMediaTypesRequiringUserActionForPlayback:");
        if ([wkConfiguration respondsToSelector:setMediaTypesRequiringUserActionForPlaybackSelector]) {
            IMP setMediaTypesRequiringUserActionForPlaybackImp = [wkConfiguration methodForSelector:setMediaTypesRequiringUserActionForPlaybackSelector];
            if (setMediaTypesRequiringUserActionForPlaybackImp) {
                void (*setMediaTypesRequiringUserActionForPlaybackFunc)(id, SEL, int) = (void *)setMediaTypesRequiringUserActionForPlaybackImp;
                setMediaTypesRequiringUserActionForPlaybackFunc(wkConfiguration, setMediaTypesRequiringUserActionForPlaybackSelector, 0);
                UADSLogDebug(@"Called setMediaTypesRequiringUserActionForPlayback");
            }
        }

        id wkWebsiteDataStore = NSClassFromString(@"WKWebsiteDataStore");
        if(wkWebsiteDataStore) {
            SEL nonPersistentDataStoreSelector = NSSelectorFromString(@"nonPersistentDataStore");
            if([wkWebsiteDataStore respondsToSelector:nonPersistentDataStoreSelector]) {
                IMP nonPersistentDataStoreImp = [wkWebsiteDataStore methodForSelector:nonPersistentDataStoreSelector];
                id (*nonPersistentDataStoreFunc)() = (void *)nonPersistentDataStoreImp;
                id nonPersistentDataStore = nonPersistentDataStoreFunc();
                [wkConfiguration setValue:nonPersistentDataStore forKey:@"websiteDataStore"];
            }
        } else {
            return;
        }

        id webView = [UADSWKWebViewApp initWebView:"WKWebView" frame:CGRectMake(0, 0, 1024, 768) configuration:wkConfiguration];

        if (webView == NULL) {
            return;
        }

        UADSLogDebug(@"Got WebView");
        [(UIView *)webView setBackgroundColor:[UIColor clearColor]];
        [(UIView *)webView setOpaque:false];
        [webView setValue:@NO forKeyPath:@"scrollView.bounces"];

        [webViewApp setWebView:webView];

        NSString * const localWebViewUrl = [UADSSdkProperties getLocalWebViewFile];
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
                UADSLogDebug(@"Cached selector and function for evaluateJavaScript");
            }
            else {
                return;
            }
        }
        else {
            return;
        }

        if ([UADSWKWebViewApp loadFileUrl:webView url:url allowReadAccess:[NSURL fileURLWithPath:[UADSSdkProperties getCacheDirectory]]]) {
            [webViewApp createBackgroundView];
            [webViewApp.backgroundView placeViewToBackground];
            [webViewApp placeWebViewToBackgroundView];
            [UADSWebViewApp setCurrentApp:webViewApp];
        }
    });
}

+ (id)addUserContentControllerMessageHandlers:(id)wkConfiguration delegate:(id)delegate handledMessages:(NSArray *)handledMessages {
    id userContentController = [wkConfiguration valueForKey:@"userContentController"];
    if (userContentController) {
        UADSLogDebug(@"Got userContentController");

        SEL addScriptMessageHandlerSelector = NSSelectorFromString(@"addScriptMessageHandler:name:");
        if ([userContentController respondsToSelector:addScriptMessageHandlerSelector]) {
            UADSLogDebug(@"Responds to selector");
            IMP addScriptMessageHandlerImp = [userContentController methodForSelector:addScriptMessageHandlerSelector];
            if (addScriptMessageHandlerImp) {
                UADSLogDebug(@"Got addScriptHandler implementation");
                void (*addScriptMessageHandlerFunc)(id, SEL, id, NSString *) = (void *)addScriptMessageHandlerImp;

                for (NSString *message in handledMessages) {
                    UADSLogDebug(@"Setting handler for: %@", message);
                    addScriptMessageHandlerFunc(userContentController, addScriptMessageHandlerSelector, delegate, message);
                }

                [wkConfiguration setValue:userContentController forKey:@"userContentController"];

                return wkConfiguration;
            }
        }
    }

    return NULL;
}

+ (id)initWebView:(const char *)className frame:(CGRect)frame configuration:(id)configuration {
    id webViewClass = objc_getClass(className);
    if (webViewClass) {
        id webViewAlloc = [webViewClass alloc];
        SEL initSelector = NSSelectorFromString(@"initWithFrame:configuration:");
        if ([webViewAlloc respondsToSelector:initSelector]) {
            UADSLogDebug(@"WebView responds to init selector");
            IMP initImp = [webViewAlloc methodForSelector:initSelector];
            if (initImp) {
                UADSLogDebug(@"Got init implementation");
                id (*initFunc)(id, SEL, CGRect, id) = (void *)initImp;
                return initFunc(webViewAlloc, initSelector, frame, configuration);
            }
        }
    }

    return NULL;
}

+ (void)loadUrl:(id)webView url:(NSURLRequest *)url {
    SEL loadFileUrlSelector = NSSelectorFromString(@"loadRequest:");
    if ([webView respondsToSelector:loadFileUrlSelector]) {
        UADSLogDebug(@"WebView responds to loadFileURL selector");
        IMP loadFileUrlImp = [webView methodForSelector:loadFileUrlSelector];
        if (loadFileUrlImp) {
            UADSLogDebug(@"Got loadFileURL implementation: %@", url);
            void (*loadFileUrlFunc)(id, SEL, NSURLRequest *) = (void *)loadFileUrlImp;
            loadFileUrlFunc(webView, loadFileUrlSelector, url);
        }
    }
}

+ (BOOL)loadFileUrl:(id)webView url:(NSURL *)url allowReadAccess:(NSURL *)allowReadAccess {
    SEL loadFileUrlSelector = NSSelectorFromString(@"loadFileURL:allowingReadAccessToURL:");
    if ([webView respondsToSelector:loadFileUrlSelector]) {
        UADSLogDebug(@"WebView responds to loadFileURL selector");
        IMP loadFileUrlImp = [webView methodForSelector:loadFileUrlSelector];
        if (loadFileUrlImp) {
            UADSLogDebug(@"Got loadFileURL implementation");
            void (*loadFileUrlFunc)(id, SEL, NSURL *, NSURL *) = (void *)loadFileUrlImp;
            UADSLogDebug(@"Trying to load fileURL: %@ and allowing readAccess to: %@", url, allowReadAccess);
            loadFileUrlFunc(webView, loadFileUrlSelector, url, allowReadAccess);

            return true;
        }
    }

    return false;
}

+ (id)getObjectFromClass:(const char *)className {
    id class = objc_getClass(className);
    NSString *classNameNSString = [NSString stringWithCString:className encoding:NSUTF8StringEncoding];

    if (class) {
        id object = [[class alloc] init];

        if (object) {
            UADSLogDebug(@"Succesfully created object for %@", classNameNSString);
            return object;
        }
    }

    UADSLogDebug(@"Couldn't create object for %@", classNameNSString);

    return NULL;
}

+ (BOOL)isFrameworkPresent {
    id wkWebKitClass = objc_getClass("WKWebView");

    if (wkWebKitClass) {
        return true;
    }

    return false;
}

- (void)invokeJavascriptString:(NSString *)javaScriptString {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.evaluateJavaScriptFunc && self.evaluateJavaScriptSelector) {
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
        NSError *err;
        data = [NSJSONSerialization dataWithJSONObject:body options:0 error:&err];

        if (err) {
            data = NULL;
        }
    }

    if (data) {
        UADSWebViewMethodInvokeHandler *handler = [[UADSWebViewMethodInvokeHandler alloc] init];
        [handler handleData:data invocationType:name];
    }
}

@end
