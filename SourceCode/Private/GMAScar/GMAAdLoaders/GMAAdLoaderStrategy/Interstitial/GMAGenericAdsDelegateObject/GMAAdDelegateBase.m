#import "GMAAdDelegateBase.h"
#import "NSError+UADSError.h"
#import "GMAWebViewEvent.h"
#import "GMAError.h"
#import "UADSArrayScheduledStream.h"

@interface GMAAdDelegateBase ()
@property (nonatomic, strong) UADSAnyCompletion *completion;
@property (strong, nonatomic) UADSArrayScheduledStream *quartileEventsStream;
@property (nonatomic, strong) NSArray *quartileEvents;
@property (nonatomic, assign) BOOL hasScheduledQuartileEvents;
@property (nonatomic, strong) id<UADSRepeatableTimer> timer;
@end

@implementation GMAAdDelegateBase
+ (instancetype)newWithMetaData: (GMAAdMetaData *)meta
                andErrorHandler: (id<UADSErrorHandler>)errorHandler
                      andSender: (id<UADSWebViewEventSender>)eventSender
                  andCompletion: (UADSAnyCompletion *)completion
                       andTimer: (id<UADSRepeatableTimer>)timer {
    GMAAdDelegateBase *base = [[self alloc] init];

    base.eventSender = eventSender;
    base.meta = meta;
    base.completion = completion;
    base.hasSentQuartiles = false;
    base.errorHandler = errorHandler;
    base.quartileEvents = @[
        [GMAWebViewEvent newFirstQuartileWithMeta: meta],
        [GMAWebViewEvent newMidPointWithMeta: meta],
        [GMAWebViewEvent newThirdQuartileWithMeta: meta],
        [GMAWebViewEvent newLastQuartileWithMeta: meta]
    ];
    base.timer = timer;
    return base;
}

- (void)didReceiveAd: (id)ad {
    [self.completion success: ad];
}

- (void)loadingOfAd: (id)ad
    failedWithError: (NSError *)error {
    GMAError *gmaError = [GMAError newLoadErrorUsingMetaData: _meta
                                                    andError: error];

    [self.completion error: gmaError];
}

- (void)willPresentAd: (id)ad {
    [self scheduleQuartileEvents: [_meta videoLengthInSeconds]];

    [_eventSender sendEvent: [GMAWebViewEvent newAdStartedWithMeta: _meta]];
}

- (void)willDismissAd: (id)ad {
}

- (void)didDismissAd: (id)ad {
    [_quartileEventsStream invalidate];
    _quartileEventsStream = nil;
    [_eventSender sendEvent: [GMAWebViewEvent newAdClosedWithMeta: _meta]];
}

- (void)willLeaveApplication: (id)ad {
    [_eventSender sendEvent: [GMAWebViewEvent newAdClickedWithMeta: _meta]];
}

- (void)ad: (nonnull id)ad didFailToPresentFullScreenContentWithError: (nonnull NSError *)error {
    [_errorHandler catchError: [GMAError newShowErrorWithMeta: _meta
                                                    withError: error]];
}

- (void)adDidDismissFullScreenContent: (nonnull id)ad {
    [self didDismissAd: ad];
}

- (void)adDidPresentFullScreenContent: (nonnull id)ad {
    [self willPresentAd: ad];
}

- (void)adWillPresentFullScreenContent: (nonnull id)ad {
    [self willPresentAd: ad];
}

- (void)adDidRecordImpression: (nonnull id)ad {
    [_eventSender sendEvent: [GMAWebViewEvent newImpressionRecordedWithMeta: _meta]];
}

- (void)scheduleQuartileEvents: (NSTimeInterval)totalTime {
    if (self.hasScheduledQuartileEvents) {
        return;
    }

    self.hasScheduledQuartileEvents = true;
    __weak typeof(self) weakSelf = self;

    self.quartileEventsStream = [UADSArrayScheduledStream scheduledStreamWithArray: self.quartileEvents
                                                                         totalTime: totalTime
                                                                             timer: self.timer
                                                                             block:^(id _Nonnull event, NSInteger index) {
                                                                                 [weakSelf.eventSender sendEvent: event];

                                                                                 if (index == self.quartileEvents.count - 1) {
                                                                                     weakSelf.hasSentQuartiles = true;
                                                                                 }
                                                                             }];
}

@end
