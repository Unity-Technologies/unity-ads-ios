#import "UADSProxyReflection.h"
#import "GADRequestBridge.h"
#import "GADFullScreenContentDelegateProxy.h"
#import <UIKit/UIKit.h>
#import "GADBaseAd.h"
NS_ASSUME_NONNULL_BEGIN

@interface GADRewardedAdBridgeV8 : GADBaseAd
typedef void (^GADRewardedAdBridgeV8Completion)(GADRewardedAdBridgeV8 *ad, NSError *error);
typedef void (^GADRewardedAdDidEarnRewardCompletion)(void);

+ (void)loadWithAdUnitID: (NSString *)adUnitID
                 request: (GADRequestBridge *)request
       completionHandler: (GADRewardedAdBridgeV8Completion)completion;

- (void)presentFromRootViewController: (UIViewController *)viewController
             userDidEarnRewardHandler: (GADRewardedAdDidEarnRewardCompletion)completion;

- (void)setDelegate: (id<UADSGADFullScreenContentDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
