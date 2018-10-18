#import "UADSARViewHandler.h"
#import "UADSViewController.h"

@implementation UADSARViewHandler

- (BOOL)create:(UADSViewController *)viewController {
    if (![self arView]) {
        [self setArView:[[UADSARView alloc] initWithFrame:[self getRect:viewController.view]]];
    }

    return true;
}

- (BOOL)destroy {
    if ([self arView]) {
        [[self arView] removeFromSuperview];
    }
    
    self.arView = nil;

    return true;
}

- (UIView *)getView {
    return _arView;
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
