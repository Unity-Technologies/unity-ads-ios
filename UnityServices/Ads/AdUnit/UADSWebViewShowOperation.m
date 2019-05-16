#import "UADSWebViewShowOperation.h"
#import "UADSProperties.h"

@implementation UADSWebViewShowOperation

- (instancetype)initWithPlacementId:(NSString *)placementId parametersDictionary:(NSDictionary *)parametersDictionary {
    NSArray *params = @[placementId, parametersDictionary];
    self = [super initWithMethod:@"show" webViewClass:@"webview" parameters:params waitTime:[UADSProperties getShowTimeout] / 1000];
    return self;
}

- (void)main {
    [super main];

    if (!self.success) {
        USRVLogError(@"Unity Ads webapp timeout, shutting down Unity Ads");
        dispatch_async(dispatch_get_main_queue(), ^{
            id delegate = [UADSProperties getDelegate];
            if (delegate) {
                if ([delegate respondsToSelector:@selector(unityAdsDidError:withMessage:)]) {
                    [delegate unityAdsDidError:kUnityAdsErrorShowError withMessage:@"Webapp timeout, shutting down Unity Ads"];
                }
                if ([delegate respondsToSelector:@selector(unityAdsDidFinish:withFinishState:)]) {
                    NSString *placementId = [self.parameters objectAtIndex:0];
                    [delegate unityAdsDidFinish:placementId withFinishState:kUnityAdsFinishStateError];
                }
            }
        });
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
