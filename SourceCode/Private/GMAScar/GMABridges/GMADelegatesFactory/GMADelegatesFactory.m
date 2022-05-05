#import "GMADelegatesFactory.h"
#import "UADSGenericCompletion.h"
#import "UADSTimerWithAppLifeCycle.h"

@interface GMADelegatesBaseFactory ()
@property (nonatomic, strong) id<UADSWebViewEventSender> eventSender;
@property (nonatomic, strong) id<UADSErrorHandler> errorHandler;
@property (nonatomic, strong) id<UADSRepeatableTimer> timer;
@end

@implementation GMADelegatesBaseFactory

+ (instancetype)newWithEventSender: (id<UADSWebViewEventSender>)eventSender
                      errorHandler: (id<UADSErrorHandler>)errorHandler {
    return [GMADelegatesBaseFactory newWithEventSender: eventSender
                                          errorHandler: errorHandler
                                                 timer: [UADSTimerWithAppLifeCycle defaultTimer]];
}

+ (instancetype)newWithEventSender: (id<UADSWebViewEventSender>)eventSender
                      errorHandler: (id<UADSErrorHandler>)errorHandler
                             timer: (id<UADSRepeatableTimer>)timer {
    GMADelegatesBaseFactory *factory = [GMADelegatesBaseFactory new];

    factory.eventSender = eventSender;
    factory.errorHandler = errorHandler;
    factory.timer = timer;
    return factory;
}

- (nonnull GMAInterstitialAdDelegateProxy *)interstitialDelegate: (nonnull GMAAdMetaData *)meta
                                                   andCompletion: (nonnull UADSAnyCompletion *)completion {
    return [GMAInterstitialAdDelegateProxy newWithMetaData: meta
                                           andErrorHandler: _errorHandler
                                                 andSender: _eventSender
                                             andCompletion: completion
                                                  andTimer: _timer];
}

- (nonnull GMARewardedAdDelegateProxy *)rewardedDelegate: (nonnull GMAAdMetaData *)meta {
    return [GMARewardedAdDelegateProxy newWithMetaData: meta
                                       andErrorHandler: _errorHandler
                                             andSender: _eventSender
                                         andCompletion: [UADSAnyCompletion new]
                                              andTimer: _timer];
}

@end
