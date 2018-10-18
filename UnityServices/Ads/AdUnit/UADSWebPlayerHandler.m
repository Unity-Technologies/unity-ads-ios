#import "UADSWebPlayerHandler.h"
#import "UADSApiWebPlayer.h"
#import "UADSViewController.h"

@interface UADSWebPlayerHandler ()
@end

@implementation UADSWebPlayerHandler

- (BOOL)create:(UADSViewController *)viewController {
    if (![self webPlayerView]) {
        [self setWebPlayerView:[[UADSWebPlayerView alloc] initWithFrame:[self getRect:viewController.view] viewId:@"webplayer" webPlayerSettings:[UADSApiWebPlayer getWebPlayerSettings]]];
        [[self webPlayerView] setEventSettings:[UADSApiWebPlayer getWebPlayerEventSettings]];
    }
    
    return true;
}

- (BOOL)destroy {
    if ([self webPlayerView]) {
        [self.webPlayerView removeFromSuperview];
    }
    [self.webPlayerView destroy];
    self.webPlayerView = nil;

    return true;
}

- (UIView *)getView {
    return self.webPlayerView;
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
