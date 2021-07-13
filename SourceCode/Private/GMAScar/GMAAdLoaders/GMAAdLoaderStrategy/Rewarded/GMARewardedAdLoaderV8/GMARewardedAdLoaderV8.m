#import "GMARewardedAdLoaderV8.h"
#import "GMAGenericAdsDelegateObject.h"
#import "NSError+UADSError.h"
#import "GMAError.h"


typedef GMAGenericAdsDelegateObject<GADRewardedAdBridgeV8 *, GMARewardedAdDelegateProxy *> StoredObject;

@implementation GMARewardedAdLoaderV8


+ (BOOL)isSupported {
    return [super isSupported] && [GADRewardedAdBridgeV8 exists];
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

    [GADRewardedAdBridgeV8 loadWithAdUnitID: meta.adUnitID
                                    request: request
                          completionHandler: ^(GADRewardedAdBridgeV8 *_Nonnull ad, NSError *_Nonnull error) {
         if (error) {
             GMAError *gmaError = [GMAError newLoadErrorUsingMetaData: meta
                                                             andError: error];
             [completion error: gmaError];
         } else {
             [self saveAdWithMetaData: ad
                             metaData: meta];
             [completion success: ad];
         }
     }];
}

- (void)saveAdWithMetaData: (GADRewardedAdBridgeV8 *)ad metaData: (GMAAdMetaData *)meta {
    GMARewardedAdDelegateProxy *delegate =  [self.delegatesFactory rewardedDelegate: meta];
    StoredObject *adContainer = [StoredObject newWithAd: ad
                                               delegate: delegate];

    [ad setDelegate: delegate];
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
                               userDidEarnRewardHandler: ^{
                                   [adContainer.storedDelegate didEarnReward: adContainer.storedAd];
                               }];
}

@end
