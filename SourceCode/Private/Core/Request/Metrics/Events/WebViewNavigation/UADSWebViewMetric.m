#import "UADSWebViewMetric.h"

@implementation UADSWebViewMetric
+ (instancetype)newWebViewTerminated {
    return [self newWithName: @"native_webview_terminated"
                       value: nil
                        tags: nil];
}

+ (instancetype)newReloaded {
    return [self newWithName: @"native_webview_reloaded"
                       value: nil
                        tags: nil];
}

@end
