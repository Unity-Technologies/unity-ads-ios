#import "UADSWebViewHandler.h"
#import "USRVWebViewApp.h"

@implementation UADSWebViewHandler

- (BOOL)create:(UADSViewController *)viewController {
    return true;
}

- (BOOL)destroy {
    if ([USRVWebViewApp getCurrentApp] && [[USRVWebViewApp getCurrentApp] webView]) {
        [[[USRVWebViewApp getCurrentApp] webView] removeFromSuperview];
        [[USRVWebViewApp getCurrentApp] placeWebViewToBackgroundView];
    }
    
    return true;
}

- (UIView *)getView {
    if ([USRVWebViewApp getCurrentApp]) {
        return [[USRVWebViewApp getCurrentApp] webView];
    }

    return NULL;
}

- (void)viewDidLoad:(UADSViewController *)viewController {
}

- (void)viewDidAppear:(UADSViewController *)viewController animated:(BOOL)animated {
}

- (void)viewWillAppear:(UADSViewController *)viewController animated:(BOOL)animated {
}

- (void)viewWillDisappear:(UADSViewController *)viewController animated:(BOOL)animated {
}

- (void)viewDidDisappear:(UADSViewController *)viewController animated:(BOOL)animated {
    [self destroy];
}

@end
