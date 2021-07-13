#import "GMAQuerySignalReader.h"
#import "GMALoaderBase.h"
#import "GADInterstitialAdBridgeV8.h"
#import "GMAInterstitialAdDelegateProxy.h"
NS_ASSUME_NONNULL_BEGIN

@interface GMAInterstitialAdLoaderV8 : GMALoaderBase<GADInterstitialAdBridgeV8 *, GMAInterstitialAdDelegateProxy *>

@end

NS_ASSUME_NONNULL_END
