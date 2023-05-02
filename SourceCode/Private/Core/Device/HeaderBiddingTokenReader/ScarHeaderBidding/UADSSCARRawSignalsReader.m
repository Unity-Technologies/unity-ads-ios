#import "UADSSCARRawSignalsReader.h"
#import "UADSSCARSignalIdentifiers.h"
#import "UADSSCARHeaderBiddingMetric.h"
#import "NSMutableDictionary+SafeOperations.h"

@implementation UADSSCARRawSignalsReader

- (void) requestSCARSignalsWithIsAsync:(BOOL)isAsync completion: (_Nullable UADSSuccessCompletion) completion {
    
    CFTimeInterval startTime = self.config.timestampReader.currentTimestamp;
    [self.config.metricsSender sendMetric: [UADSSCARHeaderBiddingMetric newScarFetchStartedWithIsAsync:isAsync]];
    
    id success = ^(UADSSCARSignals *_Nullable signals) {
        [self.config.metricsSender sendMetric: [UADSSCARHeaderBiddingMetric newScarFetchTimeSuccess:[self durationFromStartTime:startTime] isAsync:isAsync]];
        completion(signals);
    
    };

    id error = ^(id<UADSError> _Nonnull error) {
        NSMutableDictionary *tags = [NSMutableDictionary new];
        [tags uads_setValueIfNotNil:error.errorCode forKey:@"reason"];
        [self.config.metricsSender sendMetric: [UADSSCARHeaderBiddingMetric newScarFetchTimeFailure:[self durationFromStartTime:startTime] tags:tags isAsync:isAsync]];
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
