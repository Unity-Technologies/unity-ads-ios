#import "UADSAbstractModuleDelegate.h"
#import "UADSBannerViewDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSBannerLoadModuleDelegateWrapper : NSObject<UADSBannerViewDelegate, UADSAbstractModuleDelegate>
+ (instancetype)newWithAdsDelegate: (id<UADSBannerViewDelegate>)decorated bannerView:(UADSBannerView *)bannerView;

@property (nonatomic, weak, readonly) UADSBannerView *bannerView;
@end

NS_ASSUME_NONNULL_END
