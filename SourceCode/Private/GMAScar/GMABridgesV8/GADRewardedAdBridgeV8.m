#import "GADRewardedAdBridgeV8.h"
#define PRESENT_SELECTOR @"presentFromRootViewController:userDidEarnRewardHandler:"
#define LOAD_SELECTOR    @"loadWithAdUnitID:request:completionHandler:"
#define DELEGATE_KEY     @"fullScreenContentDelegate"

@implementation GADRewardedAdBridgeV8

+ (NSString *)className {
    return @"GADRewardedAd";
}

+ (NSArray<NSString *> *)requiredSelectors {
    return @[PRESENT_SELECTOR,
             LOAD_SELECTOR];
}

+ (NSArray<NSString *> *)requiredKeysForKVO {
    return [[super requiredKeysForKVO] arrayByAddingObjectsFromArray: @[DELEGATE_KEY]];
}

+ (void)loadWithAdUnitID: (NSString *)adUnitID
                 request: (GADRequestBridge *)request
       completionHandler: (GADRewardedAdBridgeV8Completion)completion {
    id adCompletion = ^(id rewardedAdObj, NSError *error) {
        if (rewardedAdObj) {
            GADRewardedAdBridgeV8 *proxy = [[GADRewardedAdBridgeV8 alloc] initWithProxyObject: rewardedAdObj];
            completion(proxy, error);
        } else {
            completion(rewardedAdObj, error);
        }
    };

    [self callClassMethod: LOAD_SELECTOR
                     args: @[adUnitID, request, adCompletion]];
}

- (void)presentFromRootViewController: (UIViewController *)viewController
             userDidEarnRewardHandler: (GADRewardedAdDidEarnRewardCompletion)completion {
    [self callInstanceMethod: PRESENT_SELECTOR
                        args: @[viewController, completion]];
}

- (void)setDelegate: (id<UADSGADFullScreenContentDelegate>)delegate {
    [self.proxyObject setValue: delegate
                        forKey: DELEGATE_KEY];
}

@end
