#import "UADSWebPlayerView.h"
#import "UADSWKWebViewApp.h"
#import "UADSDevice.h"
#import "UADSWebPlayerEvent.h"
#import "UADSWebPlayerSettings.h"
#import "UADSWebViewEventCategory.h"
#import "UADSWKWebViewUtilities.h"
#import <dlfcn.h>
#import <objc/runtime.h>

@interface UADSWebPlayerView () <UIWebViewDelegate>
@property (nonatomic, assign) id internalWebView;
@property (nonatomic, retain) NSDictionary* webPlayerSettings;
@property (nonatomic, retain) NSDictionary* webPlayerEventSettings;
- (void)createWKWebPlayer;
- (void)createUIWebPlayer;
@end

@implementation UADSWebPlayerView

- (instancetype)initWithFrame:(CGRect)frame webPlayerSettings:(NSDictionary*)webPlayerSettings {
    self = [super initWithFrame:frame];
    if (self) {
        self.accessibilityElementsHidden = true;
        [self setWebPlayerSettings:webPlayerSettings];
        [self createInternalWebView];
    }
    
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [_internalWebView setFrame:super.bounds];
}

- (void)loadUrl:(NSString *)url {
    [UADSWKWebViewUtilities loadUrl:_internalWebView url:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)loadData:(NSString*)data mimeType:(NSString *)mimeType encoding:(NSString *)encoding {
    [self loadData:data mimeType:mimeType encoding:encoding baseUrl:@""];
}

- (void)loadData:(NSString*)data mimeType:(NSString *)mimeType encoding:(NSString *)encoding baseUrl:(NSString *)baseUrl {
    if ([_internalWebView isKindOfClass:[UIWebView class]]) {
        [((UIWebView*)_internalWebView) loadData:[data dataUsingEncoding:NSUTF8StringEncoding] MIMEType:mimeType textEncodingName:encoding baseURL:[NSURL URLWithString:baseUrl]];
    } else {
        [UADSWKWebViewUtilities loadData:_internalWebView data:[data dataUsingEncoding:NSUTF8StringEncoding] mimeType:mimeType encoding:encoding baseUrl:[NSURL URLWithString:baseUrl]];
    }
}

-(void)setWebPlayerSettings:(NSDictionary*)webPlayerSettings {
    _webPlayerSettings = webPlayerSettings;
}

-(void)setEventSettings:(NSDictionary*)eventSettings {
    [self setWebPlayerEventSettings:eventSettings];
}

-(void)receiveEvent:(NSData*)data {
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *stringForEvaluation = [NSString stringWithFormat:@"javascript:window.nativebridge.receiveEvent(%@)", jsonString];
    if ([_internalWebView isKindOfClass:[UIWebView class]]) {
        [((UIWebView*)_internalWebView) stringByEvaluatingJavaScriptFromString:stringForEvaluation];
    } else {
        [UADSWKWebViewUtilities evaluateJavaScript:_internalWebView string:stringForEvaluation];
    }
}

- (void)createInternalWebView {
    NSString *osVersion = [UADSDevice getOsVersion];
    NSArray<NSString *> *splitString = [osVersion componentsSeparatedByString:@"."];
    NSString *osMajorVersionString = [splitString objectAtIndex:0];
    int osMajorVersion = [osMajorVersionString intValue];
    
    if (osMajorVersion > 8) {
        UADSLogDebug(@"Using WKWebView for WebPlayer");
        [self createWKWebPlayer];
    }
    else {
        UADSLogDebug(@"Using UIWebView for WebPlayer");
        [self createUIWebPlayer];
    }
}

- (void)createUIWebPlayer {
    UIWebView *webView = NULL;
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 1024,768)];
    NSLog(@"WebPlayerSettings: %@", self.webPlayerSettings);
    if ([self shouldSetWebPlayerSetting:kUnityAdsWebPlayerWebSettingsMediaPlaybackRequiresUserAction]) {
        webView.mediaPlaybackRequiresUserAction = [self boolValueForWebPlayerSetting:kUnityAdsWebPlayerWebSettingsMediaPlaybackRequiresUserAction];
        NSLog(@"WebPlayer: setting %@ to %d", @"mediaPlaybackRequiresUserAction", webView.mediaPlaybackRequiresUserAction);
    }
    if ([self shouldSetWebPlayerSetting:kUnityAdsWebPlayerWebSettingsAllowsInlineMediaPlayback]) {
        webView.allowsInlineMediaPlayback = [self boolValueForWebPlayerSetting:kUnityAdsWebPlayerWebSettingsAllowsInlineMediaPlayback];
        NSLog(@"WebPlayer: setting %@ to %d", @"allowsInlineMediaPlayback", webView.allowsInlineMediaPlayback);
    }
    if ([self shouldSetWebPlayerSetting:kUnityAdsWebPlayerWebSettingsScalesPagesToFit]) {
        webView.scalesPageToFit = [self boolValueForWebPlayerSetting:kUnityAdsWebPlayerWebSettingsScalesPagesToFit];
        NSLog(@"WebPlayer: setting %@ to %d", @"scalesPageToFit", webView.scalesPageToFit);
    }
    if ([self shouldSetWebPlayerSetting:kUnityAdsWebPlayerWebSettingsMediaPlaybackAllowsAirPlay]) {
        webView.mediaPlaybackAllowsAirPlay = [self boolValueForWebPlayerSetting:kUnityAdsWebPlayerWebSettingsMediaPlaybackAllowsAirPlay];
        NSLog(@"WebPlayer: setting %@ to %d", @"mediaPlaybackAllowsAirPlay", webView.mediaPlaybackAllowsAirPlay);
    }
    if ([self shouldSetWebPlayerSetting:kUnityAdsWebPlayerWebSettingsSuppressesIncrementalRendering]) {
        webView.suppressesIncrementalRendering = [self boolValueForWebPlayerSetting:kUnityAdsWebPlayerWebSettingsSuppressesIncrementalRendering];
        NSLog(@"WebPlayer: setting %@ to %d", @"suppressesIncrementalRendering", webView.suppressesIncrementalRendering);
    }
    if ([self shouldSetWebPlayerSetting:kUnityAdsWebPlayerWebSettingsKeyboardDisplayRequiresUserAction]) {
        webView.keyboardDisplayRequiresUserAction = [self boolValueForWebPlayerSetting:kUnityAdsWebPlayerWebSettingsKeyboardDisplayRequiresUserAction];
        NSLog(@"WebPlayer: setting %@ to %d", @"keyboardDisplayRequiresUserAction", webView.keyboardDisplayRequiresUserAction);
    }
    if ([self shouldSetWebPlayerSetting:kUnityAdsWebPlayerWebSettingsDataDetectorTypes]) {
        webView.dataDetectorTypes = [self intValueForWebPlayerSetting:kUnityAdsWebPlayerWebSettingsDataDetectorTypes];
        NSLog(@"WebPlayer: setting %@ to %d", @"dataDetectorTypes", webView.dataDetectorTypes);
    }
    [webView setBackgroundColor:[UIColor clearColor]];
    [webView setOpaque:false];
    webView.scrollView.bounces = NO;
    webView.delegate = self;
    [self setInternalWebView:webView];
    [self addSubview:webView];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if ([self shouldSendEvent:@"onPageStarted"]) {
        [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromWebPlayerEvent(kUnityAdsWebPlayerPageStarted) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryWebPlayer) param1:webView.request.mainDocumentURL.absoluteString,nil];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([self shouldSendEvent:@"onPageFinished"]) {
        [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromWebPlayerEvent(kUnityAdsWebPlayerPageFinished) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryWebPlayer) param1:webView.request.mainDocumentURL.absoluteString,nil];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ([self shouldSendEvent:@"onReceivedError"]) {
        [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromWebPlayerEvent(kUnityAdsWebPlayerError) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryWebPlayer) param1:webView.request.mainDocumentURL.absoluteString,error.localizedDescription,nil];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *urlString = [[request URL] absoluteString];
    NSLog(@"Got event: %@", urlString);
    
    if ([urlString hasPrefix:@"umsg:"]) {
        NSString *jsonString = [[[urlString componentsSeparatedByString:@"umsg:"] lastObject] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromWebPlayerEvent(kUnityAdsWebPlayerEvent) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryWebPlayer) param1: jsonString, nil];
        return NO;
    } else {
        BOOL allowNavigation = YES;
        if ([self shouldProvideReturnValue:@"shouldOverrideUrlLoading"]) {
            allowNavigation = [self boolValueForEventReturnValue:@"shouldOverrideUrlLoading"];
        }
        if ([self shouldSendEvent:@"shouldOverrideUrlLoading"]) {
            [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromWebPlayerEvent(kUnityAdsWebPlayerShouldOverrideURLLoading) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryWebPlayer) param1: urlString, nil];
        }
        return allowNavigation;
    }
}

