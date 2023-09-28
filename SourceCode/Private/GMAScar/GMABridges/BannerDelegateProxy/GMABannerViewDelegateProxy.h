#import <Foundation/Foundation.h>
#import "GMAAdMetaData.h"
#import "UADSWebViewEventSender.h"

NS_ASSUME_NONNULL_BEGIN

@protocol UADSGADBannerViewDelegate <NSObject>
- (void)bannerViewDidReceiveAd:(nonnull id)bannerView;
- (void)bannerView:(nonnull id)bannerView didFailToReceiveAdWithError:(nonnull NSError *)error;
- (void)bannerViewDidRecordImpression:(nonnull id)bannerView;
- (void)bannerViewDidRecordClick:(nonnull id)bannerView;
- (void)bannerViewWillPresentScreen:(nonnull id)bannerView;
- (void)bannerViewWillDismissScreen:(nonnull id)bannerView;
- (void)bannerViewDidDismissScreen:(nonnull id)bannerView;
@end

@interface GMABannerViewDelegateProxy : NSObject <UADSGADBannerViewDelegate>
+ (instancetype)newWithMetaData: (GMAAdMetaData *)meta
                andErrorHandler: (id<UADSErrorHandler>)errorHandler
                      andSender: (id<UADSWebViewEventSender>)eventSender
                  andCompletion: (UADSAnyCompletion *)completion;

- (void)bannerViewDidReceiveAd:(nonnull id)bannerView;
- (void)bannerView:(nonnull id)bannerView didFailToReceiveAdWithError:(nonnull NSError *)error;
- (void)bannerViewDidRecordImpression:(nonnull id)bannerView;
- (void)bannerViewDidRecordClick:(nonnull id)bannerView;
- (void)bannerViewWillPresentScreen:(nonnull id)bannerView;
- (void)bannerViewWillDismissScreen:(nonnull id)bannerView;
- (void)bannerViewDidDismissScreen:(nonnull id)bannerView;
@end

NS_ASSUME_NONNULL_END
