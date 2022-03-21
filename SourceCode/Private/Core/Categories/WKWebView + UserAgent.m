#import "WKWebView + UserAgent.h"

@implementation WKWebView (UserAgent)

+ (NSString *)getUserAgentSync {
    assert(NSThread.isMainThread);

    WKWebView *webView = [[WKWebView alloc] initWithFrame: CGRectZero];

    NSString *result = [webView valueForKey: @"userAgent"];

    if (result == nil || [result isEqualToString: @"" ]) {
        return [self getUserAgentSyncFallBack: webView];
    }

    return result;
}

+ (NSString *)getUserAgentSyncFallBack: (WKWebView *)webView {
    __block NSString *result;

    [webView evaluateJavaScript: @"navigator.userAgent"
              completionHandler:^(id _Nullable response, NSError *_Nullable error) {
                  if (error || ![response isKindOfClass: [NSString class]]) {
                      result = @"";
                  } else {
                      result = response;
                  }
              }];

    while (result == nil)
        [[NSRunLoop mainRunLoop] runUntilDate: [NSDate dateWithTimeIntervalSinceNow: 0.01]];
    return result;
}

@end
