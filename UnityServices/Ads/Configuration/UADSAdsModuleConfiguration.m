#import "UADSAdsModuleConfiguration.h"
#import "UADSPlacement.h"
#import "UADSWebViewShowOperation.H"
#import "UADSTokenStorage.h"
#import "UADSAbstractModule.h"
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
             @"UADSApiShow",
             @"UADSApiToken"
             ];
}

- (BOOL)resetState:(USRVConfiguration *)configuration {
    [UADSPlacement reset];
    [self setConfigurationToRequiredModules: configuration];
    [[UADSTokenStorage sharedInstance] deleteTokens];
    return true;
}

- (BOOL)initModuleState:(USRVConfiguration *)configuration {
    [self setConfigurationToRequiredModules: configuration];
    return true;
}

- (BOOL)initErrorState:(USRVConfiguration *)configuration state:(NSString *)state message:(NSString *)message {
    return true;
}

- (BOOL)initCompleteState:(USRVConfiguration *)configuration {
    [self setConfigurationToRequiredModules: configuration];
    return true;
}


-(void)setConfigurationToRequiredModules:(USRVConfiguration *)configuration {
    USRVConfiguration *config = configuration ?: [USRVConfiguration new];
    [UADSWebViewShowOperation setConfiguration: config];
    [UADSAbstractModule setConfiguration: config];
}

- (NSDictionary<NSString*, NSString*>*)getAdUnitViewHandlers {
    return @{@"webview" : @"UADSWebViewHandler",
             @"videoplayer" : @"UADSVideoPlayerHandler",
             @"webplayer" : @"UADSWebPlayerHandler"
             };
}

@end
