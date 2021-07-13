#import "UADSWebPlayerView.h"
#import "USRVWebViewApp.h"
#import "USRVDevice.h"
#import "UADSWebPlayerEvent.h"
#import "UADSWebPlayerSettings.h"
#import "USRVWebViewEventCategory.h"
#import "USRVWKWebViewUtilities.h"
#import "USRVJsonUtilities.h"
#import <dlfcn.h>
#import <objc/runtime.h>
#import "UADSWebPlayerBridge.h"

@interface UADSWebPlayerView ()
@property (nonatomic, strong) id internalWebView;
@property (nonatomic, retain) id wkConfiguration;
@property (nonatomic, retain) NSDictionary *webPlayerSettings;
@property (nonatomic, retain) NSDictionary *webPlayerEventSettings;
@property (nonatomic, retain) NSString *viewId;

- (void)createWKWebPlayer;

@end

@implementation UADSWebPlayerView

- (instancetype)initWithFrame: (CGRect)frame viewId: (NSString *)viewId webPlayerSettings: (NSDictionary *)webPlayerSettings {
    self = [super initWithFrame: frame];

    if (self) {
        _viewId = viewId;
        self.accessibilityElementsHidden = true;
        [self setWebPlayerSettings: webPlayerSettings];
        [self createWKWebPlayer];
        [self constructLayout];
    }

    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self sendFrameUpdate];
}

- (void)sendFrameUpdate {
    // Push the new frame to webview
    if (self.window) {
        CGRect frameRelativeToWindow = [self convertRect: self.frame
                                                  toView: self.window];

        if (self.viewId) {
            [UADSWebPlayerBridge sendFrameUpdate: self.viewId
                                           frame: frameRelativeToWindow
                                           alpha: self.alpha];
        }
    }
}

- (void)constructLayout {
    if ([self.internalWebView isKindOfClass: [UIView class]]) {
        UIView *webview = (UIView *)self.internalWebView;
        webview.translatesAutoresizingMaskIntoConstraints = NO;
        NSDictionary *views = @{
            @"webview": webview
        };
        [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"H:|[webview]|"
                                                                      options: 0
                                                                      metrics: nil
                                                                        views: views]];
        [self addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: @"V:|[webview]|"
                                                                      options: 0
                                                                      metrics: nil
                                                                        views: views]];
    }
}

- (void)destroy {
    [self.internalWebView setValue: nil
                        forKeyPath : @"navigationDelegate"];
    [self.internalWebView setValue: nil
                        forKeyPath : @"UIDelegate"];

    if (self.wkConfiguration) {
        [USRVWKWebViewUtilities removeUserContentControllerMessageHandler: self.wkConfiguration
                                                          handledMessages: @[@"sendEvent"]];
    }

    self.internalWebView = nil;
    self.wkConfiguration = nil;
}

- (void)setFrame: (CGRect)frame {
    [super setFrame: frame];
    [_internalWebView setFrame: super.bounds];
}

- (void)loadUrl: (NSString *)url {
    [USRVWKWebViewUtilities loadUrl: _internalWebView
                                url: [NSURLRequest requestWithURL: [NSURL URLWithString: url]]];
}

- (void)loadData: (NSString *)data mimeType: (NSString *)mimeType encoding: (NSString *)encoding {
    [self loadData: data
          mimeType: mimeType
          encoding: encoding
           baseUrl: @""];
}

- (void)loadData: (NSString *)data mimeType: (NSString *)mimeType encoding: (NSString *)encoding baseUrl: (NSString *)baseUrl {
    [USRVWKWebViewUtilities loadData: _internalWebView
                                data: [data dataUsingEncoding: NSUTF8StringEncoding]
                            mimeType: mimeType
                            encoding: encoding
                             baseUrl: [NSURL URLWithString: baseUrl]];
}

- (void)setWebPlayerSettings: (NSDictionary *)webPlayerSettings {
    _webPlayerSettings = webPlayerSettings;
}

- (void)setEventSettings: (NSDictionary *)eventSettings {
    _webPlayerEventSettings = eventSettings;
}

