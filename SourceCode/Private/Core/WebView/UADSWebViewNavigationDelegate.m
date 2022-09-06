#import "UADSWebViewNavigationDelegate.h"
#import "UADSServiceProvider.h"
#import "UADSWebViewMetric.h"

@interface UADSWebViewNavigationDelegate ()
@property (nonatomic) BOOL finishCalledOnce;
@end

@implementation UADSWebViewNavigationDelegate

_uads_default_singleton_imp(UADSWebViewNavigationDelegate);

- (void)webViewWebContentProcessDidTerminate: (WKWebView *)webView {
    [self.metricSender sendMetric: [UADSWebViewMetric newWebViewTerminated]];
}

- (void)webView: (WKWebView *)webView didFinishNavigation: (WKNavigation *)navigation {
    if (!_finishCalledOnce) {
        _finishCalledOnce = true;
        return;
    }

    [self.metricSender sendMetric: [UADSWebViewMetric newReloaded]];
}

- (id<ISDKMetrics>)metricSender {
    return UADSServiceProvider.sharedInstance.metricSender;
}

@end
