#import "GMAQuerySignalReader.h"
#import "GMALoaderBase.h"
#import "GMAInterstitialAdDelegateProxy.h"
#import "GADInterstitialBridge.h"
NS_ASSUME_NONNULL_BEGIN
/**
     Class that provides full flow for loading GADInterstitial. Contains internal storage for saving GADInterstitial and InterstitialDelegateProxy for each placementID so they can be retrieved during `show` call.
 */
@interface GMAInterstitialAdLoaderV7 : GMALoaderBase<GADInterstitialBridge *, GMAInterstitialAdDelegateProxy *>
@end

NS_ASSUME_NONNULL_END