- (void)createWKWebPlayer {
    UADSLogDebug(@"CREATING WKWEBVIEWAPP");
    NSString *frameworkLocation;

    if (![UADSWKWebViewUtilities isFrameworkPresent]) {
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
        
        if (![UADSWKWebViewUtilities isFrameworkPresent]) {
            UADSLogError(@"WKWebKit still not present!");
            return;
        }
        else {
            UADSLogDebug(@"Succesfully loaded WKWebKit framework");
        }
    }
    else {
        UADSLogDebug(@"WebKit framework already present");
    }
    
    id wkConfiguration = [UADSWKWebViewUtilities getObjectFromClass:"WKWebViewConfiguration"];
    if (wkConfiguration) {
        wkConfiguration = [UADSWKWebViewUtilities addUserContentControllerMessageHandlers:wkConfiguration delegate:self handledMessages:@[@"sendEvent"]];
        if (!wkConfiguration) {
            return;
        }
    } else {
        return;
    }
    
    if ([self shouldSetWebPlayerSetting:kUnityAdsWebPlayerWebSettingsAllowsInlineMediaPlayback]) {
        SEL setAllowsInlineMediaPlaybackSelector = NSSelectorFromString(@"setAllowsInlineMediaPlayback:");
        if ([wkConfiguration respondsToSelector:setAllowsInlineMediaPlaybackSelector]) {
            IMP setAllowsInlineMediaPlaybackImp = [wkConfiguration methodForSelector:setAllowsInlineMediaPlaybackSelector];
            if (setAllowsInlineMediaPlaybackImp) {
                void (*setAllowsInlineMediaPlaybackFunc)(id, SEL, BOOL) = (void *)setAllowsInlineMediaPlaybackImp;
                setAllowsInlineMediaPlaybackFunc(wkConfiguration, setAllowsInlineMediaPlaybackSelector, [self boolValueForWebPlayerSetting:kUnityAdsWebPlayerWebSettingsAllowsInlineMediaPlayback]);
                UADSLogDebug(@"Called setAllowsInlineMediaPlayback")
            }
        }
    }
    
    if ([self shouldSetWebPlayerSetting:kUnityAdsWebPlayerWebSettingsMediaPlaybackAllowsAirPlay]) {
        SEL setMediaPlaybackAllowsAirPlaySelector = NSSelectorFromString(@"setAllowsAirPlayForMediaPlayback:");
        if ([wkConfiguration respondsToSelector:setMediaPlaybackAllowsAirPlaySelector]) {
            IMP setMediaPlaybackAllowsAirPlayImp = [wkConfiguration methodForSelector:setMediaPlaybackAllowsAirPlaySelector];
            if (setMediaPlaybackAllowsAirPlayImp) {
                void (*setMediaPlaybackAllowsAirPlayFunc)(id, SEL, BOOL) = (void *)setMediaPlaybackAllowsAirPlayImp;
                setMediaPlaybackAllowsAirPlayFunc(wkConfiguration, setMediaPlaybackAllowsAirPlaySelector, [self boolValueForWebPlayerSetting:kUnityAdsWebPlayerWebSettingsMediaPlaybackAllowsAirPlay]);
                UADSLogDebug(@"Called setAllowsAirPlayForMediaPlayback");
            }
        }
    }
    
    if ([self shouldSetWebPlayerSetting:kUnityAdsWebPlayerWebSettingsMediaPlaybackRequiresUserAction]) {
        SEL setMediaPlaybackRequiresUserActionSelector = NSSelectorFromString(@"setMediaPlaybackRequiresUserAction:");
        if ([wkConfiguration respondsToSelector:setMediaPlaybackRequiresUserActionSelector]) {
            IMP setMediaPlaybackRequiresUserActionImp = [wkConfiguration methodForSelector:setMediaPlaybackRequiresUserActionSelector];
            if (setMediaPlaybackRequiresUserActionImp) {
                void (*setMediaPlaybackRequiresUserActionFunc)(id, SEL, BOOL) = (void *)setMediaPlaybackRequiresUserActionImp;
                setMediaPlaybackRequiresUserActionFunc(wkConfiguration, setMediaPlaybackRequiresUserActionSelector, [self boolValueForWebPlayerSetting:kUnityAdsWebPlayerWebSettingsMediaPlaybackRequiresUserAction]);
                UADSLogDebug(@"Called setMediaPlaybackRequiresUserAction");
            }
        }
    }

    if ([self shouldSetWebPlayerSetting:kUnityAdsWebPlayerWebSettingsSuppressesIncrementalRendering]) {
        SEL setSuppressesIncrementalRenderingSelector = NSSelectorFromString(@"setSuppressesIncrementalRendering:");
        if ([wkConfiguration respondsToSelector:setSuppressesIncrementalRenderingSelector]) {
            IMP setSuppressesIncrementalRenderingImp = [wkConfiguration methodForSelector:setSuppressesIncrementalRenderingSelector];
            if (setSuppressesIncrementalRenderingImp) {
                void (*setSuppressesIncrementalRenderingFunc)(id, SEL, BOOL) = (void *)setSuppressesIncrementalRenderingImp;
                setSuppressesIncrementalRenderingFunc(wkConfiguration, setSuppressesIncrementalRenderingSelector, [self boolValueForWebPlayerSetting:kUnityAdsWebPlayerWebSettingsSuppressesIncrementalRendering]);
                UADSLogDebug(@"Called setSuppressesIncrementalRendering");
            }
        }
    }

    if ([self shouldSetWebPlayerSetting:kUnityAdsWebPlayerWebSettingsTypesRequiringAction]) {
        SEL setMediaTypesRequiringUserActionForPlaybackSelector = NSSelectorFromString(@"setMediaTypesRequiringUserActionForPlayback:");
        if ([wkConfiguration respondsToSelector:setMediaTypesRequiringUserActionForPlaybackSelector]) {
            IMP setMediaTypesRequiringUserActionForPlaybackImp = [wkConfiguration methodForSelector:setMediaTypesRequiringUserActionForPlaybackSelector];
            if (setMediaTypesRequiringUserActionForPlaybackImp) {
                void (*setMediaTypesRequiringUserActionForPlaybackFunc)(id, SEL, int) = (void *)setMediaTypesRequiringUserActionForPlaybackImp;
                setMediaTypesRequiringUserActionForPlaybackFunc(wkConfiguration, setMediaTypesRequiringUserActionForPlaybackSelector, [self intValueForWebPlayerSetting:kUnityAdsWebPlayerWebSettingsTypesRequiringAction]);
                UADSLogDebug(@"Called setMediaTypesRequiringUserActionForPlayback");
            }
        }
    }

    if ([self shouldSetWebPlayerSetting:kUnityAdsWebPlayerWebSettingsDataDetectorTypes]) {
        SEL setDataDetectorTypesSelector = NSSelectorFromString(@"setDataDetectorTypes:");
        if ([wkConfiguration respondsToSelector:setDataDetectorTypesSelector]) {
            IMP setDataDetectorTypesImp = [wkConfiguration methodForSelector:setDataDetectorTypesSelector];
            if (setDataDetectorTypesImp) {
                void (*setDataDetectorTypesFunc)(id, SEL, int) = (void *)setDataDetectorTypesImp;
                setDataDetectorTypesFunc(wkConfiguration, setDataDetectorTypesSelector, [self intValueForWebPlayerSetting:kUnityAdsWebPlayerWebSettingsDataDetectorTypes]);
                UADSLogDebug(@"Called setDataDetectorTypes");
            }
        }
    }
    
    if ([self shouldSetWebPlayerSetting:kUnityAdsWebPlayerWebSettingsIgnoresViewportScaleLimits]) {
        SEL setIgnoresViewportScaleLimitsSelector = NSSelectorFromString(@"setIgnoresViewportScaleLimits:");
        if ([wkConfiguration respondsToSelector:setIgnoresViewportScaleLimitsSelector]) {
            IMP setIgnoresViewportScaleLimitsImp = [wkConfiguration methodForSelector:setIgnoresViewportScaleLimitsSelector];
            if (setIgnoresViewportScaleLimitsImp) {
                void (*setIgnoresViewportScaleLimitsFunc)(id, SEL, BOOL) = (void *)setIgnoresViewportScaleLimitsImp;
                setIgnoresViewportScaleLimitsFunc(wkConfiguration, setIgnoresViewportScaleLimitsSelector, [self boolValueForWebPlayerSetting:kUnityAdsWebPlayerWebSettingsIgnoresViewportScaleLimits]);
                UADSLogDebug(@"Called setIgnoresViewportScaleLimits");
            }
        }
    }
    
    if ([self shouldSetWebPlayerSetting:kUnityAdsWebPlayerWebSettingsIgnoresViewportScaleLimits]) {
        SEL setIgnoresViewportScaleLimitsSelector = NSSelectorFromString(@"setIgnoresViewportScaleLimits:");
        if ([wkConfiguration respondsToSelector:setIgnoresViewportScaleLimitsSelector]) {
            IMP setIgnoresViewportScaleLimitsImp = [wkConfiguration methodForSelector:setIgnoresViewportScaleLimitsSelector];
            if (setIgnoresViewportScaleLimitsImp) {
                void (*setIgnoresViewportScaleLimitsFunc)(id, SEL, BOOL) = (void *)setIgnoresViewportScaleLimitsImp;
                setIgnoresViewportScaleLimitsFunc(wkConfiguration, setIgnoresViewportScaleLimitsSelector, [self boolValueForWebPlayerSetting:kUnityAdsWebPlayerWebSettingsIgnoresViewportScaleLimits]);
                UADSLogDebug(@"Called setIgnoresViewportScaleLimits");
            }
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
    
    id wkPreferences = [UADSWKWebViewUtilities getObjectFromClass:"WKPreferences"];
    if (!wkPreferences) {
        return;
    }
    if ([self shouldSetWebPlayerSetting:kUnityAdsWebPlayerWebSettingsJavaScriptEnabled]) {
        [wkPreferences setValue:[NSNumber numberWithBool:[self boolValueForWebPlayerSetting:kUnityAdsWebPlayerWebSettingsJavaScriptEnabled]] forKey:NSStringFromWebPlayerWebSetting(kUnityAdsWebPlayerWebSettingsJavaScriptEnabled)];
    }
    if ([self shouldSetWebPlayerSetting:kUnityAdsWebPlayerWebSettingsJavaScriptCanOpenWindowsAutomatically]) {
        [wkPreferences setValue:[NSNumber numberWithBool:[self boolValueForWebPlayerSetting:kUnityAdsWebPlayerWebSettingsJavaScriptCanOpenWindowsAutomatically]] forKey:NSStringFromWebPlayerWebSetting(kUnityAdsWebPlayerWebSettingsJavaScriptCanOpenWindowsAutomatically)];
    }
    [wkConfiguration setValue:wkPreferences forKey:@"preferences"];
    
    id webView = [UADSWKWebViewUtilities initWebView:"WKWebView" frame:CGRectMake(0, 0, 1024, 768) configuration:wkConfiguration];
    
    if (webView == NULL) {
        return;
    }
    
    UADSLogDebug(@"Got WebView");
    [(UIView *)webView setBackgroundColor:[UIColor clearColor]];
    [(UIView *)webView setOpaque:false];
    [webView setValue:@NO forKeyPath:@"scrollView.bounces"];
    [webView setValue:self forKeyPath:@"navigationDelegate"];
    [webView setValue:self forKeyPath:@"UIDelegate"];
    
    [self setInternalWebView:webView];
    [self addSubview:webView];
}

- (void)webView:(id)webView didFinishNavigation:(id)navigation {
    if ([self shouldSendEvent:@"onPageFinished"]) {
       [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromWebPlayerEvent(kUnityAdsWebPlayerPageFinished) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryWebPlayer) param1:[(NSURL*)[webView valueForKeyPath:@"URL"] absoluteString],nil];
    }
}

- (void)webView:(id)webView didStartProvisionalNavigation:(id)navigation {
    if ([self shouldSendEvent:@"onPageStarted"]) {
        [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromWebPlayerEvent(kUnityAdsWebPlayerPageStarted) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryWebPlayer) param1:[(NSURL*)[webView valueForKeyPath:@"URL"] absoluteString],nil];
    }
}

