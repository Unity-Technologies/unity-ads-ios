#import "USRVNativeErrorReporter.h"
#import "USRVWebViewApp.h"
#import "USRVWebViewEventCategory.h"

typedef NS_ENUM (NSInteger, USRVErrorEvent) {
    USRVErrorEventReportNativeError
};

NSString * NSStringFromUSRVErrorEvent(USRVErrorEvent event) {
    switch (event) {
        case USRVErrorEventReportNativeError:
            return @"REPORT_NATIVE_ERROR";

        default:
            return @"";
    }
}

@implementation USRVNativeErrorReporter

+ (void)reportError: (NSString *)errorString {
    USRVWebViewApp *webViewApp = [USRVWebViewApp getCurrentApp];

    if (webViewApp) {
        [webViewApp sendEvent: NSStringFromUSRVErrorEvent(USRVErrorEventReportNativeError)
                     category: USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryNativeError)
                       params: @[errorString]];
    }
}

@end
