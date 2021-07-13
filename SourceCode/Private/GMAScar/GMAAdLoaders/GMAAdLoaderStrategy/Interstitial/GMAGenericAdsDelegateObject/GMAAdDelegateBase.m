#import "GMAAdDelegateBase.h"
#import "NSError+UADSError.h"
#import "GMAWebViewEvent.h"
#import "GMAError.h"

@interface GMAAdDelegateBase ()
@property (nonatomic, strong) UADSAnyCompletion *completion;
@property (strong, nonatomic) NSTimer *timer;
@property bool hasSentQuartiles;
@end

@implementation GMAAdDelegateBase
+ (instancetype)newWithMetaData: (GMAAdMetaData *)meta
                andErrorHandler: (id<UADSErrorHandler>)errorHandler
                      andSender: (id<UADSWebViewEventSender>)eventSender
                  andCompletion: (UADSAnyCompletion *)completion; {
    GMAAdDelegateBase *base = [[self alloc] init];

    base.eventSender = eventSender;
    base.meta = meta;
    base.completion = completion;
    base.hasSentQuartiles = false;
    base.errorHandler = errorHandler;
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
    double inSeconds = ([_meta.videoLength intValue] % 1000 == 0) ? [_meta.videoLength doubleValue] / 1000 : [_meta.videoLength doubleValue];

    self.timer = [NSTimer scheduledTimerWithTimeInterval: inSeconds
                                                  target: self
                                                selector: @selector(timesUp:)
                                                userInfo: nil
                                                 repeats: NO];

    [_eventSender sendEvent: [GMAWebViewEvent newAdStartedWithMeta: _meta]];

    if (!self.hasSentQuartiles) {
        [_eventSender sendEvent: [GMAWebViewEvent newFirstQuartileWithMeta: _meta]];
        [_eventSender sendEvent: [GMAWebViewEvent newMidPointWithMeta: _meta]];
        self.hasSentQuartiles = true;
    }
}

- (void)timesUp: (NSTimer *)timer {
    USRVLogDebug(@"User finished watching ad.");
    [_timer invalidate];
    _timer = nil;
}

- (void)willDismissAd: (id)ad {
}

- (void)didDismissAd: (id)ad {
    if (_timer) {
        [_eventSender sendEvent: [GMAWebViewEvent newAdSkippedWithMeta: _meta]];
    }

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

- (void)adDidRecordImpression: (nonnull id)ad {
    [_eventSender sendEvent: [GMAWebViewEvent newImpressionRecordedWithMeta: _meta]];
}

@end
