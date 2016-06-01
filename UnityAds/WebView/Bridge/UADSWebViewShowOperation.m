#import "UADSWebViewShowOperation.h"
#import "UADSClientProperties.h"
#import "UADSApiPlacement.h"
#import "UADSCacheQueue.h"
#import "UADSConnectivityMonitor.h"

@implementation UADSWebViewShowOperation

- (instancetype)initWithPlacementId:(NSString *)placementId parametersDictionary:(NSDictionary *)parametersDictionary {
    NSArray *params = @[placementId, parametersDictionary];
    self = [super initWithMethod:@"show" webViewClass:@"webview" parameters:params waitTime:20];
    return self;
}

- (void)main {
    [super main];

    if (!self.success) {
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
        
        [UADSApiPlacement reset];
        [UADSCacheQueue cancelAllDownloads];
        [UADSConnectivityMonitor stopAll];
    }
    else {
        UADSLog(@"SHOW SUCCESS");
    }
}

+ (void)callback:(NSArray *)params {
    if ([[params objectAtIndex:0] isEqualToString:@"OK"]) {
        [super callback:params];
    }
}

@end