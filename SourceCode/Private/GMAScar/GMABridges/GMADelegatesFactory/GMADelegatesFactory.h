#import <Foundation/Foundation.h>
#import "GMAInterstitialAdDelegateProxy.h"
#import "GMARewardedAdDelegateProxy.h"
NS_ASSUME_NONNULL_BEGIN

@protocol GMADelegatesFactory <NSObject>
- (GMAInterstitialAdDelegateProxy *)interstitialDelegate: (GMAAdMetaData *)meta
                                           andCompletion: (UADSAnyCompletion *)completion;
- (GMARewardedAdDelegateProxy *)rewardedDelegate: (GMAAdMetaData *)meta;

@end

@interface GMADelegatesBaseFactory : NSObject<GMADelegatesFactory>

+ (instancetype)newWithEventSender: (id<UADSWebViewEventSender>)eventSender
                      errorHandler: (id<UADSErrorHandler>)errorHandler;

+ (instancetype)newWithEventSender: (id<UADSWebViewEventSender>)eventSender
                      errorHandler: (id<UADSErrorHandler>)errorHandler
                             timer: (id<UADSRepeatableTimer>)timer;

@end

NS_ASSUME_NONNULL_END
