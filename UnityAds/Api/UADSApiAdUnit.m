#import "UADSApiAdUnit.h"
#import "UADSWebViewCallback.h"
#import "UADSClientProperties.h"
#import "UADSAdUnitError.h"
#import "UADSWebViewApp.h"

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
        UADSLogDebug(@"PRESENTING VIEWCONTROLLER");
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

+ (void)WebViewExposed_setTransform:(NSNumber *)transform callback:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [[UADSApiAdUnit getAdUnit] setTransform:[transform floatValue]];
        });
        [callback invoke:transform, nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsViewControllerNull) arg1:nil];
    }
}

+ (void)WebViewExposed_setViewFrame:(NSString *)view x:(NSNumber *)x y:(NSNumber *)y width:(NSNumber *)width height:(NSNumber *)height callback:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UADSApiAdUnit getAdUnit] setViewFrame:view x:[x intValue] y:[y intValue] width:[width intValue] height:[height intValue]];
        });
        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsViewControllerNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getTransform:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        if ([[UADSApiAdUnit getAdUnit].view valueForKeyPath:@"layer.transform.rotation.z"]) {
            [callback invoke:[(NSNumber *)[UADSApiAdUnit getAdUnit].view valueForKeyPath:@"layer.transform.rotation.z"], nil];
        }
        else {
            [callback error:NSStringFromAdUnitError(kUnityAdsViewControllerNoRotationZ) arg1:nil];
        }
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsViewControllerNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getViewFrame:(NSString *)view callback:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        UIView *targetView = NULL;
        
        if ([view isEqualToString:@"adunit"]) {
            targetView = [UADSApiAdUnit getAdUnit].view;
        }
        else if ([view isEqualToString:@"videoplayer"]) {
            targetView = [UADSApiAdUnit getAdUnit].videoView;
        }
        else if ([view isEqualToString:@"webview"]) {
            targetView = [[UADSWebViewApp getCurrentApp] webView];
        }
        else {
            [callback error:NSStringFromAdUnitError(kUnityAdsViewControllerUnknownView) arg1:nil];
            return;
        }
        
        if (targetView) {
            CGRect targetFrame = targetView.frame;
            [callback invoke:[NSNumber numberWithFloat:targetFrame.origin.x],
                [NSNumber numberWithFloat:targetFrame.origin.y],
                [NSNumber numberWithFloat:targetFrame.size.width],
                [NSNumber numberWithFloat:targetFrame.size.height],
             nil];
        }
        else {
            [callback error:NSStringFromAdUnitError(kUnityAdsViewControllerTargetViewNull) arg1:nil];
            return;
        }
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsViewControllerNull) arg1:nil];
    }
}

@end
