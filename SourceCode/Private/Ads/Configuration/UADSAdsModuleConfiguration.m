#import "UADSAdsModuleConfiguration.h"
#import "UADSWebViewShowOperation.H"
#import "UADSTokenStorage.h"
#import "UADSAbstractModule.h"
#import "UADSHeaderBiddingTokenReaderBuilder.h"

@implementation UADSAdsModuleConfiguration

- (NSArray<NSString *> *)getWebAppApiClassList {
    return @[
        @"UADSApiAdUnit",
        @"UADSApiVideoPlayer",
        @"UADSApiWebPlayer",
        @"UADSAdsProperties",
        @"UADSApiLoad",
        @"UADSApiShow",
        @"UADSApiToken",
        @"UADSApiGMAScar"
    ];
}

- (BOOL)resetState: (USRVConfiguration *)configuration {
    [self setConfigurationToRequiredModules: configuration];
    [[UADSTokenStorage sharedInstance] deleteTokens];
    return true;
}

- (BOOL)initModuleState: (USRVConfiguration *)configuration {
    [self setConfigurationToRequiredModules: configuration];
    return true;
}

- (BOOL)initErrorState: (USRVConfiguration *)configuration state: (NSString *)state message: (NSString *)message {
    [UADSHeaderBiddingTokenReaderBuilder.sharedInstance.defaultReader setInitToken: nil];
    [UADSHeaderBiddingTokenReaderBuilder.sharedInstance.defaultReader deleteTokens];

    return true;
}

- (BOOL)initCompleteState: (USRVConfiguration *)configuration {
    [self setConfigurationToRequiredModules: configuration];
    return true;
}

- (void)setConfigurationToRequiredModules: (USRVConfiguration *)configuration {
    USRVConfiguration *config = configuration ? : [USRVConfiguration new];

    [UADSWebViewShowOperation setConfiguration: config];
    [UADSAbstractModule setConfiguration: config];
}

- (NSDictionary<NSString *, NSString *> *)getAdUnitViewHandlers {
    return @{ @"webview": @"UADSWebViewHandler",
              @"videoplayer": @"UADSVideoPlayerHandler",
              @"webplayer": @"UADSWebPlayerHandler" };
}

@end
