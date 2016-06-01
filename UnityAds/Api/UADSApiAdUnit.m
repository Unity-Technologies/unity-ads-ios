#import "UADSApiAdUnit.h"
#import "UADSWebViewCallback.h"
#import "UADSClientProperties.h"
#import "UADSAdUnitError.h"

@implementation UADSApiAdUnit

static UADSViewController *adUnitViewController = NULL;

+ (UADSViewController *)getAdUnit {
    return adUnitViewController;
}

+ (void)setAdUnit:(UADSViewController *)viewController {
    adUnitViewController = viewController;
}

+ (void)WebViewExposed_open:(NSArray *)views supportedOrientations:(NSNumber *)supportedOrientations callback:(UADSWebViewCallback *)callback {
    [UADSApiAdUnit WebViewExposed_open:views supportedOrientations:supportedOrientations statusBarHidden:[NSNumber numberWithInt:0] callback:callback];
}

+ (void)WebViewExposed_open:(NSArray *)views supportedOrientations:(NSNumber *)supportedOrientations statusBarHidden:(NSNumber *)statusBarHidden callback:(UADSWebViewCallback *)callback {
    [UADSApiAdUnit WebViewExposed_open:views supportedOrientations:supportedOrientations statusBarHidden:[NSNumber numberWithInt:0] shouldAutorotate:[NSNumber numberWithBool:YES] callback:callback];
    
    [callback invoke:nil];
}

+ (void)WebViewExposed_open:(NSArray *)views supportedOrientations:(NSNumber *)supportedOrientations statusBarHidden:(NSNumber *)statusBarHidden shouldAutorotate:(NSNumber *)shouldAutorotate callback:(UADSWebViewCallback *)callback {
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        UADSLog(@"PRESENTING VIEWCONTROLLER");
        UADSViewController *adUnit = [[UADSViewController alloc] initWithViews:views supportedOrientations:supportedOrientations statusBarHidden:[statusBarHidden boolValue] shouldAutorotate:[shouldAutorotate boolValue]];
        [adUnit setModalPresentationCapturesStatusBarAppearance:true];
        [[UADSClientProperties getCurrentViewController] presentViewController:adUnit animated:YES completion:NULL];
        adUnitViewController = adUnit;
    });
    
    [callback invoke:nil];
}

+ (void)WebViewExposed_close:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSClientProperties getCurrentViewController] dismissViewControllerAnimated:true completion:NULL];
            adUnitViewController = NULL;
        });
        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsViewControllerNull) arg1:nil];
    }
}

+ (void)WebViewExposed_setViews:(NSArray *)views callback:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSApiAdUnit getAdUnit] setViews:views];
        });
        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsViewControllerNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getViews:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [callback invoke:[[UADSApiAdUnit getAdUnit] currentViews], nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsViewControllerNull) arg1:nil];
    }
}

+ (void)WebViewExposed_setSupportedOrientations:(NSNumber *)supportedOrientations callback:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [[UADSApiAdUnit getAdUnit] setSupportedOrientations:[supportedOrientations intValue]];
        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsViewControllerNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getSupportedOrientations:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [callback invoke:[NSNumber numberWithInt:[[UADSApiAdUnit getAdUnit] supportedOrientations]], nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsViewControllerNull) arg1:nil];
    }
}

+ (void)WebViewExposed_setKeepScreenOn:(NSNumber *)screenOn callback:(UADSWebViewCallback *)callback {
    BOOL keepOn = [screenOn boolValue];
    [UIApplication sharedApplication].idleTimerDisabled = keepOn;
    [callback invoke:nil];
}

+ (void)WebViewExposed_setStatusBarHidden:(NSNumber *)statusBarHidden callback:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [[UADSApiAdUnit getAdUnit] setStatusBarHidden:[statusBarHidden boolValue]];
        [callback invoke:statusBarHidden, nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsViewControllerNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getStatusBarHidden:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [callback invoke:[NSNumber numberWithInt:[[UADSApiAdUnit getAdUnit] statusBarHidden]], nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsViewControllerNull) arg1:nil];
    }
}

+ (void)WebViewExposed_setShouldAutorotate:(NSNumber *)shouldAutorotate callback:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [[UADSApiAdUnit getAdUnit] setAutorotate:[shouldAutorotate boolValue]];
        [callback invoke:shouldAutorotate, nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsViewControllerNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getShouldAutorotate:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [callback invoke:[NSNumber numberWithInt:[[UADSApiAdUnit getAdUnit] autorotate]], nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsViewControllerNull) arg1:nil];
    }
}

@end