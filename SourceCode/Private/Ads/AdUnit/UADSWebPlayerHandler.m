#import "UADSWebPlayerHandler.h"
#import "UADSApiWebPlayer.h"
#import "UADSViewController.h"
#import "UADSWebPlayerSettingsManager.h"
#import "UADSWebPlayerViewManager.h"

NSString *const UADSWebPlayerViewId = @"webplayer";

@interface UADSWebPlayerHandler ()
@end

@implementation UADSWebPlayerHandler

- (BOOL)create: (UADSViewController *)viewController {
    if (![self webPlayerView]) {
        NSDictionary *settings = [[UADSWebPlayerSettingsManager sharedInstance] getWebPlayerSettings: UADSWebPlayerViewId];
        [self setWebPlayerView: [[UADSWebPlayerView alloc] initWithFrame: [self getRect: viewController.view]
                                                                  viewId: UADSWebPlayerViewId
                                                       webPlayerSettings: settings]];
        [[UADSWebPlayerViewManager sharedInstance] addWebPlayerView: self.webPlayerView
                                                             viewId: UADSWebPlayerViewId];
        NSDictionary *eventSettings = [[UADSWebPlayerSettingsManager sharedInstance] getWebPlayerEventSettings: UADSWebPlayerViewId];
        [[self webPlayerView] setEventSettings: eventSettings];
    }

    return true;
}

- (BOOL)destroy {
    if ([self webPlayerView]) {
        [self.webPlayerView removeFromSuperview];
    }

    [self.webPlayerView destroy];
    self.webPlayerView = nil;
    [[UADSWebPlayerViewManager sharedInstance] removeWebPlayerViewWithViewId: UADSWebPlayerViewId];

    return true;
}

- (UIView *)getView {
    return self.webPlayerView;
}

- (void)viewDidLoad: (UADSViewController *)viewController {
}

- (void)viewDidAppear: (UADSViewController *)viewController animated: (BOOL)animated {
}

- (void)viewWillAppear: (UADSViewController *)viewController animated: (BOOL)animated {
}

- (void)viewWillDisappear: (UADSViewController *)viewController animated: (BOOL)animated {
}

- (void)viewDidDisappear: (UADSViewController *)viewController animated: (BOOL)animated {
    [self destroy];
}

@end
