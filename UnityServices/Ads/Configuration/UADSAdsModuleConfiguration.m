#import "UADSAdsModuleConfiguration.h"
#import "UADSPlacement.h"

@implementation UADSAdsModuleConfiguration

- (NSArray<NSString*>*)getWebAppApiClassList {
    return @[
             @"UADSApiListener",
             @"UADSApiAdUnit",
             @"UADSApiVideoPlayer",
             @"UADSApiWebPlayer",
             @"UADSApiPlacement",
             @"UADSApiPurchasing",
             @"UADSAdsProperties"
             ];
}

- (BOOL)resetState:(USRVConfiguration *)configuration {
    [UADSPlacement reset];
    return true;
}

- (BOOL)initModuleState:(USRVConfiguration *)configuration {
    return true;
}

- (BOOL)initErrorState:(USRVConfiguration *)configuration state:(NSString *)state message:(NSString *)message {
    return true;
}

- (BOOL)initCompleteState:(USRVConfiguration *)configuration {
    return true;
}

- (NSDictionary<NSString*, NSString*>*)getAdUnitViewHandlers {
    return @{@"webview" : @"UADSWebViewHandler",
             @"videoplayer" : @"UADSVideoPlayerHandler",
             @"webplayer" : @"UADSWebPlayerHandler"
             };
}

@end