- (void)webView:(id)webView didFailProvisionalNavigation:(id)navigation withError:(NSError *)error {
    if ([self shouldSendEvent:@"onReceivedError"]) {
        [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromWebPlayerEvent(kUnityAdsWebPlayerError) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryWebPlayer) param1:[(NSURL*)[webView valueForKeyPath:@"URL"] absoluteString],error.localizedDescription,nil];
    }
}

- (void)userContentController:(id)userContentController didReceiveScriptMessage:(id)message {
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
        [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromWebPlayerEvent(kUnityAdsWebPlayerEvent) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryWebPlayer) param1:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding],nil];
        NSLog(@"datadesc: %@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }
}

typedef NS_ENUM(NSInteger, UADSWKWebViewDecisionPolicy) {
    UADSWKWebViewDecisionPolicyCancel,
    UADSWKWebViewDecisionPolicyAllow
};

- (UADSWKWebViewDecisionPolicy)decideNavigationAction:(BOOL)allow {
    return allow ? UADSWKWebViewDecisionPolicyAllow : UADSWKWebViewDecisionPolicyCancel;
}

- (BOOL)isNavigationActionRequestInIFrame:(id)navigationAction {
    id sourceFrame = [navigationAction valueForKey:@"sourceFrame"];
    id targetFrame = [navigationAction valueForKey:@"targetFrame"];
    NSLog(@"(SourceFrame=%@, TargetFrame=%@)", sourceFrame, targetFrame);
    if (sourceFrame == nil) {
        return NO;
    }
    if (targetFrame == nil) {
        return NO;
    }
    BOOL sourceIsMainFrame = [[sourceFrame valueForKey:@"isMainFrame"] boolValue];
    BOOL targetIsMainFrame = [[targetFrame valueForKey:@"isMainFrame"] boolValue];
    NSLog(@"(SourceFrame=%d, TargetFrame=%d)", sourceIsMainFrame, targetIsMainFrame);
    return !(sourceIsMainFrame && targetIsMainFrame);
}

