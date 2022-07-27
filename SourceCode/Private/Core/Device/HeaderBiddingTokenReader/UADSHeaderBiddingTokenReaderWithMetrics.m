#import "UADSHeaderBiddingTokenReaderWithMetrics.h"
#import "UADSTsiMetric.h"
#import "UADSHeaderBiddingToken.h"

@interface UADSHeaderBiddingTokenReaderWithMetrics ()
@property (nonatomic, strong) id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> original;
@property (nonatomic, strong) id<ISDKMetrics> metricsSender;
@property (nonatomic, strong) id<UADSInitializationStatusReader> statusReader;
@property (nonatomic, strong) id<UADSPrivacyResponseReader> privacyResponseReader;
@end

@implementation UADSHeaderBiddingTokenReaderWithMetrics

+ (instancetype)decorateOriginal: (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)original
                 andStatusReader: (id<UADSInitializationStatusReader>)statusReader
                   metricsSender: (id<ISDKMetrics>)metricsSender
           privacyResponseReader: (id<UADSPrivacyResponseReader>)privacyResponseReader {
    UADSHeaderBiddingTokenReaderWithMetrics *decorator = [UADSHeaderBiddingTokenReaderWithMetrics new];

    decorator.original = original;
    decorator.statusReader = statusReader;
    decorator.metricsSender = metricsSender;
    decorator.privacyResponseReader = privacyResponseReader;
    return decorator;
}

- (void)getToken: (nonnull UADSHeaderBiddingTokenCompletion)completion {
    __weak typeof(self) weakSelf = self;
    [self.original getToken:^(UADSHeaderBiddingToken *_Nullable token) {
        [weakSelf sendMetricsWithToken: token];
        completion(token);
    }];
}

- (void)sendMetricsWithToken: (UADSHeaderBiddingToken *)token {
    switch (token.type) {
        case kUADSTokenRemote:
            [self sendRemoteTokenMetricsIfNeeded: token];
            break;

        case kUADSTokenNative:
            [self sendNativeTokenMetricsIfNeeded: token];
            break;
    }
}

- (void)sendRemoteTokenMetricsIfNeeded: (UADSHeaderBiddingToken *)token  {
    
    if (!token.isValid) {
        [self.metricsSender sendMetric: [UADSTsiMetric newAsyncTokenNullWithTags: [self metricTags]]];
    } else {
        [self.metricsSender sendMetric: [UADSTsiMetric newAsyncTokenTokenAvailableWithTags: self.metricTags]];
    }
}

- (void)sendNativeTokenMetricsIfNeeded: (UADSHeaderBiddingToken *)token {
    if (!token.isValid) {
        [self.metricsSender sendMetric: [UADSTsiMetric newNativeGeneratedTokenNullWithTags: [self metricTags]]];
    } else {
        [self.metricsSender sendMetric: [UADSTsiMetric newNativeGeneratedTokenAvailableWithTags: [self metricTags]]];
    }
}

- (NSDictionary *)metricTags {
    NSMutableDictionary *tags = [NSMutableDictionary dictionary];

    tags[@"state"] = UADSStringFromInitializationState(self.statusReader.currentState);
    return tags;
}

- (void)appendTokens: (nonnull NSArray<NSString *> *)tokens {
    [self.original appendTokens: tokens];
}

- (void)createTokens: (nonnull NSArray<NSString *> *)tokens {
    [self.original createTokens: tokens];
}

- (void)deleteTokens {
    [self.original deleteTokens];
}

- (nonnull NSString *)getToken {
    return [self.original getToken];
}

- (void)setInitToken: (nullable NSString *)token {
    [self.original setInitToken: token];
}

- (void)setPeekMode: (BOOL)mode {
    [self.original setPeekMode: mode];
}

@end
