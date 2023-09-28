#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GADBaseAd.h"
#import "UADSProxyReflection.h"
#import "GADRequestBridge.h"
#import "GMABannerViewDelegateProxy.h"

NS_ASSUME_NONNULL_BEGIN

@interface GADBannerViewBridge : GADBaseAd
+ (nullable instancetype)newWithAdSize:(CGSize)size;

- (void)setAdUnitId:(NSString *)adUnitId;
- (void)setRootViewController:(UIViewController *)rootViewController;
- (void)setDelegate: (id<UADSGADBannerViewDelegate>)delegate;
- (void)loadRequest:(GADRequestBridge*)request;

@end

NS_ASSUME_NONNULL_END
