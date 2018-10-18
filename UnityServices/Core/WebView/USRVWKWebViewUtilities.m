#import <objc/runtime.h>
#import "USRVWKWebViewApp.h"
#import "USRVWKWebViewUtilities.h"


@implementation USRVWKWebViewUtilities {

}

+ (id)initWebView:(const char *)className frame:(CGRect)frame configuration:(id)configuration {
    id webViewClass = objc_getClass(className);
    if (webViewClass) {
        id webViewAlloc = [webViewClass alloc];
        SEL initSelector = NSSelectorFromString(@"initWithFrame:configuration:");
        if ([webViewAlloc respondsToSelector:initSelector]) {
            USRVLogDebug(@"WebView responds to init selector");
            IMP initImp = [webViewAlloc methodForSelector:initSelector];
            if (initImp) {
                USRVLogDebug(@"Got init implementation");
                id (*initFunc)(id, SEL, CGRect, id) = (void *)initImp;
                return initFunc(webViewAlloc, initSelector, frame, configuration);
            }
        }
    }

    return NULL;
}

+ (void)removeUserContentControllerMessageHandler:(id)wkConfiguration handledMessages:(NSArray *)handledMessages {
    id userContentController = [wkConfiguration valueForKey:@"userContentController"];
    if (userContentController) {
        USRVLogDebug(@"Got userContentController");

        SEL removeScriptMessageHandlerSelector = NSSelectorFromString(@"removeScriptMessageHandlerForName:");
        if ([userContentController respondsToSelector:removeScriptMessageHandlerSelector]) {
            USRVLogDebug(@"Responds to selector");
            IMP removeScriptMessageHandlerImp = [userContentController methodForSelector:removeScriptMessageHandlerSelector];
            if (removeScriptMessageHandlerImp) {
                USRVLogDebug(@"Got addScriptHandler implementation");
                void (*removeScriptMessageHandlerFunc)(id, SEL, NSString *) = (void *)removeScriptMessageHandlerImp;
                for (NSString *message in handledMessages) {
                    USRVLogDebug(@"Removing handler for: %@", message);
                    removeScriptMessageHandlerFunc(userContentController, removeScriptMessageHandlerSelector, message);
                }
            }
        }
    }
}

+ (id)addUserContentControllerMessageHandlers:(id)wkConfiguration delegate:(id)delegate handledMessages:(NSArray *)handledMessages {
    id userContentController = [wkConfiguration valueForKey:@"userContentController"];
    if (userContentController) {
        USRVLogDebug(@"Got userContentController");

        SEL addScriptMessageHandlerSelector = NSSelectorFromString(@"addScriptMessageHandler:name:");
        if ([userContentController respondsToSelector:addScriptMessageHandlerSelector]) {
            USRVLogDebug(@"Responds to selector");
            IMP addScriptMessageHandlerImp = [userContentController methodForSelector:addScriptMessageHandlerSelector];
            if (addScriptMessageHandlerImp) {
                USRVLogDebug(@"Got addScriptHandler implementation");
                void (*addScriptMessageHandlerFunc)(id, SEL, id, NSString *) = (void *)addScriptMessageHandlerImp;

                for (NSString *message in handledMessages) {
                    USRVLogDebug(@"Setting handler for: %@", message);
                    addScriptMessageHandlerFunc(userContentController, addScriptMessageHandlerSelector, delegate, message);
                }

                [wkConfiguration setValue:userContentController forKey:@"userContentController"];

                return wkConfiguration;
            }
        }
    }

    return NULL;
}

+ (void)loadUrl:(id)webView url:(NSURLRequest *)url {
    SEL loadFileUrlSelector = NSSelectorFromString(@"loadRequest:");
    if ([webView respondsToSelector:loadFileUrlSelector]) {
        USRVLogDebug(@"WebView responds to loadFileURL selector");
        IMP loadFileUrlImp = [webView methodForSelector:loadFileUrlSelector];
        if (loadFileUrlImp) {
            USRVLogDebug(@"Got loadFileURL implementation: %@", url);
            void (*loadFileUrlFunc)(id, SEL, NSURLRequest *) = (void *)loadFileUrlImp;
            loadFileUrlFunc(webView, loadFileUrlSelector, url);
        }
    }
}

+ (void)evaluateJavaScript:(id)webView string:(NSString *)string {
    SEL evaluateJavaScriptSelector = NSSelectorFromString(@"evaluateJavaScript:completionHandler:");
    if ([webView respondsToSelector:evaluateJavaScriptSelector]) {
        USRVLogDebug(@"WebView responds to evaluateJavaScript selector");
        IMP evaluateJavaScriptImp = [webView methodForSelector:evaluateJavaScriptSelector];
        if (evaluateJavaScriptImp) {
            USRVLogDebug(@"Got evaluateJavaScript implementation: %@", string);
            void (*evaluateJavaScriptFunc)(id, SEL, NSString *, void (^)(id, NSError *error)) = (void *)evaluateJavaScriptImp;
            evaluateJavaScriptFunc(webView, evaluateJavaScriptSelector, string, nil);
        }
    }
}

+ (BOOL)loadFileUrl:(id)webView url:(NSURL *)url allowReadAccess:(NSURL *)allowReadAccess {
    SEL loadFileUrlSelector = NSSelectorFromString(@"loadFileURL:allowingReadAccessToURL:");
    if ([webView respondsToSelector:loadFileUrlSelector]) {
        USRVLogDebug(@"WebView responds to loadFileURL selector");
        IMP loadFileUrlImp = [webView methodForSelector:loadFileUrlSelector];
        if (loadFileUrlImp) {
            USRVLogDebug(@"Got loadFileURL implementation");
            void (*loadFileUrlFunc)(id, SEL, NSURL *, NSURL *) = (void *)loadFileUrlImp;
            USRVLogDebug(@"Trying to load fileURL: %@ and allowing readAccess to: %@", url, allowReadAccess);
            loadFileUrlFunc(webView, loadFileUrlSelector, url, allowReadAccess);

            return true;
        }
    }

    return false;
}

+ (BOOL)loadData:(id)webView data:(NSData *)data mimeType:(NSString *)mimeType encoding:(NSString *)encoding baseUrl:(NSURL *)baseUrl {
    // NOTE: this selector is available in iOS9+
    SEL loadDataSelector = NSSelectorFromString(@"loadData:MIMEType:characterEncodingName:baseURL:");
    if ([webView respondsToSelector:loadDataSelector]) {
        USRVLogDebug(@"WebView responds to loadFileURL selector");
        IMP loadDataImp = [webView methodForSelector:loadDataSelector];
        if (loadDataImp) {
            USRVLogDebug(@"Got loadData implementation");
            void (*loadDataFunc)(id, SEL, NSData *, NSString *, NSString *, NSURL *) = (void *)loadDataImp;
            USRVLogDebug(@"Trying to load data with base url: %@", baseUrl.absoluteString);
            loadDataFunc(webView, loadDataSelector, data, mimeType, encoding, baseUrl);

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
            USRVLogDebug(@"Succesfully created object for %@", classNameNSString);
            return object;
        }
    }

    USRVLogDebug(@"Couldn't create object for %@", classNameNSString);

    return NULL;
}

+ (BOOL)isFrameworkPresent {
    id wkWebKitClass = objc_getClass("WKWebView");

    if (wkWebKitClass) {
        return true;
    }

    return false;
}
@end
