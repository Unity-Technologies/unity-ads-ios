#import "UIViewControllerMock.h"

@interface UIViewControllerMock ()

@end

@implementation UIViewControllerMock
{
    NSInteger presentViewControllerCalled;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    presentViewControllerCalled = 0;
}

- (NSInteger)presentViewControllerCalledNumberOfTimes {
    return presentViewControllerCalled;
}


- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion {
    presentViewControllerCalled += 1;
    [super presentViewController:viewControllerToPresent animated:flag completion:completion];
}

@end
