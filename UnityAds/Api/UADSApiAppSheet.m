#import "UADSApiAppSheet.h"
#import "UADSWebViewCallback.h"
#import "UADSAppSheetViewController.h"
#import "UADSApiAdUnit.h"
#import "UADSWebViewApp.h"
#import "UADSAppSheet.h"
#import "UADSAppSheetEvent.h"
#import "UADSWebViewEventCategory.h"
#import "UADSAppSheetError.h"


@implementation UADSApiAppSheet

+ (void)WebViewExposed_canOpen:(UADSWebViewCallback *)callback {
    UADSAppSheet* appSheet = [UADSAppSheet instance];
    NSNumber* canOpenAppSheet = [NSNumber numberWithBool:appSheet.canOpenAppSheet];
    [callback invoke:canOpenAppSheet, nil];
}

+ (void)WebViewExposed_prepare:(NSDictionary *)parameters prepareTimeout:(NSNumber *)timeout callback:(UADSWebViewCallback *)callback {
    [[UADSAppSheet instance] prepareAppSheet:parameters prepareTimeoutInSeconds:timeout.intValue / 1000 completionBlock:^(BOOL result, NSString * _Nullable error) {
        id webViewApp = [UADSWebViewApp getCurrentApp];
        if(result) {
            if(webViewApp) {
                [webViewApp sendEvent:NSStringFromAppSheetEvent(kAppSheetPrepared) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryAppSheet) param1:parameters, nil];
            }
        } else {
            if(webViewApp) {
                [webViewApp sendEvent:NSStringFromAppSheetEvent(kAppSheetFailed) category:NSStringFromWebViewEventCategory(kUnityAdsWebViewEventCategoryAppSheet) param1:error, parameters, nil];
            }
        }
    }];
    [callback invoke:nil];
}

+ (void)WebViewExposed_present:(NSDictionary *)parameters animated:(NSNumber *)animated callback:(UADSWebViewCallback *)callback {
    [[UADSAppSheet instance] presentAppSheet:parameters animated:[animated boolValue] completionBlock:^(BOOL result, NSString * _Nullable error) {
        if(result) {
            [callback invoke:parameters, nil];
        } else {
            [callback error:error arg1:parameters, nil];
        }
    }];
}

+ (void)WebViewExposed_destroy:(UADSWebViewCallback *)callback {
    [[UADSAppSheet instance] destroyAppSheet];
    [callback invoke:nil];
}

+ (void)WebViewExposed_destroy:(NSDictionary*)parameters callback:(UADSWebViewCallback *)callback {
    if([[UADSAppSheet instance] destroyAppSheet:parameters]) {
        [callback invoke:nil];
    } else {
        [callback error:NSStringFromAppSheetError(kUnityAdsAppSheetErrorNoAppSheetFound) arg1:parameters, nil];
    }
}

+ (void)WebViewExposed_setPrepareTimeout:(NSNumber *)timeout callback:(UADSWebViewCallback *)callback {
    [[UADSAppSheet instance] setPrepareTimeoutInSeconds:timeout.intValue / 1000];
    [callback invoke:nil];
}

+ (void)WebViewExposed_getPrepareTimeout:(UADSWebViewCallback *)callback {
    NSNumber *timeoutInMs = [NSNumber numberWithInt:[[UADSAppSheet instance] prepareTimeoutInSeconds] * 1000];
    [callback invoke:timeoutInMs, nil];
}

@end