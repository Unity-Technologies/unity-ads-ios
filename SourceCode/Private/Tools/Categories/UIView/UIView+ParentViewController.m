#import "UIView+ParentViewController.h"

@implementation UIView (ParentViewController)
- (nullable UIViewController *)parentViewController {
    UIResponder *responder = [self nextResponder];
    while (responder != nil) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = [responder nextResponder];
    }
    return nil;
}
@end
