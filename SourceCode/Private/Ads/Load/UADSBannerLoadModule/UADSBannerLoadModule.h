#import "UADSLoadModule.h"
#import "UADSLoadOptions.h"
#import "UADSBannerViewDelegate.h"
#import "UnityAdsLoadError.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSBannerLoadModule : UADSLoadModule

- (void)sendClickEventForListenerID:  (NSString *_Nonnull)listenerID;

- (void)sendLeaveApplicationEventForListenerID:  (NSString *_Nonnull)listenerID;

- (NSString *)loadForPlacementID: (NSString *)placementID
                      bannerView: (UADSBannerView *)bannerView
                         options: (UADSLoadOptions *)options
                    loadDelegate: (nullable id<UADSBannerViewDelegate>)loadDelegate;

- (UADSBannerView *)bannerViewWithID:(NSString *)bannerID;


@end

NS_ASSUME_NONNULL_END
