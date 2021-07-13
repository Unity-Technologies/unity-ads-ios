#import "UADSWebPlayerBridge.h"
#import "USRVWebViewApp.h"
#import "UADSWebPlayerEvent.h"
#import "USRVWebViewEventCategory.h"

@implementation UADSWebPlayerBridge

+ (void)sendFrameUpdate: (NSString *)viewId frame: (CGRect)frame alpha: (CGFloat)alpha {
    USRVWebViewApp *currentApp = [USRVWebViewApp getCurrentApp];

    if (currentApp) {
        NSNumber *x = [NSNumber numberWithFloat: frame.origin.x];
        NSNumber *y = [NSNumber numberWithFloat: frame.origin.y];
        NSNumber *width = [NSNumber numberWithFloat: frame.size.width];
        NSNumber *height = [NSNumber numberWithFloat: frame.size.height];
        NSNumber *alphaNumber = [NSNumber numberWithFloat: alpha];
        [currentApp sendEvent: UADSNSStringFromWebPlayerEvent(kUnityAdsWebPlayerFrameUpdate)
                     category: USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryWebPlayer)
                       params: @[viewId, x, y, width, height, alphaNumber]];
    }
}

+ (void)sendGetFrameResponse: (NSString *)callId viewId: (NSString *)viewId frame: (CGRect)frame alpha: (CGFloat)alpha {
    USRVWebViewApp *currentApp = [USRVWebViewApp getCurrentApp];

    if (currentApp) {
        NSNumber *x = [NSNumber numberWithFloat: frame.origin.x];
        NSNumber *y = [NSNumber numberWithFloat: frame.origin.y];
        NSNumber *width = [NSNumber numberWithFloat: frame.size.width];
        NSNumber *height = [NSNumber numberWithFloat: frame.size.height];
        NSNumber *alphaNumber = [NSNumber numberWithFloat: alpha];
        [currentApp sendEvent: UADSNSStringFromWebPlayerEvent(kUnityAdsWebPlayerGetFrameResponse)
                     category: USRVNSStringFromWebViewEventCategory(kUnityServicesWebViewEventCategoryWebPlayer)
                       params: @[callId, viewId, x, y, width, height, alphaNumber]];
    }
}

@end
