#import "USRVApiAppSheet.h"
#import "USRVWebViewCallback.h"
#import "USRVAppSheetViewController.h"
#import "UADSApiAdUnit.h"
#import "USRVWebViewApp.h"
#import "USRVAppSheet.h"
#import "USRVAppSheetEvent.h"
#import "USRVWebViewEventCategory.h"
#import "USRVAppSheetError.h"


@implementation USRVApiAppSheet

+ (void)WebViewExposed_canOpen:(USRVWebViewCallback *)callback {
    USRVAppSheet* appSheet = [USRVAppSheet instance];
    NSNumber* canOpenAppSheet = [NSNumber numberWithBool:appSheet.canOpenAppSheet];
    [callback invoke:canOpenAppSheet, nil];
}

+ (void)WebViewExposed_prepare:(NSDictionary *)parameters prepareTimeout:(NSNumber *)timeout callback:(USRVWebViewCallback *)callback {
    [[USRVAppSheet instance] prepareAppSheet:parameters prepareTimeoutInSeconds:timeout.intValue / 1000 completionBlock:^(BOOL result, NSString * _Nullable error) {
        id webViewApp = [USRVWebViewApp getCurrentApp];
        if(result) {
            if(webViewApp) {
                [webViewApp sendEvent:NSStringFromAppSheetEvent(kAppSheetPrepared) category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryAppSheet) param1:parameters, nil];
            }
        } else {
            if(webViewApp) {
                [webViewApp sendEvent:NSStringFromAppSheetEvent(kAppSheetFailed) category:NSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryAppSheet) param1:error, parameters, nil];
            }
        }
    }];
    [callback invoke:nil];
}

+ (void)WebViewExposed_present:(NSDictionary *)parameters animated:(NSNumber *)animated callback:(USRVWebViewCallback *)callback {
    [[USRVAppSheet instance] presentAppSheet:parameters animated:[animated boolValue] completionBlock:^(BOOL result, NSString * _Nullable error) {
        if(result) {
            [callback invoke:parameters, nil];
        } else {
            [callback error:error arg1:parameters, nil];
        }
    }];
}

+ (void)WebViewExposed_destroy:(USRVWebViewCallback *)callback {
    [[USRVAppSheet instance] destroyAppSheet];
    [callback invoke:nil];
}

+ (void)WebViewExposed_destroy:(NSDictionary*)parameters callback:(USRVWebViewCallback *)callback {
    if([[USRVAppSheet instance] destroyAppSheet:parameters]) {
        [callback invoke:nil];
    } else {
        [callback error:NSStringFromAppSheetError(kUnityServicesAppSheetErrorNoAppSheetFound) arg1:parameters, nil];
    }
}

+ (void)WebViewExposed_setPrepareTimeout:(NSNumber *)timeout callback:(USRVWebViewCallback *)callback {
    [[USRVAppSheet instance] setPrepareTimeoutInSeconds:timeout.intValue / 1000];
    [callback invoke:nil];
}

+ (void)WebViewExposed_getPrepareTimeout:(USRVWebViewCallback *)callback {
    NSNumber *timeoutInMs = [NSNumber numberWithInt:[[USRVAppSheet instance] prepareTimeoutInSeconds] * 1000];
    [callback invoke:timeoutInMs, nil];
}

@end