- (void)webView:(id)webView decidePolicyForNavigationAction:(id)navigationAction decisionHandler:(void (^)(UADSWKWebViewDecisionPolicy))decisionHandler {
    BOOL allowNavigation = YES;
    if ([self shouldProvideReturnValue:@"shouldOverrideUrlLoading"]) {
        allowNavigation = [self boolValueForEventReturnValue:@"shouldOverrideUrlLoading"];
    }
    BOOL isIFrame = [self isNavigationActionRequestInIFrame:navigationAction];
    decisionHandler([self decideNavigationAction:allowNavigation]);
    if (isIFrame) {
        return;
    }
    id request = [navigationAction valueForKey:@"request"];
    if (request != nil) {
        NSURL* url = [request valueForKey:@"URL"];
        if (url != nil) {
            if ([self shouldSendEvent:@"shouldOverrideUrlLoading"]) {
                [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromWebPlayerEvent(kUnityAdsWebPlayerShouldOverrideURLLoading) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryWebPlayer) param1: [url absoluteString], nil];
            }
        }
    }
}

- (id)webView:(id)webView createWebViewWithConfiguration:(id)configuration forNavigationAction:(id)navigationAction windowFeatures:(id)windowFeatures {
    id request = [navigationAction valueForKey:@"request"];
    if (request != nil) {
        NSURL* url = [request valueForKey:@"URL"];
        if (url != nil) {
            if ([self shouldProvideReturnValue:@"shouldOverrideUrlLoading"] && [self boolValueForEventReturnValue:@"shouldOverrideUrlLoading"]) {
                [UADSWKWebViewUtilities loadUrl:_internalWebView url:[NSURLRequest requestWithURL:url]];
            }
            if ([self shouldSendEvent:@"shouldOverrideUrlLoading"]) {
                [[UADSWebViewApp getCurrentApp] sendEvent:NSStringFromWebPlayerEvent(kUnityAdsWebPlayerShouldOverrideURLLoading) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryWebPlayer) param1: [url absoluteString], nil];
            }
        }
    }
    return nil;
}

