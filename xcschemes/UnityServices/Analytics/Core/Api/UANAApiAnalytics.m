#import "UANAApiAnalytics.h"
#import "USRVWebViewCallback.h"

typedef NS_ENUM(NSInteger, UnityAnalyticsServiceError) {
    kUnityAnalyticsServiceErrorApiNotFound,
    kUnityAnalyticsServiceErrorApiSignatureMismatch
};

NSString *NSStringFromUnityAnalyticsServiceError(UnityAnalyticsServiceError error) {
    switch (error) {
        case kUnityAnalyticsServiceErrorApiNotFound:
            return @"API_NOT_FOUND";
        case kUnityAnalyticsServiceErrorApiSignatureMismatch:
            return @"API_SIGNATURE_MISMATCH";
    }
}

@implementation UANAApiAnalytics

static id <UANAEngineDelegate> internalAnalyticsDelegate = nil;

+(id <UANAEngineDelegate>)getAnalyticsDelegate {
    return internalAnalyticsDelegate;
}

+(void)setAnalyticsDelegate:(id <UANAEngineDelegate>)analyticsDelegate {
    internalAnalyticsDelegate = analyticsDelegate;
}

+(void)WebViewExposed_addExtras:(NSString *)jsonExtras callback:(USRVWebViewCallback *)callback {
    if ([UANAApiAnalytics getAnalyticsDelegate] && [[UANAApiAnalytics getAnalyticsDelegate] conformsToProtocol:@protocol(UANAEngineDelegate)]) {
        if ([(id <UANAEngineDelegate>) [UANAApiAnalytics getAnalyticsDelegate] respondsToSelector:@selector(addExtras:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [(id <UANAEngineDelegate>) [UANAApiAnalytics getAnalyticsDelegate] addExtras:jsonExtras];
            });
            [callback invoke:nil];
        } else {
            // callback with error
            [callback error:NSStringFromUnityAnalyticsServiceError(kUnityAnalyticsServiceErrorApiSignatureMismatch) arg1:jsonExtras, nil];
        }
    } else {
        // callback with error
        [callback error:NSStringFromUnityAnalyticsServiceError(kUnityAnalyticsServiceErrorApiNotFound) arg1:jsonExtras, nil];
    }
}

@end
