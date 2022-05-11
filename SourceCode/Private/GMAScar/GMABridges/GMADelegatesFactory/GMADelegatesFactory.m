#import "GMADelegatesFactory.h"
#import "UADSGenericCompletion.h"
#import "UADSTimerWithAppLifeCycle.h"

@interface GMADelegatesBaseFactory ()
@property (nonatomic, strong) id<UADSWebViewEventSender> eventSender;
@property (nonatomic, strong) id<UADSErrorHandler> errorHandler;
@property (nonatomic, strong) id<UADSTimerFactory> timerFactory;
@end

@implementation GMADelegatesBaseFactory

+ (instancetype)newWithEventSender: (id<UADSWebViewEventSender>)eventSender
                      errorHandler: (id<UADSErrorHandler>)errorHandler {
    return [GMADelegatesBaseFactory newWithEventSender: eventSender
                                          errorHandler: errorHandler
                                          timerFactory: [UADSTimerFactoryBase new]];
}

+ (instancetype)newWithEventSender: (id<UADSWebViewEventSender>)eventSender
                      errorHandler: (id<UADSErrorHandler>)errorHandler
                      timerFactory: (id<UADSTimerFactory>)timerFactory {
    GMADelegatesBaseFactory *factory = [GMADelegatesBaseFactory new];

    factory.eventSender = eventSender;
    factory.errorHandler = errorHandler;
    factory.timerFactory = timerFactory;
    return factory;
}

- (nonnull GMAInterstitialAdDelegateProxy *)interstitialDelegate: (nonnull GMAAdMetaData *)meta
                                                   andCompletion: (nonnull UADSAnyCompletion *)completion {
    return [GMAInterstitialAdDelegateProxy newWithMetaData: meta
                                           andErrorHandler: _errorHandler
                                                 andSender: _eventSender
                                             andCompletion: completion
                                                  andTimer: [_timerFactory timerWithAppLifeCycle]];
}

- (nonnull GMARewardedAdDelegateProxy *)rewardedDelegate: (nonnull GMAAdMetaData *)meta {
    return [GMARewardedAdDelegateProxy newWithMetaData: meta
                                       andErrorHandler: _errorHandler
                                             andSender: _eventSender
                                         andCompletion: [UADSAnyCompletion new]
                                              andTimer: [_timerFactory timerWithAppLifeCycle]];
}

@end
