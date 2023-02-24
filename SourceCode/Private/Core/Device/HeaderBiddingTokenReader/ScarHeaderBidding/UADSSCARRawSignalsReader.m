#import "UADSSCARRawSignalsReader.h"
#import "UADSSCARSignalIdentifiers.h"
#import "UADSSCARHeaderBiddingMetric.h"

@implementation UADSSCARRawSignalsReader

- (void) requestSCARSignalsWithCompletion: (_Nullable UADSSuccessCompletion) completion {
    
    CFTimeInterval startTime = self.config.timestampReader.currentTimestamp;
    [self.config.metricsSender sendMetric: [UADSSCARHeaderBiddingMetric newScarFetchStarted]];
    
    id success = ^(UADSSCARSignals *_Nullable signals) {
        [self.config.metricsSender sendMetric: [UADSSCARHeaderBiddingMetric newScarFetchTimeSuccess:[self durationFromStartTime:startTime]]];
        completion(signals);
    
    };

    id error = ^(id<UADSError> _Nonnull error) {
        NSMutableDictionary *tags = [NSMutableDictionary dictionaryWithDictionary: @{
                                         @"reason": error.errorCode
        }];
        [self.config.metricsSender sendMetric: [UADSSCARHeaderBiddingMetric newScarFetchTimeFailure:[self durationFromStartTime:startTime] tags:tags]];
        completion(nil);
    };
    
    UADSGMAScarSignalsCompletion *scarSignalsCompletion = [UADSGMAScarSignalsCompletion newWithSuccess: success
                                                                                              andError: error];
    [self.config.signalService getSCARSignalsUsingInterstitialList:@[UADSScarInterstitialSignal] andRewardedList:@[UADSScarRewardedSignal] completion:scarSignalsCompletion];
}

- (NSNumber *)durationFromStartTime:(CFTimeInterval)startTime {
    return [self.config.timestampReader msDurationFrom: startTime];
}


@end
