#import "UADSWebViewShowOperation.h"
#import "UADSProperties.h"
#import "UnityAdsDelegateUtil.h"

@implementation UADSWebViewShowOperation

- (instancetype)initWithPlacementId:(NSString *)placementId parametersDictionary:(NSDictionary *)parametersDictionary {
    NSArray *params = @[placementId, parametersDictionary];
    self = [super initWithMethod:@"show" webViewClass:@"webview" parameters:params waitTime:[UADSProperties getShowTimeout] / 1000];
    return self;
}

- (void)main {
    [super main];

    if (!self.success) {
        NSString *placementId = [self.parameters objectAtIndex:0];
        USRVLogError(@"Unity Ads webapp timeout, shutting down Unity Ads");
        [UnityAdsDelegateUtil unityAdsDidError:kUnityAdsErrorShowError withMessage:@"Webapp timeout, shutting down Unity Ads"];
        [UnityAdsDelegateUtil unityAdsDidFinish:placementId withFinishState:kUnityAdsFinishStateError];
    }
    else {
        USRVLogDebug(@"SHOW SUCCESS");
    }
}

+ (void)callback:(NSArray *)params {
    if ([[params objectAtIndex:0] isEqualToString:@"OK"]) {
        [super callback:params];
    }
}

@end
