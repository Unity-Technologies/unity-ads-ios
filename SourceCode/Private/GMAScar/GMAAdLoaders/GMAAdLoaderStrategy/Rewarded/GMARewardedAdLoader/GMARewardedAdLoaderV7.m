
#import "GMARewardedAdLoaderV7.h"
#import "GADInterstitialBridge.h"
#import "GMAError.h"
#import "GADRequestBridge.h"
#import "NSError+UADSError.h"
#import "GMAGenericAdsDelegateObject.h"

typedef GMAGenericAdsDelegateObject<GADRewardedAdBridge *, GMARewardedAdDelegateProxy *> StoredObject;

@implementation GMARewardedAdLoaderV7


+ (BOOL)isSupported {
    return [super isSupported] &&  [GADRewardedAdBridge exists];
}

- (void)loadAdUsingMetaData: (GMAAdMetaData *)meta andCompletion: (UADSLoadAdCompletion *)completion {
    id<UADSError>returnedError;
    GADRequestBridge *request = [self.requestFactory getAdRequestFor: meta
                                                               error: &returnedError];

    if (returnedError) {
        [completion error: returnedError];
        return;
    }

    GADRewardedAdBridge *rewardedAd =  [GADRewardedAdBridge newWithAdUnitID: meta.adUnitID];

    if (!rewardedAd.isValid) {
        [completion error: [GMAError newCannotCreateAd: meta]];
        return;
    }

    [rewardedAd loadRequest: request
          completionHandler: ^(NSError *_Nullable error) {
         if (error) {
             GMAError *gmaError = [GMAError newLoadErrorUsingMetaData: meta
                                                             andError: error];
             [completion error: gmaError];
         } else {
             [self saveAdWithMetaData: rewardedAd
                             metaData: meta];
             [completion success: rewardedAd];
         }
     }];
}

- (void)saveAdWithMetaData: (GADRewardedAdBridge *)ad metaData: (GMAAdMetaData *)meta {
    GMARewardedAdDelegateProxy *delegate =  [self.delegatesFactory rewardedDelegate: meta];
    StoredObject *adContainer = [StoredObject newWithAd: ad
                                               delegate: delegate];

    [self.storage setValue: adContainer
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

    [adContainer.storedAd presentFromRootViewController: viewController
                                            andDelegate: adContainer.storedDelegate];
}

@end
