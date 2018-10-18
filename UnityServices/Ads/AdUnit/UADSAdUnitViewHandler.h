#import <UIKit/UIKit.h>

@class UADSViewController;

@interface UADSAdUnitViewHandler : NSObject

- (BOOL)create:(UADSViewController *)viewController;
- (BOOL)destroy;
- (UIView *)getView;
- (CGRect)getRect:(UIView *)view;

- (void)viewDidLoad:(UADSViewController *)viewController;
- (void)viewDidAppear:(UADSViewController *)viewController animated:(BOOL)animated;
- (void)viewWillAppear:(UADSViewController *)viewController animated:(BOOL)animated;
- (void)viewWillDisappear:(UADSViewController *)viewController animated:(BOOL)animated;
- (void)viewDidDisappear:(UADSViewController *)viewController animated:(BOOL)animated;
    
@end
