#import "GMABannerViewDelegateProxy.h"
#import "GMAError.h"
#import "GMABannerWebViewEvent.h"

@interface GMABannerViewDelegateProxy ()
@property (nonatomic, strong) GMAAdMetaData *meta;
@property (nonatomic, strong) id<UADSWebViewEventSender>eventSender;
@property (nonatomic, strong) id<UADSErrorHandler>errorHandler;
@property (nonatomic, strong) UADSAnyCompletion *completion;
@end

@implementation GMABannerViewDelegateProxy

+ (instancetype)newWithMetaData: (GMAAdMetaData *)meta
                andErrorHandler: (id<UADSErrorHandler>)errorHandler
                      andSender: (id<UADSWebViewEventSender>)eventSender
                  andCompletion: (UADSAnyCompletion *)completion {
    GMABannerViewDelegateProxy *base = [[self alloc] init];
    
    base.eventSender = eventSender;
    base.meta = meta;
    base.completion = completion;
    base.errorHandler = errorHandler;
    
    return base;
}

- (void)bannerViewDidReceiveAd:(nonnull id)bannerView {
    [self.completion success: bannerView];
}

- (void)bannerView:(nonnull id)bannerView didFailToReceiveAdWithError:(nonnull NSError *)error {
    GMAError *gmaError = [GMAError newLoadErrorUsingMetaData: _meta
                                                    andError: error];

    [self.completion error: gmaError];
}

- (void)bannerViewDidRecordImpression:(nonnull id)bannerView {
    [self.eventSender sendEvent: [GMABannerWebViewEvent newBannerImpressionWithMeta:self.meta]];
}

- (void)bannerViewDidRecordClick:(nonnull id)bannerView {
    [self.eventSender sendEvent: [GMABannerWebViewEvent newBannerClickedWithMeta:self.meta]];
}

- (void)bannerViewWillPresentScreen:(nonnull id)bannerView {
    [self.eventSender sendEvent: [GMABannerWebViewEvent newBannerOpenedWithMeta:self.meta]];
}

- (void)bannerViewWillDismissScreen:(nonnull id)bannerView {
}

- (void)bannerViewDidDismissScreen:(nonnull id)bannerView {
    [self.eventSender sendEvent: [GMABannerWebViewEvent newBannerClosedWithMeta:self.meta]];
}

@end
