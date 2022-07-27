#import "UIViewController+TopController.h"

@implementation UIViewController (TopViewController)
+ (UIViewController *_Nullable)uads_getTopController {
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;

    while (topController.presentedViewController)
        topController = topController.presentedViewController;

    return topController;
}

@end
