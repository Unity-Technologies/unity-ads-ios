#import "UnityAds.h"
#import "UADSBannerProperties.h"
#import "UADSWebViewBannerShowOperation.h"
#import "UADSWebViewBannerHideOperation.h"
#import "USRVWebViewMethodInvokeQueue.h"
#import "UADSPlacement.h"

@implementation UnityAdsBanner

+(void)loadBanner {
    [self loadBanner:[UADSPlacement getDefaultBannerPlacement]];
}

+(void)loadBanner:(nonnull NSString *)placementId {
    if ([UnityAds isReady:placementId]) {
        USRVLogInfo(@"Unity Ads opening banner ad unit for placement %@", placementId);
        UADSWebViewBannerShowOperation *operation = [[UADSWebViewBannerShowOperation alloc] initWithPlacementId:placementId];

        [USRVWebViewMethodInvokeQueue addOperation:operation];
    } else {
        BOOL isSupported = [UnityAds isSupported];
        if (!isSupported) {
            [self handleShowError:placementId message:@"Unity Ads is not supported for this device"];
        } else if (![UnityAds isInitialized]) {
            [self handleShowError:placementId message:@"Unity Ads is not initialized"];
        } else {
            NSString *message = [NSString stringWithFormat:@"Placement \"%@""\" is not ready", placementId];
            [self handleShowError:placementId message:message];
        }
    }
}

+(void)destroy {
    USRVLogInfo(@"Unity Ads destroying current banner ad unit.");
    UADSWebViewBannerHideOperation *operation = [[UADSWebViewBannerHideOperation alloc] init];

    [USRVWebViewMethodInvokeQueue addOperation:operation];
}

+(id <UnityAdsBannerDelegate>)getDelegate {
    return [UADSBannerProperties getDelegate];
}

+(void)setDelegate:(id <UnityAdsBannerDelegate>)delegate {
    [UADSBannerProperties setDelegate:delegate];
}

+(void)handleShowError:(NSString *)placementId message:(NSString *)message {
    NSString *errorMessage = [NSString stringWithFormat:@"Unity Ads Banner load failed: %@", message];
    USRVLogError(@"%@", errorMessage);
    if ([self getDelegate] && [[self getDelegate] respondsToSelector:@selector(unityAdsBannerDidError:)]) {
        [[self getDelegate] unityAdsBannerDidError:errorMessage];
    }
}

@end
