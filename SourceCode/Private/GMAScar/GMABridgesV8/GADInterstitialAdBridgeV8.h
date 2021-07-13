#import "UADSProxyReflection.h"
#import "GADRequestBridge.h"
#import "GADFullScreenContentDelegateProxy.h"
#import <UIKit/UIKit.h>
#import "GADBaseAd.h"

NS_ASSUME_NONNULL_BEGIN

@interface GADInterstitialAdBridgeV8 : GADBaseAd
typedef void (^GADInterstitialAdV8Completion)(GADInterstitialAdBridgeV8 *ad, NSError *error);

+ (void)loadWithAdUnitID: (NSString *)adUnitID
                 request: (GADRequestBridge *)request
       completionHandler: (GADInterstitialAdV8Completion)completion;

- (void)presentFromRootViewController: (UIViewController *)viewController;

- (void)setDelegate: (id<UADSGADFullScreenContentDelegate>)delegate;


@end

NS_ASSUME_NONNULL_END
