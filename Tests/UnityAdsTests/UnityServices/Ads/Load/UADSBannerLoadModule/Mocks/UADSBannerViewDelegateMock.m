#import "UADSBannerViewDelegateMock.h"
#import "UADSTools.h"
#import "UnityAdsLoadError.h"

@implementation UADSBannerViewDelegateMock

- (instancetype)init {
    SUPER_INIT
    self.succeedBanners = [NSArray new];
    self.failedBanners = [NSArray new];
    self.errorCodes = [NSArray new];
    self.errorMessages = [NSArray new];
    self.clickedBanners = [NSArray new];
    self.leaveAppBanners = [NSArray new];
    self.showedBanners = [NSArray new];
    return self;
}

- (void)bannerViewDidLoad: (UADSBannerView *)bannerView {
    _succeedBanners = [_succeedBanners arrayByAddingObject:bannerView];
    [self.expectation fulfill];
}

- (void)bannerViewDidShow:(UADSBannerView *)bannerView {
    _showedBanners = [_showedBanners arrayByAddingObject:bannerView];
    [self.expectation fulfill];
}
 
- (void)bannerViewDidClick: (UADSBannerView *)bannerView {
    _clickedBanners = [_clickedBanners arrayByAddingObject:bannerView];
    [self.expectation fulfill];
}

- (void)bannerViewDidLeaveApplication: (UADSBannerView *)bannerView {
    _leaveAppBanners = [_leaveAppBanners arrayByAddingObject:bannerView];
    [self.expectation fulfill];
}

- (void)bannerViewDidError: (UADSBannerView *)bannerView error: (UADSBannerError *)error {
    _failedBanners = [_failedBanners arrayByAddingObject:bannerView];
    _errorCodes = [_errorCodes arrayByAddingObject: [NSNumber numberWithInteger: error.code]];
    _errorMessages = [_errorMessages arrayByAddingObject: error.description];
    [self.expectation fulfill];
}

@end
