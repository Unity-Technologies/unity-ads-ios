#import "GADBannerViewBridge.h"
#import "GADAdSizeBridge.h"
#import "GADAdSizeStructBox.h"

#define INIT_SELECTOR            @"initWithAdSize:"
#define LOAD_REQUEST_SELECTOR    @"loadRequest:"
#define DELEGATE_KEY             @"delegate"
#define AD_UNIT_ID_KEY           @"adUnitID"
#define ROOT_VIEW_CONTROLLER_KEY @"rootViewController"

@implementation GADBannerViewBridge

+ (NSString *)className {
    return @"GADBannerView";
}

+ (NSArray<NSString *> *)requiredSelectors {
    return @[INIT_SELECTOR];
}

+ (nullable instancetype)newWithAdSize:(CGSize)size {
    struct GADAdSizeBridge adSize;
    adSize.size = size;
    adSize.flags = 0;
    GADAdSizeStructBox *box = [GADAdSizeStructBox newWithBytes:&adSize objCType:@encode(GADAdSizeBridge)];
    return [self getInstanceUsingMethod: INIT_SELECTOR
                                   args: @[box]];
}

- (void)setAdUnitId:(nonnull NSString *)adUnitId {
    [self.proxyObject setValue: adUnitId
                        forKey: AD_UNIT_ID_KEY];
}

- (void)setRootViewController:(nonnull UIViewController *)rootViewController {
    [self.proxyObject setValue: rootViewController
                        forKey: ROOT_VIEW_CONTROLLER_KEY];
}

- (void)setDelegate: (id<UADSGADBannerViewDelegate>)delegate {
    [self.proxyObject setValue: delegate
                        forKey: DELEGATE_KEY];
}

- (void)loadRequest:(nonnull GADRequestBridge *)request {
    [self callInstanceMethod: LOAD_REQUEST_SELECTOR
                        args: @[request]];
}


@end