- (void)receiveEvent: (NSString *)data {
    NSData *jsonData = [USRVJsonUtilities dataWithJSONObject: data
                                                     options: 0
                                                       error: nil];

    if (jsonData) {
        NSString *jsonString = [[NSString alloc] initWithData: jsonData
                                                     encoding: NSUTF8StringEncoding];
        NSString *stringForEvaluation = [NSString stringWithFormat: @"javascript:window.nativebridge.receiveEvent(%@)", jsonString];

        [USRVWKWebViewUtilities evaluateJavaScript: _internalWebView
                                            string: stringForEvaluation];
    }
}

- (void)createWKWebPlayer {
    USRVLogDebug(@"CREATING WKWEBVIEWAPP");
    NSString *frameworkLocation;

    if (![USRVWKWebViewUtilities isFrameworkPresent]) {
        USRVLogDebug(@"WebKit framework not present, trying to load it");

        if ([USRVDevice isSimulator]) {
            NSString *frameworkPath = [[NSProcessInfo processInfo] environment][@"DYLD_FALLBACK_FRAMEWORK_PATH"];

            if (frameworkPath) {
                frameworkLocation = [NSString pathWithComponents: @[frameworkPath, @"WebKit.framework", @"WebKit"]];
            }
        } else {
            frameworkLocation = [NSString stringWithFormat: @"/System/Library/Frameworks/WebKit.framework/WebKit"];
        }

        dlopen([frameworkLocation cStringUsingEncoding: NSUTF8StringEncoding], RTLD_LAZY);

        if (![USRVWKWebViewUtilities isFrameworkPresent]) {
            USRVLogError(@"WKWebKit still not present!");
            return;
        } else {
            USRVLogDebug(@"Succesfully loaded WKWebKit framework");
        }
    } else {
        USRVLogDebug(@"WebKit framework already present");
    }

    id wkConfiguration = [USRVWKWebViewUtilities getObjectFromClass: "WKWebViewConfiguration"];

    if (wkConfiguration) {
        wkConfiguration = [USRVWKWebViewUtilities addUserContentControllerMessageHandlers: wkConfiguration
                                                                                 delegate: self
                                                                          handledMessages: @[@"sendEvent"]];

        if (!wkConfiguration) {
            return;
        }
    } else {
        return;
    }

    self.wkConfiguration = wkConfiguration;

    if ([self shouldSetWebPlayerSetting: kUnityAdsWebPlayerWebSettingsAllowsInlineMediaPlayback]) {
        SEL setAllowsInlineMediaPlaybackSelector = NSSelectorFromString(@"setAllowsInlineMediaPlayback:");

        if ([wkConfiguration respondsToSelector: setAllowsInlineMediaPlaybackSelector]) {
            IMP setAllowsInlineMediaPlaybackImp = [wkConfiguration methodForSelector: setAllowsInlineMediaPlaybackSelector];

            if (setAllowsInlineMediaPlaybackImp) {
                void (*setAllowsInlineMediaPlaybackFunc)(id, SEL, BOOL) = (void *)setAllowsInlineMediaPlaybackImp;
                setAllowsInlineMediaPlaybackFunc(wkConfiguration, setAllowsInlineMediaPlaybackSelector, [self boolValueForWebPlayerSetting: kUnityAdsWebPlayerWebSettingsAllowsInlineMediaPlayback]);
                USRVLogDebug(@"Called setAllowsInlineMediaPlayback")
            }
        }
    }

    if ([self shouldSetWebPlayerSetting: kUnityAdsWebPlayerWebSettingsMediaPlaybackAllowsAirPlay]) {
        SEL setMediaPlaybackAllowsAirPlaySelector = NSSelectorFromString(@"setAllowsAirPlayForMediaPlayback:");

        if ([wkConfiguration respondsToSelector: setMediaPlaybackAllowsAirPlaySelector]) {
            IMP setMediaPlaybackAllowsAirPlayImp = [wkConfiguration methodForSelector: setMediaPlaybackAllowsAirPlaySelector];

            if (setMediaPlaybackAllowsAirPlayImp) {
                void (*setMediaPlaybackAllowsAirPlayFunc)(id, SEL, BOOL) = (void *)setMediaPlaybackAllowsAirPlayImp;
                setMediaPlaybackAllowsAirPlayFunc(wkConfiguration, setMediaPlaybackAllowsAirPlaySelector, [self boolValueForWebPlayerSetting: kUnityAdsWebPlayerWebSettingsMediaPlaybackAllowsAirPlay]);
                USRVLogDebug(@"Called setAllowsAirPlayForMediaPlayback");
            }
        }
    }

    if ([self shouldSetWebPlayerSetting: kUnityAdsWebPlayerWebSettingsMediaPlaybackRequiresUserAction]) {
        SEL setMediaPlaybackRequiresUserActionSelector = NSSelectorFromString(@"setMediaPlaybackRequiresUserAction:");

        if ([wkConfiguration respondsToSelector: setMediaPlaybackRequiresUserActionSelector]) {
            IMP setMediaPlaybackRequiresUserActionImp = [wkConfiguration methodForSelector: setMediaPlaybackRequiresUserActionSelector];

            if (setMediaPlaybackRequiresUserActionImp) {
                void (*setMediaPlaybackRequiresUserActionFunc)(id, SEL, BOOL) = (void *)setMediaPlaybackRequiresUserActionImp;
                setMediaPlaybackRequiresUserActionFunc(wkConfiguration, setMediaPlaybackRequiresUserActionSelector, [self boolValueForWebPlayerSetting: kUnityAdsWebPlayerWebSettingsMediaPlaybackRequiresUserAction]);
                USRVLogDebug(@"Called setMediaPlaybackRequiresUserAction");
            }
        }
    }

    if ([self shouldSetWebPlayerSetting: kUnityAdsWebPlayerWebSettingsSuppressesIncrementalRendering]) {
        SEL setSuppressesIncrementalRenderingSelector = NSSelectorFromString(@"setSuppressesIncrementalRendering:");

        if ([wkConfiguration respondsToSelector: setSuppressesIncrementalRenderingSelector]) {
            IMP setSuppressesIncrementalRenderingImp = [wkConfiguration methodForSelector: setSuppressesIncrementalRenderingSelector];

            if (setSuppressesIncrementalRenderingImp) {
                void (*setSuppressesIncrementalRenderingFunc)(id, SEL, BOOL) = (void *)setSuppressesIncrementalRenderingImp;
                setSuppressesIncrementalRenderingFunc(wkConfiguration, setSuppressesIncrementalRenderingSelector, [self boolValueForWebPlayerSetting: kUnityAdsWebPlayerWebSettingsSuppressesIncrementalRendering]);
                USRVLogDebug(@"Called setSuppressesIncrementalRendering");
            }
        }
    }

    if ([self shouldSetWebPlayerSetting: kUnityAdsWebPlayerWebSettingsTypesRequiringAction]) {
        SEL setMediaTypesRequiringUserActionForPlaybackSelector = NSSelectorFromString(@"setMediaTypesRequiringUserActionForPlayback:");

        if ([wkConfiguration respondsToSelector: setMediaTypesRequiringUserActionForPlaybackSelector]) {
            IMP setMediaTypesRequiringUserActionForPlaybackImp = [wkConfiguration methodForSelector: setMediaTypesRequiringUserActionForPlaybackSelector];

            if (setMediaTypesRequiringUserActionForPlaybackImp) {
                void (*setMediaTypesRequiringUserActionForPlaybackFunc)(id, SEL, int) = (void *)setMediaTypesRequiringUserActionForPlaybackImp;
                setMediaTypesRequiringUserActionForPlaybackFunc(wkConfiguration, setMediaTypesRequiringUserActionForPlaybackSelector, [self intValueForWebPlayerSetting: kUnityAdsWebPlayerWebSettingsTypesRequiringAction]);
                USRVLogDebug(@"Called setMediaTypesRequiringUserActionForPlayback");
            }
        }
    }

    if ([self shouldSetWebPlayerSetting: kUnityAdsWebPlayerWebSettingsDataDetectorTypes]) {
        SEL setDataDetectorTypesSelector = NSSelectorFromString(@"setDataDetectorTypes:");

        if ([wkConfiguration respondsToSelector: setDataDetectorTypesSelector]) {
            IMP setDataDetectorTypesImp = [wkConfiguration methodForSelector: setDataDetectorTypesSelector];

            if (setDataDetectorTypesImp) {
                void (*setDataDetectorTypesFunc)(id, SEL, int) = (void *)setDataDetectorTypesImp;
                setDataDetectorTypesFunc(wkConfiguration, setDataDetectorTypesSelector, [self intValueForWebPlayerSetting: kUnityAdsWebPlayerWebSettingsDataDetectorTypes]);
                USRVLogDebug(@"Called setDataDetectorTypes");
            }
        }
    }

    if ([self shouldSetWebPlayerSetting: kUnityAdsWebPlayerWebSettingsIgnoresViewportScaleLimits]) {
        SEL setIgnoresViewportScaleLimitsSelector = NSSelectorFromString(@"setIgnoresViewportScaleLimits:");

        if ([wkConfiguration respondsToSelector: setIgnoresViewportScaleLimitsSelector]) {
            IMP setIgnoresViewportScaleLimitsImp = [wkConfiguration methodForSelector: setIgnoresViewportScaleLimitsSelector];

            if (setIgnoresViewportScaleLimitsImp) {
                void (*setIgnoresViewportScaleLimitsFunc)(id, SEL, BOOL) = (void *)setIgnoresViewportScaleLimitsImp;
                setIgnoresViewportScaleLimitsFunc(wkConfiguration, setIgnoresViewportScaleLimitsSelector, [self boolValueForWebPlayerSetting: kUnityAdsWebPlayerWebSettingsIgnoresViewportScaleLimits]);
                USRVLogDebug(@"Called setIgnoresViewportScaleLimits");
            }
        }
    }

    if ([self shouldSetWebPlayerSetting: kUnityAdsWebPlayerWebSettingsIgnoresViewportScaleLimits]) {
        SEL setIgnoresViewportScaleLimitsSelector = NSSelectorFromString(@"setIgnoresViewportScaleLimits:");

        if ([wkConfiguration respondsToSelector: setIgnoresViewportScaleLimitsSelector]) {
            IMP setIgnoresViewportScaleLimitsImp = [wkConfiguration methodForSelector: setIgnoresViewportScaleLimitsSelector];

            if (setIgnoresViewportScaleLimitsImp) {
                void (*setIgnoresViewportScaleLimitsFunc)(id, SEL, BOOL) = (void *)setIgnoresViewportScaleLimitsImp;
                setIgnoresViewportScaleLimitsFunc(wkConfiguration, setIgnoresViewportScaleLimitsSelector, [self boolValueForWebPlayerSetting: kUnityAdsWebPlayerWebSettingsIgnoresViewportScaleLimits]);
                USRVLogDebug(@"Called setIgnoresViewportScaleLimits");
            }
        }
    }

    id wkWebsiteDataStore = NSClassFromString(@"WKWebsiteDataStore");

    if (wkWebsiteDataStore) {
        SEL nonPersistentDataStoreSelector = NSSelectorFromString(@"nonPersistentDataStore");

        if ([wkWebsiteDataStore respondsToSelector: nonPersistentDataStoreSelector]) {
            IMP nonPersistentDataStoreImp = [wkWebsiteDataStore methodForSelector: nonPersistentDataStoreSelector];
            id (*nonPersistentDataStoreFunc)(void) = (void *)nonPersistentDataStoreImp;
            id nonPersistentDataStore = nonPersistentDataStoreFunc();
            [wkConfiguration setValue: nonPersistentDataStore
                               forKey: @"websiteDataStore"];
        }
    } else {
        return;
    }

    id wkPreferences = [USRVWKWebViewUtilities getObjectFromClass: "WKPreferences"];

    if (!wkPreferences) {
        return;
    }

    if ([self shouldSetWebPlayerSetting: kUnityAdsWebPlayerWebSettingsJavaScriptEnabled]) {
        [wkPreferences setValue: [NSNumber numberWithBool: [self boolValueForWebPlayerSetting: kUnityAdsWebPlayerWebSettingsJavaScriptEnabled]]
                         forKey: UADSNSStringFromWebPlayerWebSetting(kUnityAdsWebPlayerWebSettingsJavaScriptEnabled)];
    }

    if ([self shouldSetWebPlayerSetting: kUnityAdsWebPlayerWebSettingsJavaScriptCanOpenWindowsAutomatically]) {
        [wkPreferences setValue: [NSNumber numberWithBool: [self boolValueForWebPlayerSetting: kUnityAdsWebPlayerWebSettingsJavaScriptCanOpenWindowsAutomatically]]
                         forKey: UADSNSStringFromWebPlayerWebSetting(kUnityAdsWebPlayerWebSettingsJavaScriptCanOpenWindowsAutomatically)];
    }

    [wkConfiguration setValue: wkPreferences
                       forKey: @"preferences"];

    id webView = [USRVWKWebViewUtilities initWebView: "WKWebView"
                                               frame: CGRectMake(0, 0, 1024, 768)
                                       configuration: wkConfiguration];

    if (webView == NULL) {
        return;
    }

    USRVLogDebug(@"Got WebView");
    [(UIView *) webView
     setBackgroundColor: [UIColor clearColor]];
    [(UIView *) webView
     setOpaque: false];
    [webView setValue: @NO
           forKeyPath : @"scrollView.bounces"];
    [webView setValue: self
           forKeyPath : @"navigationDelegate"];
    [webView setValue: self
           forKeyPath : @"UIDelegate"];

    if ([self shouldSetWebPlayerSetting: kUnityAdsWebPlayerWebSettingsScrollEnabled]) {
        [webView setValue: [NSNumber numberWithBool: [self boolValueForWebPlayerSetting: kUnityAdsWebPlayerWebSettingsScrollEnabled]]
               forKeyPath : @"scrollView.scrollEnabled"];
    } else {
        [webView setValue: @NO
               forKeyPath : @"scrollView.scrollEnabled"];
    }

    self.internalWebView = webView;
    [self addSubview: webView];
} /* createWKWebPlayer */

