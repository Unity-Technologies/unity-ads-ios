#import "GADRewardedAdBridge.h"
#import "NSInvocation+Convenience.h"

#define INIT_WITH_AD_SELECTOR @"initWithAdUnitID:"
#define PRESENT_SELECTOR      @"presentFromRootViewController:delegate:"
#define LOAD_SELECTOR         @"loadRequest:completionHandler:"
@implementation GADRewardedAdBridge

+ (NSString *)className {
    return @"GADRewardedAd";
}

+ (NSArray<NSString *> *)requiredSelectors {
    return @[INIT_WITH_AD_SELECTOR,
             LOAD_SELECTOR,
             PRESENT_SELECTOR];
}

+ (instancetype)newWithAdUnitID: (NSString *)ID {
    return [self getInstanceUsingMethod: INIT_WITH_AD_SELECTOR
                                   args: @[ID]];
}

- (void)presentFromRootViewController: (UIViewController *)viewController
                          andDelegate: (GMARewardedAdDelegateProxy *)delegate; {
    [self callInstanceMethod: PRESENT_SELECTOR
                        args: @[viewController, delegate]];
}

- (void)  loadRequest: (GADRequestBridge *)request
    completionHandler: (nullable GADRewardedAdBridgeCompletion)completionHandler {
    [self callInstanceMethod: LOAD_SELECTOR
                        args: @[request, completionHandler]];
}

@end
