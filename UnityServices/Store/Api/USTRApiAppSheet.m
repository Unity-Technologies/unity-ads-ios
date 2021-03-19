#import "USTRApiAppSheet.h"
#import "USTRStore.h"
#import "USRVWebViewCallback.h"
#import "UADSApiAdUnit.h"
#import "USRVWebViewApp.h"
#import "USTRAppSheetEvent.h"
#import "USRVWebViewEventCategory.h"
#import "USTRAppSheetError.h"


@implementation USTRApiAppSheet

+ (void)WebViewExposed_canOpen:(USRVWebViewCallback *)callback {
    USTRAppSheet* appSheet = [USTRStore appSheet];
    NSNumber* canOpenAppSheet = [NSNumber numberWithBool:appSheet.canOpenAppSheet];
    [callback invoke:canOpenAppSheet, nil];
}

+ (void)WebViewExposed_prepare:(NSDictionary *)parameters prepareTimeout:(NSNumber *)timeout callback:(USRVWebViewCallback *)callback {
    [[USTRStore appSheet] prepareAppSheet:parameters prepareTimeoutInSeconds:timeout.intValue / 1000 completionBlock:^(BOOL result, NSString * _Nullable error) {
        id webViewApp = [USRVWebViewApp getCurrentApp];
        if(result) {
            if(webViewApp) {
                [webViewApp sendEvent:USRVNSStringFromAppSheetEvent(kAppSheetPrepared) category:USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryAppSheet) param1:parameters, nil];
            }
        } else {
            if(webViewApp) {
                [webViewApp sendEvent:USRVNSStringFromAppSheetEvent(kAppSheetFailed) category:USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryAppSheet) param1:error, parameters, nil];
            }
        }
    }];
    [callback invoke:nil];
}

+ (void)WebViewExposed_prepareImmediate:(NSDictionary *)parameters prepareTimeout:(NSNumber *)timeout callback:(USRVWebViewCallback *)callback {
    [[USTRStore appSheet] prepareAppSheetImmediate:parameters prepareTimeoutInSeconds:timeout.intValue / 1000 completionBlock:^(BOOL result, NSString * _Nullable error) {
        id webViewApp = [USRVWebViewApp getCurrentApp];
        if(result) {
            if(webViewApp) {
                [webViewApp sendEvent:USRVNSStringFromAppSheetEvent(kAppSheetPrepared) category:USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryAppSheet) param1:parameters, nil];
            }
        } else {
            if(webViewApp) {
                [webViewApp sendEvent:USRVNSStringFromAppSheetEvent(kAppSheetFailed) category:USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryAppSheet) param1:error, parameters, nil];
            }
        }
    }];
    [callback invoke:nil];
}

+ (void)WebViewExposed_present:(NSDictionary *)parameters animated:(NSNumber *)animated callback:(USRVWebViewCallback *)callback {
    [[USTRStore appSheet] presentAppSheet:parameters animated:[animated boolValue] completionBlock:^(BOOL result, NSString * _Nullable error) {
        if(result) {
            [callback invoke:parameters, nil];
        } else {
            [callback error:error arg1:parameters, nil];
        }
    }];
}

+ (void)WebViewExposed_presentWithTopViewControllerSupport:(NSDictionary *)parameters animated:(NSNumber *)animated callback:(USRVWebViewCallback *)callback {
    [[USTRStore appSheet] presentAppSheetWithTopViewControllerSupport:parameters animated:[animated boolValue] completionBlock:^(BOOL result, NSString * _Nullable error) {
        if(result) {
            [callback invoke:parameters, nil];
        } else {
            [callback error:error arg1:parameters, nil];
        }
    }];
}

+ (void)WebViewExposed_destroy:(USRVWebViewCallback *)callback {
    [[USTRStore appSheet] destroyAppSheet];
    [callback invoke:nil];
}

+ (void)WebViewExposed_destroy:(NSDictionary*)parameters callback:(USRVWebViewCallback *)callback {
    if([[USTRStore appSheet] destroyAppSheet:parameters]) {
        [callback invoke:nil];
    } else {
        [callback error:USRVNSStringFromAppSheetError(kUnityServicesAppSheetErrorNoAppSheetFound) arg1:parameters, nil];
    }
}

+ (void)WebViewExposed_setPrepareTimeout:(NSNumber *)timeout callback:(USRVWebViewCallback *)callback {
    [[USTRStore appSheet] setPrepareTimeoutInSeconds:timeout.intValue / 1000];
    [callback invoke:nil];
}

+ (void)WebViewExposed_getPrepareTimeout:(USRVWebViewCallback *)callback {
    NSNumber *timeoutInMs = [NSNumber numberWithInt:[[USTRStore appSheet] prepareTimeoutInSeconds] * 1000];
    [callback invoke:timeoutInMs, nil];
}

@end
