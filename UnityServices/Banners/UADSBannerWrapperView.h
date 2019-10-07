#import <Foundation/Foundation.h>
#import "UADSBannerAdRefreshView.h"
#import "UADSBanner.h"

@interface UADSBannerWrapperView : UIView

@property(nonatomic, strong, readonly) UADSBannerAdRefreshView *bannerAdRefreshView;

- (instancetype)initWithBannerAdRefreshView:(UADSBannerAdRefreshView *)bannerAdRefreshView bannerPosition:(UnityAdsBannerPosition)bannerPosition;

@end
