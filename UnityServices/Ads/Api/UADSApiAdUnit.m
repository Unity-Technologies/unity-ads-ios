#import "UADSApiAdUnit.h"
#import "USRVWebViewCallback.h"
#import "USRVClientProperties.h"
#import "UADSAdUnitError.h"
#import "USRVWebViewApp.h"

@implementation UADSApiAdUnit

static UADSViewController *adUnitViewController = NULL;

+ (UADSViewController *)getAdUnit {
    return adUnitViewController;
}

+ (void)setAdUnit:(UADSViewController *)viewController {
    adUnitViewController = viewController;
}

+ (void)WebViewExposed_open:(NSArray *)views supportedOrientations:(NSNumber *)supportedOrientations callback:(USRVWebViewCallback *)callback {
    [UADSApiAdUnit WebViewExposed_open:views supportedOrientations:supportedOrientations statusBarHidden:[NSNumber numberWithInt:0] callback:callback];
}

+ (void)WebViewExposed_open:(NSArray *)views supportedOrientations:(NSNumber *)supportedOrientations statusBarHidden:(NSNumber *)statusBarHidden callback:(USRVWebViewCallback *)callback {
    [UADSApiAdUnit WebViewExposed_open:views supportedOrientations:supportedOrientations statusBarHidden:statusBarHidden shouldAutorotate:[NSNumber numberWithBool:YES] callback:callback];
}

+ (void)WebViewExposed_open:(NSArray *)views supportedOrientations:(NSNumber *)supportedOrientations statusBarHidden:(NSNumber *)statusBarHidden shouldAutorotate:(NSNumber *)shouldAutorotate callback:(USRVWebViewCallback *)callback {
    [UADSApiAdUnit WebViewExposed_open:views supportedOrientations:supportedOrientations statusBarHidden:statusBarHidden shouldAutorotate:shouldAutorotate isTransparent:[NSNumber numberWithBool:NO] callback:callback];
}

+ (void)WebViewExposed_open:(NSArray *)views supportedOrientations:(NSNumber *)supportedOrientations statusBarHidden:(NSNumber *)statusBarHidden shouldAutorotate:(NSNumber *)shouldAutorotate isTransparent:(NSNumber *)isTransparent callback:(USRVWebViewCallback *)callback {
    [UADSApiAdUnit WebViewExposed_open:views supportedOrientations:supportedOrientations statusBarHidden:statusBarHidden shouldAutorotate:shouldAutorotate isTransparent:isTransparent withAnimation:[NSNumber numberWithBool:YES] callback:callback];
}

+ (void)WebViewExposed_open:(NSArray *)views supportedOrientations:(NSNumber *)supportedOrientations statusBarHidden:(NSNumber *)statusBarHidden shouldAutorotate:(NSNumber *)shouldAutorotate isTransparent:(NSNumber *)isTransparent withAnimation:(NSNumber *)animated callback:(USRVWebViewCallback *)callback {
    [UADSApiAdUnit WebViewExposed_open:views supportedOrientations:supportedOrientations statusBarHidden:statusBarHidden shouldAutorotate:shouldAutorotate isTransparent:isTransparent withAnimation:animated homeIndicatorAutoHidden:[NSNumber numberWithBool:YES] callback:callback];
}

+ (void)WebViewExposed_open:(NSArray *)views supportedOrientations:(NSNumber *)supportedOrientations statusBarHidden:(NSNumber *)statusBarHidden shouldAutorotate:(NSNumber *)shouldAutorotate isTransparent:(NSNumber *)isTransparent withAnimation:(NSNumber *)animated homeIndicatorAutoHidden:(NSNumber *)homeIndicatorAutoHidden callback:(USRVWebViewCallback *)callback {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        USRVLogDebug(@"PRESENTING VIEWCONTROLLER");
        UADSViewController *adUnit = [[UADSViewController alloc] initWithViews:views supportedOrientations:supportedOrientations statusBarHidden:[statusBarHidden boolValue] shouldAutorotate:[shouldAutorotate boolValue] isTransparent:[isTransparent boolValue] homeIndicatorAutoHidden: [homeIndicatorAutoHidden boolValue]];
        [adUnit setModalPresentationCapturesStatusBarAppearance:true];
        if (floor(NSFoundationVersionNumber) >= NSFoundationVersionNumber_iOS_8_0 && [isTransparent boolValue]) {
            adUnit.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            if ([USRVClientProperties getCurrentViewController]) {
                [USRVClientProperties getCurrentViewController].modalPresentationStyle = UIModalPresentationCurrentContext;
            }
            else {
                [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitHostViewControllerNull) arg1:nil];
                return;
            }
        }

        if ([USRVClientProperties getCurrentViewController]) {
            [[USRVClientProperties getCurrentViewController] presentViewController:adUnit animated:[animated boolValue] completion:NULL];
        }
        else {
            [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitHostViewControllerNull) arg1:nil];
            return;
        }
        adUnitViewController = adUnit;
    });

    [callback invoke:nil];
}

