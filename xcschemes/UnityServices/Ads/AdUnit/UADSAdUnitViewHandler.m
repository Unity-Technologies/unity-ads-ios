#import "UADSAdUnitViewHandler.h"

@implementation UADSAdUnitViewHandler

- (BOOL)create:(UADSViewController *)viewController {
    return true;
}

- (BOOL)destroy {
    return true;
}

- (UIView *)getView {
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
}

- (CGRect)getRect:(UIView *)view {
    CGFloat x = CGRectGetMinX(view.bounds);
    CGFloat y = CGRectGetMinY(view.bounds);
    CGFloat width = CGRectGetWidth(view.bounds);
    CGFloat height = CGRectGetHeight(view.bounds);
    
    return CGRectMake(x, y, width, height);
}

@end
