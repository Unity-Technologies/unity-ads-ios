#import "UADSAppSheetViewController.h"

@implementation UADSAppSheetViewController

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return [UIApplication sharedApplication].statusBarOrientation;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1]intValue]
            >= 8 && [[UIDevice currentDevice] userInterfaceIdiom] != UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    return UIInterfaceOrientationMaskAll;
}

- (BOOL)shouldAutorotate {
      return [[[[UIDevice currentDevice] systemVersion] substringToIndex:1]intValue] < 8
            || [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end