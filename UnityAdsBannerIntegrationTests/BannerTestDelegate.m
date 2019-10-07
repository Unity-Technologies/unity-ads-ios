#import "BannerTestDelegate.h"

@implementation BannerTestDelegate

// MARK UnityAdsBannerDelegate

- (void)bannerViewDidLoad:(UADSBannerView *)bannerView {
    if (_didLoadBlock) {
        _didLoadBlock(bannerView);
    }
}

- (void)bannerViewDidClick:(UADSBannerView *)bannerView {
    if (_didClickBlock) {
        _didClickBlock(bannerView);
    }
}

- (void)bannerViewDidLeaveApplication:(UADSBannerView *)bannerView {
    if (_didLeaveApplicationBlock) {
        _didLeaveApplicationBlock(bannerView);
    }
}

- (void)bannerViewDidError:(UADSBannerView *)bannerView error:(UADSBannerError *)error {
    if (_didErrorBlock) {
        _didErrorBlock(bannerView, error);
    }
}

@end
