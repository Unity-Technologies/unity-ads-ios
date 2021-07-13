#import "UADSProxyReflection.h"
#import "GADRequestBridge.h"
#import <UIKit/UIKit.h>
#import "GMARewardedAdDelegateProxy.h"
#import "GADBaseAd.h"
NS_ASSUME_NONNULL_BEGIN

typedef void (^GADRewardedAdBridgeCompletion)(NSError *_Nullable error);

@interface GADRewardedAdBridge : GADBaseAd
+ (instancetype)newWithAdUnitID: (NSString *)ID;
- (void)  loadRequest: (nonnull GADRequestBridge *)request
    completionHandler: (nullable GADRewardedAdBridgeCompletion)completionHandler;
- (void)presentFromRootViewController: (UIViewController *)viewController
                          andDelegate: (GMARewardedAdDelegateProxy *)delegate;
@end

NS_ASSUME_NONNULL_END
