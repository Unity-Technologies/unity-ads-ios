#import "UIViewController+WindowScene.h"
#import "UIViewController + TopController.h"

@implementation UIViewController (WindowScene)

+ (UIWindowScene *)currentWindowScene API_AVAILABLE(ios(13.0)) {
    UIViewController *currentVC = [UIViewController uads_getTopController];
    UIWindowScene *scene = [currentVC.view.window windowScene];

    if (scene == nil) {
        scene = [UIApplication.sharedApplication.windows.firstObject windowScene];
    }

    return scene;
}

@end
