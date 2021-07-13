#import "GADInterstitialAdBridgeV8.h"

#define PRESENT_SELECTOR @"presentFromRootViewController:"
#define LOAD_SELECTOR    @"loadWithAdUnitID:request:completionHandler:"
#define DELEGATE_KEY     @"fullScreenContentDelegate"

@implementation GADInterstitialAdBridgeV8
+ (NSString *)className {
    return @"GADInterstitialAd";
}

+ (NSArray<NSString *> *)requiredSelectors {
    return @[PRESENT_SELECTOR,
             LOAD_SELECTOR];
}

+ (NSArray<NSString *> *)requiredKeysForKVO {
    return @[DELEGATE_KEY];
}

+ (void)loadWithAdUnitID: (NSString *)adUnitID
                 request: (GADRequestBridge *)request
       completionHandler: (GADInterstitialAdV8Completion)completion {
    id adCompletion = ^(id interstitialAdObj, NSError *error) {
        if (interstitialAdObj) {
            GADInterstitialAdBridgeV8 *proxy = [[GADInterstitialAdBridgeV8 alloc] initWithProxyObject: interstitialAdObj];
            completion(proxy, error);
        } else {
            completion(interstitialAdObj, error);
        }
    };

    [self callClassMethod: LOAD_SELECTOR
                     args: @[adUnitID, request, adCompletion]];
}

- (void)presentFromRootViewController: (UIViewController *)viewController {
    [self callInstanceMethod: PRESENT_SELECTOR
                        args: @[viewController]];
}

- (void)setDelegate: (id<UADSGADFullScreenContentDelegate>)delegate {
    [self.proxyObject setValue: delegate
                        forKey: DELEGATE_KEY];
}

@end
