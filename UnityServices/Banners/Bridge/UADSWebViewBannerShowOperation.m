
#import "UADSWebViewBannerShowOperation.h"
#import "UADSProperties.h"
#import "UADSBannerProperties.h"

@implementation UADSWebViewBannerShowOperation

-(instancetype)initWithPlacementId:(NSString *)placementId {
    NSArray *params = @[placementId];
    self = [super initWithMethod:@"showBanner" webViewClass:@"webview" parameters:params waitTime:[UADSProperties getShowTimeout] / 1000];
    return self;
}

-(void)main {
    [super main];

    if (!self.success) {
        USRVLogError(@"Unity Ads webapp timeout, shutting down Unity Ads");
        id delegate = [UADSBannerProperties getDelegate];
        if (delegate) {
            if ([delegate respondsToSelector:@selector(unityAdsBannerDidError:)]) {
                [delegate unityAdsDidError:kUnityAdsErrorShowError withMessage:@"Webapp timeout, shutting down Unity Ads"];
            }
            if ([delegate respondsToSelector:@selector(unityAdsDidFinish:withFinishState:)]) {
                NSString *placementId = [self.parameters objectAtIndex:0];
                [delegate unityAdsDidFinish:placementId withFinishState:kUnityAdsFinishStateError];
            }
        }
    } else {
        USRVLogDebug(@"SHOW BANNER SUCCESS");
    }
}

+(void)callback:(NSArray *)params {
    if ([[params objectAtIndex:0] isEqualToString:@"OK"]) {
        [super callback:params];
    }
}

@end
