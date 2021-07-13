#import "GADInterstitialBridge.h"
#import "NSInvocation+Convenience.h"

#define INIT_WITH_AD_SELECTOR @"initWithAdUnitID:"
#define PRESENT_SELECTOR      @"presentFromRootViewController:"
#define LOAD_SELECTOR         @"loadRequest:"
#define DELEGATE_KEY          @"delegate"
@implementation GADInterstitialBridge

+ (NSString *)className {
    return @"GADInterstitial";
}

+ (NSArray<NSString *> *)requiredSelectors {
    return [super.requiredSelectors arrayByAddingObjectsFromArray: @[INIT_WITH_AD_SELECTOR,
                                                                     LOAD_SELECTOR,
                                                                     PRESENT_SELECTOR]];
}

+ (NSArray<NSString *> *)requiredKeysForKVO {
    return @[DELEGATE_KEY];
}

- (void)loadRequest: (nonnull GADRequestBridge *)request {
    [self callInstanceMethod: LOAD_SELECTOR
                        args: @[request]];
}

- (void)presentFromRootViewController: (UIViewController *)viewController {
    [self callInstanceMethod: PRESENT_SELECTOR
                        args: @[viewController]];
}

+ (instancetype)newWithAdUnitID: (NSString *)ID {
    return [self getInstanceUsingMethod: INIT_WITH_AD_SELECTOR
                                   args: @[ID]];
}

- (void)setDelegate: (GMAInterstitialAdDelegateProxy *)delegate {
    [self.proxyObject setValue: delegate
                        forKey: DELEGATE_KEY];
}

@end
