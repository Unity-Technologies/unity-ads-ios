#import "UADSWebKitLoader.h"

@implementation UADSWebKitLoader

+ (NSString *)frameworkName {
    return @"WebKit";
}

+ (NSString *)classNameForCheck {
    return @"WKWebView";
}

@end
