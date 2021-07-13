#import "GMAInterstitialAdLoaderV7.h"
#import "GMAError.h"
#import "GADRequestBridge.h"
#import "GMAGenericAdsDelegateObject.h"

typedef GMAGenericAdsDelegateObject<GADInterstitialBridge *, GMAInterstitialAdDelegateProxy *> StoredObject;

@implementation GMAInterstitialAdLoaderV7

+ (BOOL)isSupported {
    return [super isSupported] && [GADInterstitialBridge exists];
}

- (void)loadAdUsingMetaData: (GMAAdMetaData *)meta
              andCompletion: (UADSLoadAdCompletion *)completion; {
    id<UADSError>returnedError;
    GADRequestBridge *request = [self.requestFactory getAdRequestFor: meta
                                                               error: &returnedError];

    if (returnedError) {
        [completion error: returnedError];
        return;
    }

    GADInterstitialBridge *interstitialAd = [GADInterstitialBridge newWithAdUnitID: meta.adUnitID];

    if (!interstitialAd.isValid) {
        [completion error: [GMAError newCannotCreateAd: meta]];
        return;
    }

    [self saveAdUsingMetaData: meta
                           ad: interstitialAd
                andCompletion: completion];
    [interstitialAd loadRequest: request];
}

- (void)saveAdUsingMetaData: (GMAAdMetaData *)meta
                         ad: (GADInterstitialBridge *)ad
              andCompletion: (UADSLoadAdCompletion *)completion {
    GMAInterstitialAdDelegateProxy *delegate = [self.delegatesFactory interstitialDelegate: meta
                                                                             andCompletion: completion];

    [ad setDelegate: delegate];

    StoredObject *adContainer = [StoredObject newWithAd: ad
                                               delegate: delegate];

    [self.storage setObject: adContainer
                     forKey: meta.placementID];
}

- (void)showAdUsingMetaData: (GMAAdMetaData *)meta
           inViewController: (UIViewController *)viewController
                      error: (id<UADSError>  _Nullable __autoreleasing *)error {
    [super showAdUsingMetaData: meta
              inViewController: viewController
                         error: error];
    StoredObject *adContainer = [self.storage objectForKey: meta.placementID];

    if (!adContainer) {
        *error = [GMAError newNoAdFoundToShowForMeta: meta];
        return;
    }

    [adContainer.storedAd presentFromRootViewController: viewController];
}

@end
