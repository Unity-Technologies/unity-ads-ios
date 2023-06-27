#import "UADSBannerLoadModuleDelegateWrapper.h"

@interface UADSBannerLoadModuleDelegateWrapper()
@property (nonatomic, strong) id<UADSBannerViewDelegate>decorated;
@property (nonatomic, weak) UADSBannerView *bannerView;
@property (nonatomic, copy) NSString *uuidString;
@end

@implementation UADSBannerLoadModuleDelegateWrapper

+ (instancetype)newWithAdsDelegate: (id<UADSBannerViewDelegate>)decorated bannerView:(nonnull UADSBannerView *)bannerView {
    UADSBannerLoadModuleDelegateWrapper *wrapper = [UADSBannerLoadModuleDelegateWrapper new];
    wrapper.uuidString = [NSUUID new].UUIDString;
    wrapper.decorated = decorated;
    wrapper.bannerView = bannerView;
    return wrapper;
}

- (void)didFailWithError:(UADSInternalError * _Nonnull)error forPlacementID:(NSString * _Nonnull)placementID {
    UADSBannerError *bannerError = [[UADSBannerError alloc] initWithCode: [self convertIntoPublicError:error]
                                                                userInfo: @{ NSLocalizedDescriptionKey: error.errorMessage }];
    [self bannerViewDidError: self.bannerView
                       error: bannerError];
}

- (void)bannerViewDidLoad: (UADSBannerView *)bannerView {
    dispatch_on_main( ^{
        [self.decorated bannerViewDidLoad: self.bannerView];
    });
}

- (void)bannerViewDidShow:(UADSBannerView *)bannerView {
    dispatch_on_main( ^{
        [self.decorated bannerViewDidShow: self.bannerView];
    });
}

- (void)bannerViewDidClick: (UADSBannerView *)bannerView {
    dispatch_on_main( ^{
        [self.decorated bannerViewDidClick: self.bannerView];
    });
}

- (void)bannerViewDidLeaveApplication: (UADSBannerView *)bannerView {
    dispatch_on_main( ^{
        [self.decorated bannerViewDidLeaveApplication: self.bannerView];
    });
}

- (void)bannerViewDidError: (UADSBannerView *)bannerView error: (UADSBannerError *)error {
    dispatch_on_main( ^{
        [self.decorated bannerViewDidError: self.bannerView error: error];
    });
}

- (UADSBannerErrorCode)convertIntoPublicError: (UADSInternalError *)error {
    if (error.errorCode == kUADSInternalErrorAbstractModule && error.reasonCode == kUADSInternalErrorAbstractModuleTimeout) {
        return UADSBannerErrorCodeNativeError;
    }

    if (error.errorCode == kUADSInternalErrorWebView && error.reasonCode == kUADSInternalErrorWebViewInternal) {
        return UADSBannerErrorCodeWebViewError;
    }

    if (error.errorCode == kUADSInternalErrorWebView && error.reasonCode == kUADSInternalErrorWebViewSDKNotInitialized) {
        return UADSBannerErrorInitializeFailed;
    }

    if (error.errorCode == kUADSInternalErrorAbstractModule && error.reasonCode == kUADSInternalErrorAbstractModuleEmptyPlacementID) {
        return UADSBannerErrorInvalidArgument;
    }

    return error.reasonCode;
}

@end
