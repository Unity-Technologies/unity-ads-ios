#import "UADSWebViewShowOperation.h"
#import "UADSClientProperties.h"
#import "UADSPlacement.h"
#import "UADSCacheQueue.h"
#import "UADSConnectivityMonitor.h"
#import "UADSSdkProperties.h"

@implementation UADSWebViewShowOperation

- (instancetype)initWithPlacementId:(NSString *)placementId parametersDictionary:(NSDictionary *)parametersDictionary {
    NSArray *params = @[placementId, parametersDictionary];
    self = [super initWithMethod:@"show" webViewClass:@"webview" parameters:params waitTime:[UADSSdkProperties getShowTimeout] / 1000];
    return self;
}

- (void)main {
    [super main];

    if (!self.success) {
        UADSLogError(@"Unity Ads webapp timeout, shutting down Unity Ads");
        id delegate = [UADSClientProperties getDelegate];
        if (delegate) {
            if ([delegate respondsToSelector:@selector(unityAdsDidError:withMessage:)]) {
                [delegate unityAdsDidError:kUnityAdsErrorShowError withMessage:@"Webapp timeout, shutting down Unity Ads"];
            }
            if ([delegate respondsToSelector:@selector(unityAdsDidFinish:withFinishState:)]) {
                NSString *placementId = [self.parameters objectAtIndex:1];
                [delegate unityAdsDidFinish:placementId withFinishState:kUnityAdsFinishStateError];
            }
        }
        
        [UADSPlacement reset];
        [UADSCacheQueue cancelAllDownloads];
        [UADSConnectivityMonitor stopAll];
    }
    else {
        UADSLogDebug(@"SHOW SUCCESS");
    }
}

+ (void)callback:(NSArray *)params {
    if ([[params objectAtIndex:0] isEqualToString:@"OK"]) {
        [super callback:params];
    }
}

@end