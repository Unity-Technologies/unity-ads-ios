#import "UADSSCARWebRequestSignalSender.h"
#import "UADSSCARSignalIdentifiers.h"
#import "NSMutableDictionary+SafeOperations.h"
#import "UADSSCARHeaderBiddingMetric.h"
#import "UADSErrorState.h"

@implementation UADSSCARWebRequestSignalSender {
    dispatch_queue_t queue;
}

- (instancetype)init {
    SUPER_INIT;
    queue = dispatch_queue_create("com.unity3d.scarwebrequestsignalsender.module", DISPATCH_QUEUE_SERIAL);
    return self;
}

- (void)sendSCARSignalsWithUUIDString:(NSString* _Nonnull)uuidString signals:(UADSSCARSignals * _Nonnull) signals isAsync:(BOOL)isAsync {
    if (![signals objectForKey:UADSScarRewardedSignal] && ![signals objectForKey:UADSScarInterstitialSignal]) {
        NSMutableDictionary *tags = [NSMutableDictionary dictionaryWithDictionary: @{
                                         @"reason": @"No SCAR Signals passed along"
        }];
        [self.config.metricsSender sendMetric: [UADSSCARHeaderBiddingMetric newScarSendTimeFailure:0 tags:tags isAsync:isAsync]];
        return;
    }
    
    if (!uuidString || [uuidString isEqualToString:@""]) {
        NSMutableDictionary *tags = [NSMutableDictionary dictionaryWithDictionary: @{
                                         @"reason": @"Invalid UUID string"
        }];
        [self.config.metricsSender sendMetric: [UADSSCARHeaderBiddingMetric newScarSendTimeFailure:0 tags:tags isAsync:isAsync]];
        return;
    }
    [self.config.metricsSender sendMetric: [UADSSCARHeaderBiddingMetric newScarSendStartedWithIsAsync:isAsync]];
    CFTimeInterval startTime = self.config.timestampReader.currentTimestamp;
    
    NSString* scarHbUrl = [self.config.configurationReader getCurrentScarHBURL];
    id<USRVWebRequest> request =  [self.config.requestFactory create:scarHbUrl
                                   requestType:@"POST"
                                   headers:@{@"Content-Type": @[@"application/json"]}
                                   connectTimeout:10];

    NSMutableDictionary* info = [NSMutableDictionary new];
    NSString *idfi = [self.config.idfiReader idfi];
    
    [info uads_setValueIfNotNil:uuidString forKey:UADSScarUUIDKey];
    [info uads_setValueIfNotNil:[signals objectForKey:UADSScarRewardedSignal] forKey:UADSScarRewardedKey];
    [info uads_setValueIfNotNil:[signals objectForKey:UADSScarInterstitialSignal] forKey:UADSScarInterstitialKey];
    [info uads_setValueIfNotNil:idfi forKey:UADSScarIdfiKey];

    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:info
      options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error) {
        NSMutableDictionary *tags = [NSMutableDictionary dictionaryWithDictionary: @{
                                         @"reason": uads_errorStateString(error.code)
        }];
        [self.config.metricsSender sendMetric: [UADSSCARHeaderBiddingMetric newScarSendTimeFailure:[self durationFromStartTime:startTime] tags:tags isAsync:isAsync]];
        return;
    }
    NSString *jsonString = [[NSString alloc] initWithData:jsonData
                                                encoding:NSUTF8StringEncoding];
    request.body = jsonString;

    dispatch_async(queue, ^{
        NSData* data = [request makeRequest];
        [self.config.metricsSender sendMetric: [UADSSCARHeaderBiddingMetric newScarSendTimeSuccess:[self durationFromStartTime:startTime] isAsync:isAsync]];
    });
}

- (NSNumber *)durationFromStartTime:(CFTimeInterval)startTime {
    return [self.config.timestampReader msDurationFrom: startTime];
}

@end
