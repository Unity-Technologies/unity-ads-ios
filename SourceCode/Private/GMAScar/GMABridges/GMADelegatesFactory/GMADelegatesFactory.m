#import "GMADelegatesFactory.h"
#import "UADSGenericCompletion.h"

@interface GMADelegatesBaseFactory ()
@property (nonatomic, strong) id<UADSWebViewEventSender> eventSender;
@property (nonatomic, strong) id<UADSErrorHandler> errorHandler;
@end

@implementation GMADelegatesBaseFactory

+ (instancetype)newWithEventSender: (id<UADSWebViewEventSender>)eventSender
                      errorHandler: (id<UADSErrorHandler>)errorHandler {
    GMADelegatesBaseFactory *factory = [GMADelegatesBaseFactory new];

    factory.eventSender = eventSender;
    factory.errorHandler = errorHandler;
    return factory;
}

- (nonnull GMAInterstitialAdDelegateProxy *)interstitialDelegate: (nonnull GMAAdMetaData *)meta
                                                   andCompletion: (nonnull UADSAnyCompletion *)completion {
    return [GMAInterstitialAdDelegateProxy newWithMetaData: meta
                                           andErrorHandler: _errorHandler
                                                 andSender: _eventSender
                                             andCompletion: completion];
}

- (nonnull GMARewardedAdDelegateProxy *)rewardedDelegate: (nonnull GMAAdMetaData *)meta {
    return [GMARewardedAdDelegateProxy newWithMetaData: meta
                                       andErrorHandler: _errorHandler
                                             andSender: _eventSender
                                         andCompletion: [UADSAnyCompletion new]];
}

@end
