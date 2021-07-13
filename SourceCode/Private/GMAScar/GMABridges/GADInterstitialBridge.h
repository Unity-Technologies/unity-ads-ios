#import "GADRequestBridge.h"
#import "UADSProxyReflection.h"
#import "GMAInterstitialAdDelegateProxy.h"
#import <UIKit/UIKit.h>
#import "GADBaseAd.h"

NS_ASSUME_NONNULL_BEGIN

@interface GADInterstitialBridge : GADBaseAd
+ (instancetype)newWithAdUnitID: (NSString *)ID;
- (void)loadRequest: (nonnull GADRequestBridge *)request;
- (void)setDelegate: (GMAInterstitialAdDelegateProxy *)delegate;
- (void)presentFromRootViewController: (UIViewController *)viewController;
@end

NS_ASSUME_NONNULL_END
