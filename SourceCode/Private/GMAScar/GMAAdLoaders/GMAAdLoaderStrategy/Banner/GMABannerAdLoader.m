#import "GMABannerAdLoader.h"

typedef GMAGenericAdsDelegateObject<GADBannerViewBridge *, GMABannerViewDelegateProxy *> StoredObject;

@implementation GMABannerAdLoader

+ (BOOL)isSupported {
    return [super isSupported] && [GADBannerViewBridge exists];
}

- (void)loadAdUsingMetaData: (GMAAdMetaData *)meta
              andCompletion: (UADSLoadAdCompletion *)completion {
    id<UADSError>returnedError;
    GADRequestBridge *request = [self.requestFactory getAdRequestFor: meta
                                                               error: &returnedError];

    if (returnedError) {
        [completion error: returnedError];
        return;
    }
    
    GADBannerViewBridge *banner = [GADBannerViewBridge newWithAdSize: meta.bannerSize];
    [banner setAdUnitId: meta.adUnitID];
    [self saveAdWithMetaData: banner
                    metaData: meta
               andCompletion: completion];
   
    meta.beforeLoad(banner);
    meta.beforeLoad = nil;
    [banner loadRequest:request];
}

- (void)saveAdWithMetaData: (GADBannerViewBridge *)ad
                  metaData: (GMAAdMetaData *)meta
             andCompletion: (UADSLoadAdCompletion *)completion {
    GMABannerViewDelegateProxy *delegate =  [self.delegatesFactory bannerDelegate: meta
                                                                    andCompletion: completion];
    StoredObject *adContainer = [StoredObject newWithAd: ad
                                               delegate: delegate];

    [ad setDelegate: delegate];
    [self.storage setValue: adContainer
                    forKey: meta.placementID];
}

@end