- (void)webView: (id)webView didFinishNavigation: (id)navigation {
    if ([self shouldSendEvent: @"onPageFinished"]) {
        [[USRVWebViewApp getCurrentApp] sendEvent: UADSNSStringFromWebPlayerEvent(kUnityAdsWebPlayerPageFinished)
                                         category: USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryWebPlayer)
                                           param1: [(NSURL *)[webView valueForKeyPath: @"URL"] absoluteString], self.viewId, nil];
    }
}

- (void)webView: (id)webView didStartProvisionalNavigation: (id)navigation {
    if ([self shouldSendEvent: @"onPageStarted"]) {
        [[USRVWebViewApp getCurrentApp] sendEvent: UADSNSStringFromWebPlayerEvent(kUnityAdsWebPlayerPageStarted)
                                         category: USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryWebPlayer)
                                           param1: [(NSURL *)[webView valueForKeyPath: @"URL"] absoluteString], self.viewId, nil];
    }
}

- (void)webView: (id)webView didFailProvisionalNavigation: (id)navigation withError: (NSError *)error {
    if ([self shouldSendEvent: @"onReceivedError"]) {
        [[USRVWebViewApp getCurrentApp] sendEvent: UADSNSStringFromWebPlayerEvent(kUnityAdsWebPlayerError)
                                         category: USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryWebPlayer)
                                           param1: [(NSURL *)[webView valueForKeyPath: @"URL"] absoluteString], error.localizedDescription, self.viewId, nil];
    }
}

