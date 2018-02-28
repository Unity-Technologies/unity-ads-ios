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
    [UADSApiAdUnit WebViewExposed_open:views supportedOrientations:supportedOrientations statusBarHidden:statusBarHidden shouldAutorotate:[NSNumber numberWithBool:YES] callback:callback];
}

+ (void)WebViewExposed_open:(NSArray *)views supportedOrientations:(NSNumber *)supportedOrientations statusBarHidden:(NSNumber *)statusBarHidden shouldAutorotate:(NSNumber *)shouldAutorotate callback:(UADSWebViewCallback *)callback {
    [UADSApiAdUnit WebViewExposed_open:views supportedOrientations:supportedOrientations statusBarHidden:statusBarHidden shouldAutorotate:shouldAutorotate isTransparent:[NSNumber numberWithBool:NO] callback:callback];
}

+ (void)WebViewExposed_open:(NSArray *)views supportedOrientations:(NSNumber *)supportedOrientations statusBarHidden:(NSNumber *)statusBarHidden shouldAutorotate:(NSNumber *)shouldAutorotate isTransparent:(NSNumber *)isTransparent callback:(UADSWebViewCallback *)callback {
    [UADSApiAdUnit WebViewExposed_open:views supportedOrientations:supportedOrientations statusBarHidden:statusBarHidden shouldAutorotate:shouldAutorotate isTransparent:isTransparent withAnimation:[NSNumber numberWithBool:YES] callback:callback];
}

+ (void)WebViewExposed_open:(NSArray *)views supportedOrientations:(NSNumber *)supportedOrientations statusBarHidden:(NSNumber *)statusBarHidden shouldAutorotate:(NSNumber *)shouldAutorotate isTransparent:(NSNumber *)isTransparent withAnimation:(NSNumber *)animated callback:(UADSWebViewCallback *)callback {
    [UADSApiAdUnit WebViewExposed_open:views supportedOrientations:supportedOrientations statusBarHidden:statusBarHidden shouldAutorotate:shouldAutorotate isTransparent:isTransparent withAnimation:animated homeIndicatorAutoHidden:[NSNumber numberWithBool:YES] callback:callback];
}

+ (void)WebViewExposed_open:(NSArray *)views supportedOrientations:(NSNumber *)supportedOrientations statusBarHidden:(NSNumber *)statusBarHidden shouldAutorotate:(NSNumber *)shouldAutorotate isTransparent:(NSNumber *)isTransparent withAnimation:(NSNumber *)animated homeIndicatorAutoHidden:(NSNumber *)homeIndicatorAutoHidden callback:(UADSWebViewCallback *)callback {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        UADSLogDebug(@"PRESENTING VIEWCONTROLLER");
        UADSViewController *adUnit = [[UADSViewController alloc] initWithViews:views supportedOrientations:supportedOrientations statusBarHidden:[statusBarHidden boolValue] shouldAutorotate:[shouldAutorotate boolValue] isTransparent:[isTransparent boolValue] homeIndicatorAutoHidden: [homeIndicatorAutoHidden boolValue]];
        [adUnit setModalPresentationCapturesStatusBarAppearance:true];
        if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_8_0 && [isTransparent boolValue]) {
            adUnit.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            if ([UADSClientProperties getCurrentViewController]) {
                [UADSClientProperties getCurrentViewController].modalPresentationStyle = UIModalPresentationCurrentContext;
            }
            else {
                [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitHostViewControllerNull) arg1:nil];
                return;
            }
        }

        if ([UADSClientProperties getCurrentViewController]) {
            [[UADSClientProperties getCurrentViewController] presentViewController:adUnit animated:[animated boolValue] completion:NULL];
        }
        else {
            [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitHostViewControllerNull) arg1:nil];
            return;
        }
        adUnitViewController = adUnit;
    });

    [callback invoke:nil];
}

+ (void)WebViewExposed_close:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([UADSClientProperties getCurrentViewController]) {
                [[UADSClientProperties getCurrentViewController] dismissViewControllerAnimated:true completion:NULL];
            }
            else {
                [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitHostViewControllerNull) arg1:nil];
                return;
            }

            adUnitViewController = NULL;
        });
        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
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
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getViews:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [callback invoke:[[UADSApiAdUnit getAdUnit] currentViews], nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

+ (void)WebViewExposed_setSupportedOrientations:(NSNumber *)supportedOrientations callback:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [[UADSApiAdUnit getAdUnit] setSupportedOrientations:[supportedOrientations intValue]];
        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getSupportedOrientations:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [callback invoke:[NSNumber numberWithInt:[[UADSApiAdUnit getAdUnit] supportedOrientations]], nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
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
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getStatusBarHidden:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [callback invoke:[NSNumber numberWithInt:[[UADSApiAdUnit getAdUnit] statusBarHidden]], nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

+ (void)WebViewExposed_setShouldAutorotate:(NSNumber *)shouldAutorotate callback:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [[UADSApiAdUnit getAdUnit] setAutorotate:[shouldAutorotate boolValue]];
        [callback invoke:shouldAutorotate, nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getShouldAutorotate:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [callback invoke:[NSNumber numberWithInt:[[UADSApiAdUnit getAdUnit] autorotate]], nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
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
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
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
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getTransform:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        if ([[UADSApiAdUnit getAdUnit].view valueForKeyPath:@"layer.transform.rotation.z"]) {
            [callback invoke:[(NSNumber *)[UADSApiAdUnit getAdUnit].view valueForKeyPath:@"layer.transform.rotation.z"], nil];
        }
        else {
            [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNoRotationZ) arg1:nil];
        }
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
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
        
        if (targetView) {
            CGRect targetFrame = targetView.frame;
            [callback invoke:[NSNumber numberWithFloat:targetFrame.origin.x],
                [NSNumber numberWithFloat:targetFrame.origin.y],
                [NSNumber numberWithFloat:targetFrame.size.width],
                [NSNumber numberWithFloat:targetFrame.size.height],
             nil];
        }
        else {
            [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitUnknownView) arg1:nil];
            return;
        }
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

+ (void)WebViewExposed_setHomeIndicatorAutoHidden:(NSNumber *)homeIndicatorAutoHidden callback:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [[UADSApiAdUnit getAdUnit] setHomeIndicatorAutoHidden:[homeIndicatorAutoHidden boolValue]];
        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getHomeIndicatorAutoHidden:(UADSWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [callback invoke:[NSNumber numberWithBool:[[UADSApiAdUnit getAdUnit] homeIndicatorAutoHidden]], nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

@end
