#import <UIKit/UIKit.h>
#import "UIView+Subview.h"
#import "UADSGADBannerWrapper.h"
#import "UIViewController+TopController.h"
#import "UIView+ParentViewController.h"
#import "GMABannerWebViewEvent.h"

@interface UADSGADBannerWrapper()
@property (nonatomic, strong) id<UADSWebViewEventSender> eventSender;
@property (nonatomic, strong) GMAAdMetaData *meta;
@property (nonatomic, strong) UADSGMAScar *gmaScar;
@end

@implementation UADSGADBannerWrapper

+ (instancetype)newWithMeta: (GMAAdMetaData *)meta eventSender: (id<UADSWebViewEventSender>)eventSender gmaScar:(UADSGMAScar*)gmaScar {
    UADSGADBannerWrapper *wrapper = [UADSGADBannerWrapper new];
    wrapper.meta = meta;
    wrapper.eventSender = eventSender;
    wrapper.gmaScar = gmaScar;
    return wrapper;
}

- (void)addToBannerView: (UADSBannerView *)bannerView withSize: (CGSize)size {
    [bannerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [bannerView addSubview:self withSize:size];
   
    UIView *gBannerView = self.gadBannerView;
    [self addSubview:gBannerView withSize:size];
    
    [self updateGADBannerRootViewController];
}

- (void)updateGADBannerRootViewController {
    [self.gadBanner setRootViewController: self.bannerRootViewController];
}

- (UIViewController *)bannerRootViewController {
    return [self parentViewController] ?: [UIViewController uads_getTopController];
}

- (UIView *)gadBannerView {
    return (UIView *)self.gadBanner.proxyObject;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview == nil) {
        [self.gmaScar removeAdForPlacement: self.meta.placementID];
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    if (newWindow) {
        [self updateGADBannerRootViewController];
        [self sendAttachedEvent];
    } else {
        [self sendDettachedEvent];
    }
}

- (void)sendAttachedEvent {
    [self.eventSender sendEvent:[GMABannerWebViewEvent newBannerAttachedWithMeta: self.meta]];
}

- (void)sendDettachedEvent {
    [self.eventSender sendEvent:[GMABannerWebViewEvent newBannerDetachedWithMeta: self.meta]];
}

@end