+ (void)WebViewExposed_close:(USRVWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([USRVClientProperties getCurrentViewController]) {
                [[USRVClientProperties getCurrentViewController] dismissViewControllerAnimated:true completion:NULL];
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

+ (void)WebViewExposed_setViews:(NSArray *)views callback:(USRVWebViewCallback *)callback {
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

+ (void)WebViewExposed_getViews:(USRVWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [callback invoke:[[UADSApiAdUnit getAdUnit] currentViews], nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

+ (void)WebViewExposed_setSupportedOrientations:(NSNumber *)supportedOrientations callback:(USRVWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [[UADSApiAdUnit getAdUnit] setSupportedOrientations:[supportedOrientations intValue]];
        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getSupportedOrientations:(USRVWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [callback invoke:[NSNumber numberWithInt:[[UADSApiAdUnit getAdUnit] supportedOrientations]], nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

+ (void)WebViewExposed_setKeepScreenOn:(NSNumber *)screenOn callback:(USRVWebViewCallback *)callback {
    BOOL keepOn = [screenOn boolValue];
    [UIApplication sharedApplication].idleTimerDisabled = keepOn;
    [callback invoke:nil];
}

+ (void)WebViewExposed_setStatusBarHidden:(NSNumber *)statusBarHidden callback:(USRVWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [[UADSApiAdUnit getAdUnit] setStatusBarHidden:[statusBarHidden boolValue]];
        [callback invoke:statusBarHidden, nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getStatusBarHidden:(USRVWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [callback invoke:[NSNumber numberWithInt:[[UADSApiAdUnit getAdUnit] statusBarHidden]], nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

+ (void)WebViewExposed_setShouldAutorotate:(NSNumber *)shouldAutorotate callback:(USRVWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [[UADSApiAdUnit getAdUnit] setAutorotate:[shouldAutorotate boolValue]];
        [callback invoke:shouldAutorotate, nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getShouldAutorotate:(USRVWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [callback invoke:[NSNumber numberWithInt:[[UADSApiAdUnit getAdUnit] autorotate]], nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

+ (void)WebViewExposed_setTransform:(NSNumber *)transform callback:(USRVWebViewCallback *)callback {
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

+ (void)WebViewExposed_setViewFrame:(NSString *)view x:(NSNumber *)x y:(NSNumber *)y width:(NSNumber *)width height:(NSNumber *)height callback:(USRVWebViewCallback *)callback {
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

+ (void)WebViewExposed_getTransform:(USRVWebViewCallback *)callback {
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

+ (void)WebViewExposed_getViewFrame:(NSString *)view callback:(USRVWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        UIView *targetView = NULL;
        
        if ([view isEqualToString:@"adunit"]) {
            targetView = [UADSApiAdUnit getAdUnit].view;
        }
        else if ([UADSApiAdUnit getAdUnit] && [[UADSApiAdUnit getAdUnit] getViewHandler:view]) {
            targetView = [[[UADSApiAdUnit getAdUnit] getViewHandler:view] getView];
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

+ (void)WebViewExposed_setHomeIndicatorAutoHidden:(NSNumber *)homeIndicatorAutoHidden callback:(USRVWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [[UADSApiAdUnit getAdUnit] setHomeIndicatorAutoHidden:[homeIndicatorAutoHidden boolValue]];
        [callback invoke:nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getHomeIndicatorAutoHidden:(USRVWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        [callback invoke:[NSNumber numberWithBool:[[UADSApiAdUnit getAdUnit] homeIndicatorAutoHidden]], nil];
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

+ (void)WebViewExposed_getSafeAreaInsets:(USRVWebViewCallback *)callback {
    if ([UADSApiAdUnit getAdUnit]) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        SEL safeAreaInsetsSelector = NSSelectorFromString(@"safeAreaInsets");
        if ([window respondsToSelector:safeAreaInsetsSelector]) {
            IMP safeAreaInsetsSelectorImpl = [window methodForSelector:safeAreaInsetsSelector];
            UIEdgeInsets (*safeAreaInsetsFunc)(id, SEL) = (void *)safeAreaInsetsSelectorImpl;
            UIEdgeInsets safeAreaInsets = safeAreaInsetsFunc(window, safeAreaInsetsSelector);
            NSDictionary *safeAreaInsetsDictionary = @{@"top" : @(safeAreaInsets.top), @"right" : @(safeAreaInsets.right), @"bottom" : @(safeAreaInsets.bottom), @"left" : @(safeAreaInsets.left)};
            [callback invoke: safeAreaInsetsDictionary, nil];
        }
        else {
            [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitApiLevelError) arg1:nil];
        }
    }
    else {
        [callback error:NSStringFromAdUnitError(kUnityAdsAdUnitNull) arg1:nil];
    }
}

@end
