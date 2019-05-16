#import "USRVWKWebViewApp.h"
#import "USRVDevice.h"
#import "USRVSdkProperties.h"
#import "USRVWebViewMethodInvokeHandler.h"
#import "USRVWKWebViewUtilities.h"
#import <dlfcn.h>
#import <objc/runtime.h>

@interface USRVWKWebViewApp ()

@property (nonatomic, assign) SEL evaluateJavaScriptSelector;
@property (nonatomic, assign) void (*evaluateJavaScriptFunc)(id, SEL, NSString *, id);

@end

@implementation USRVWKWebViewApp

+ (void)create:(USRVConfiguration *)configuration {
    USRVLogDebug(@"CREATING WKWEBVIEWAPP");
    NSString *frameworkLocation;
    
    USRVWKWebViewApp *webViewApp = [[USRVWKWebViewApp alloc] initWithConfiguration:configuration];

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
                id (*nonPersistentDataStoreFunc)() = (void *)nonPersistentDataStoreImp;
                id nonPersistentDataStore = nonPersistentDataStoreFunc();
                [wkConfiguration setValue:nonPersistentDataStore forKey:@"websiteDataStore"];
            }
        } else {
            return;
        }

        id webView = [USRVWKWebViewUtilities initWebView:"WKWebView" frame:CGRectMake(0, 0, 1024, 768) configuration:wkConfiguration];

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
        NSError *err;
        data = [NSJSONSerialization dataWithJSONObject:body options:0 error:&err];

        if (err) {
            data = NULL;
        }
    }

    if (data) {
        USRVWebViewMethodInvokeHandler *handler = [[USRVWebViewMethodInvokeHandler alloc] init];
        [handler handleData:data invocationType:name];
    }
}

@end
