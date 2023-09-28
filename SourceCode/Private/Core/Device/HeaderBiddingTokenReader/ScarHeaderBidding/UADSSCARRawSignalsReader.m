#import "UADSSCARRawSignalsReader.h"
#import "UADSSCARSignalIdentifiers.h"
#import "UADSSCARHeaderBiddingMetric.h"
#import "NSMutableDictionary+SafeOperations.h"
#import "UADSScarSignalParameters.h"

@implementation UADSSCARRawSignalsReader

- (void) requestSCARSignalsWithIsAsync:(BOOL)isAsync completion: (_Nullable UADSSuccessCompletion) completion {
    
    CFTimeInterval startTime = self.config.timestampReader.currentTimestamp;
    [self.config.metricsSender sendMetric: [UADSSCARHeaderBiddingMetric newScarFetchStartedWithIsAsync:isAsync]];
    
    id success = ^(UADSSCARSignals *_Nullable signals) {
        [self.config.metricsSender sendMetric: [UADSSCARHeaderBiddingMetric newScarFetchTimeSuccess:[self durationFromStartTime:startTime] isAsync:isAsync]];
        completion([self validateSignals: signals]);
    };

    id error = ^(id<UADSError> _Nonnull error) {
        NSMutableDictionary *tags = [NSMutableDictionary new];
        [tags uads_setValueIfNotNil:error.errorCode forKey:@"reason"];
        [self.config.metricsSender sendMetric: [UADSSCARHeaderBiddingMetric newScarFetchTimeFailure:[self durationFromStartTime:startTime] tags:tags isAsync:isAsync]];
        completion(nil);
    };
    
    UADSGMAScarSignalsCompletion *scarSignalsCompletion = [UADSGMAScarSignalsCompletion newWithSuccess: success
                                                                                              andError: error];
    [self.config.signalService getSCARSignals:self.signalsToCollect completion:scarSignalsCompletion];
}

- (NSNumber *)durationFromStartTime:(CFTimeInterval)startTime {
    return [self.config.timestampReader msDurationFrom: startTime];
}

- (BOOL)scarBannerSignalsEnabled {
    return [self.config.configurationReader.currentSessionExperiments isScarBannerSignalsEnabled];
}

- (NSArray<UADSScarSignalParameters *>*)signalsToCollect {
    NSMutableArray<UADSScarSignalParameters *> *params = [NSMutableArray arrayWithArray:@[
        [[UADSScarSignalParameters alloc] initWithPlacementId:UADSScarInterstitialSignal adFormat:GADQueryInfoAdTypeInterstitial],
        [[UADSScarSignalParameters alloc] initWithPlacementId:UADSScarRewardedSignal adFormat: GADQueryInfoAdTypeRewarded]
    ]];
    if ([self scarBannerSignalsEnabled]) {
        [params addObject:[[UADSScarSignalParameters alloc] initWithPlacementId:UADSScarBannerSignal adFormat:GADQueryInfoAdTypeBanner]];
    }
    return params;
}

- (UADSSCARSignals *)validateSignals:(UADSSCARSignals *)signals {
    if (![signals objectForKey:UADSScarRewardedSignal] &&
        ![signals objectForKey:UADSScarInterstitialSignal] &&
        (!self.scarBannerSignalsEnabled || ![signals objectForKey:UADSScarBannerSignal])) {
        return nil;
    }
    return signals;
}
@end
