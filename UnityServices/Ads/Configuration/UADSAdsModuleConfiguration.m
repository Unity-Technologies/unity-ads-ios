#import "UADSAdsModuleConfiguration.h"
#import "UADSPlacement.h"
#import "UADSLoadModule.h"
#import "UADSWebViewShowOperation.H"
#import "UADSTokenStorage.h"

@implementation UADSAdsModuleConfiguration

- (NSArray<NSString*>*)getWebAppApiClassList {
    return @[
             @"UADSApiListener",
             @"UADSApiAdUnit",
             @"UADSApiVideoPlayer",
             @"UADSApiWebPlayer",
             @"UADSApiPlacement",
             @"UADSApiPurchasing",
             @"UADSAdsProperties",
             @"UADSApiLoad",
             @"UADSApiToken"
             ];
}

- (BOOL)resetState:(USRVConfiguration *)configuration {
    [UADSPlacement reset];
    [UADSWebViewShowOperation setConfiguration:configuration];
    [UADSLoadModule setConfiguration:configuration];
    [[UADSTokenStorage sharedInstance] deleteTokens];
    return true;
}

- (BOOL)initModuleState:(USRVConfiguration *)configuration {
    [UADSWebViewShowOperation setConfiguration:configuration];
    [UADSLoadModule setConfiguration:configuration];
    return true;
}

- (BOOL)initErrorState:(USRVConfiguration *)configuration state:(NSString *)state message:(NSString *)message {
    return true;
}

- (BOOL)initCompleteState:(USRVConfiguration *)configuration {
    [UADSWebViewShowOperation setConfiguration:configuration];
    [UADSLoadModule setConfiguration:configuration];
    return true;
}

- (NSDictionary<NSString*, NSString*>*)getAdUnitViewHandlers {
    return @{@"webview" : @"UADSWebViewHandler",
             @"videoplayer" : @"UADSVideoPlayerHandler",
             @"webplayer" : @"UADSWebPlayerHandler"
             };
}

@end