- (void)userContentController: (id)userContentController didReceiveScriptMessage: (id)message {
    id body = [message valueForKey: @"body"];
    NSData *data = NULL;

    if ([body isKindOfClass: [NSString class]]) {
        data = [body dataUsingEncoding: NSUTF8StringEncoding];
    } else if ([body isKindOfClass: [NSDictionary class]]) {
        data = [USRVJsonUtilities dataWithJSONObject: body
                                             options: 0
                                               error: nil];
    }

    if (data) {
        [[USRVWebViewApp getCurrentApp] sendEvent: UADSNSStringFromWebPlayerEvent(kUnityAdsWebPlayerEvent)
                                         category: USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryWebPlayer)
                                           param1: [[NSString alloc] initWithData: data
                                                                         encoding: NSUTF8StringEncoding], self.viewId, nil];
        NSLog(@"datadesc: %@", [[NSString alloc] initWithData: data
                                                     encoding: NSUTF8StringEncoding]);
    }
} /* userContentController */

typedef NS_ENUM (NSInteger, UADSWKWebViewDecisionPolicy) {
    UADSWKWebViewDecisionPolicyCancel,
    UADSWKWebViewDecisionPolicyAllow
};

- (UADSWKWebViewDecisionPolicy)decideNavigationAction: (BOOL)allow {
    return allow ? UADSWKWebViewDecisionPolicyAllow : UADSWKWebViewDecisionPolicyCancel;
}

