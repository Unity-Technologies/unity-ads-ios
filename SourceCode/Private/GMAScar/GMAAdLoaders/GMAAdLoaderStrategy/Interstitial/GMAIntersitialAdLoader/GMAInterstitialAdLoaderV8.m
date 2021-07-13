#import "GMAInterstitialAdLoaderV8.h"
#import "NSError+UADSError.h"
#import "GMAGenericAdsDelegateObject.h"
#import "GMAError.h"
#import "GMASCARSignalsReader.h"

typedef GMAGenericAdsDelegateObject<GADInterstitialAdBridgeV8 *, GMAInterstitialAdDelegateProxy *> StoredObject;

@implementation GMAInterstitialAdLoaderV8

+ (BOOL)isSupported {
    return [super isSupported] && [GADInterstitialAdBridgeV8 exists];
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

    [GADInterstitialAdBridgeV8 loadWithAdUnitID: meta.adUnitID
                                        request: request
                              completionHandler: ^(GADInterstitialAdBridgeV8 *_Nonnull ad, NSError *_Nonnull error) {
         if (error) {
             GMAError *gmaError = [GMAError newLoadErrorUsingMetaData: meta
                                                             andError: error];
             [completion error: gmaError];
         } else {
             [self saveAdUsingMetaData: meta
                                    ad: ad
                         andCompletion: completion];
             [completion success: ad];
         }
     }];
}

- (void)saveAdUsingMetaData: (GMAAdMetaData *)meta
                         ad: (GADInterstitialAdBridgeV8 *)ad
              andCompletion: (UADSLoadAdCompletion *)completion {
    GMAInterstitialAdDelegateProxy *delegate = [self.delegatesFactory interstitialDelegate: meta
                                                                             andCompletion: [UADSAnyCompletion new]];


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