- (BOOL)shouldSendEvent:(NSString *)eventName {
    return [[[_webPlayerEventSettings objectForKey:eventName] objectForKey:@"sendEvent"] isEqualToValue:[NSNumber numberWithBool:YES]];
}

- (BOOL)shouldProvideReturnValue:(NSString *)eventName {
    return [[_webPlayerEventSettings objectForKey:eventName] objectForKey:@"returnValue"] != nil;
}

- (BOOL)boolValueForEventReturnValue:(NSString *)eventName {
    return [[[_webPlayerEventSettings objectForKey:eventName] objectForKey:@"returnValue"] isEqualToValue:[NSNumber numberWithBool:YES]];
}

- (BOOL)shouldSetWebPlayerSetting:(UnityAdsWebPlayerWebSettings)setting {
    return [_webPlayerSettings objectForKey:NSStringFromWebPlayerWebSetting(setting)] != nil;
}

- (BOOL)boolValueForWebPlayerSetting:(UnityAdsWebPlayerWebSettings)setting {
    return [[_webPlayerSettings objectForKey:NSStringFromWebPlayerWebSetting(setting)] boolValue];
}

- (int)intValueForWebPlayerSetting:(UnityAdsWebPlayerWebSettings)setting {
    return [[_webPlayerSettings objectForKey:NSStringFromWebPlayerWebSetting(setting)] intValue];
}

@end