- (BOOL)isNavigationActionRequestInIFrame: (id)navigationAction {
    id sourceFrame = [navigationAction valueForKey: @"sourceFrame"];
    id targetFrame = [navigationAction valueForKey: @"targetFrame"];

    if (sourceFrame == nil) {
        return NO;
    }

    if (targetFrame == nil) {
        return NO;
    }

    BOOL sourceIsMainFrame = [[sourceFrame valueForKey: @"isMainFrame"] boolValue];
    BOOL targetIsMainFrame = [[targetFrame valueForKey: @"isMainFrame"] boolValue];

    return !(sourceIsMainFrame && targetIsMainFrame);
}

- (void)webView: (id)webView decidePolicyForNavigationAction: (id)navigationAction decisionHandler: (void (^)(UADSWKWebViewDecisionPolicy))decisionHandler {
    BOOL allowNavigation = YES;

    if ([self shouldProvideReturnValue: @"shouldOverrideUrlLoading"]) {
        allowNavigation = [self boolValueForEventReturnValue: @"shouldOverrideUrlLoading"];
    }

    BOOL isIFrame = [self isNavigationActionRequestInIFrame: navigationAction];

    decisionHandler([self decideNavigationAction: allowNavigation]);

    if (isIFrame) {
        return;
    }

    id request = [navigationAction valueForKey: @"request"];

    if (request != nil) {
        NSURL *url = [request valueForKey: @"URL"];

        if (url != nil) {
            if ([self shouldSendEvent: @"onCreateWindow"]) {
                [[USRVWebViewApp getCurrentApp] sendEvent: UADSNSStringFromWebPlayerEvent(kUnityAdsWebPlayerCreateWebView)
                                                 category: USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryWebPlayer)
                                                   param1: [url absoluteString], self.viewId, nil];
            }
        }
    }
} /* webView */

