#import <UIKit/UIKit.h>
#import "UADSBannerView.h"
#import "GADBannerViewBridge.h"
#import "UADSWebViewEventSender.h"
#import "GMAAdMetaData.h"
#import "UADSGMAScar.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSGADBannerWrapper : UIView
@property (nonatomic, strong) GADBannerViewBridge *gadBanner;

+ (instancetype)newWithMeta: (GMAAdMetaData *)meta eventSender: (id<UADSWebViewEventSender>)eventSender gmaScar:(UADSGMAScar*)gmaScar;
- (void)addToBannerView: (UADSBannerView *)bannerView withSize: (CGSize)size;
- (void)updateGADBannerRootViewController;

@end

NS_ASSUME_NONNULL_END