- (id)webView: (id)webView createWebViewWithConfiguration: (id)configuration forNavigationAction: (id)navigationAction windowFeatures: (id)windowFeatures {
    id request = [navigationAction valueForKey: @"request"];

    if (request != nil) {
        NSURL *url = [request valueForKey: @"URL"];

        if (url != nil) {
            if ([self shouldProvideReturnValue: @"onCreateWindow"] && [self boolValueForEventReturnValue: @"onCreateWindow"]) {
                [USRVWKWebViewUtilities loadUrl: _internalWebView
                                            url: [NSURLRequest requestWithURL: url]];
            }

            if ([self shouldSendEvent: @"onCreateWindow"]) {
                [[USRVWebViewApp getCurrentApp] sendEvent: UADSNSStringFromWebPlayerEvent(kUnityAdsWebPlayerCreateWebView)
                                                 category: USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryWebPlayer)
                                                   param1: [url absoluteString], self.viewId, nil];
            }
        }
    }

    return nil;
} /* webView */

- (BOOL)shouldSendEvent: (NSString *)eventName {
    return [[[_webPlayerEventSettings objectForKey: eventName] objectForKey: @"sendEvent"] isEqualToValue: [NSNumber numberWithBool: YES]];
}

- (BOOL)shouldProvideReturnValue: (NSString *)eventName {
    return [[_webPlayerEventSettings objectForKey: eventName] objectForKey: @"returnValue"] != nil;
}

- (BOOL)boolValueForEventReturnValue: (NSString *)eventName {
    return [[[_webPlayerEventSettings objectForKey: eventName] objectForKey: @"returnValue"] isEqualToValue: [NSNumber numberWithBool: YES]];
}

- (BOOL)shouldSetWebPlayerSetting: (UnityAdsWebPlayerWebSettings)setting {
    return [_webPlayerSettings objectForKey: UADSNSStringFromWebPlayerWebSetting(setting)] != nil;
}

- (BOOL)boolValueForWebPlayerSetting: (UnityAdsWebPlayerWebSettings)setting {
    return [[_webPlayerSettings objectForKey: UADSNSStringFromWebPlayerWebSetting(setting)] boolValue];
}

- (int)intValueForWebPlayerSetting: (UnityAdsWebPlayerWebSettings)setting {
    return [[_webPlayerSettings objectForKey: UADSNSStringFromWebPlayerWebSetting(setting)] intValue];
}

@end
