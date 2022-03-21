#import "UADSHeaderBiddingTokenReaderWithMetrics.h"
#import "UADSTsiMetric.h"

@interface UADSHeaderBiddingTokenReaderWithMetrics ()
@property (nonatomic, strong) id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD> original;
@property (nonatomic, strong) id<ISDKMetrics> metricsSender;
@property (nonatomic, strong) id<UADSConfigurationMetricTagsReader> tagsReader;
@property (nonatomic, strong) id<UADSInitializationStatusReader> statusReader;
@end

@implementation UADSHeaderBiddingTokenReaderWithMetrics

+ (instancetype)decorateOriginal: (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)original
                 andStatusReader: (id<UADSInitializationStatusReader>)statusReader
                   metricsSender: (id<ISDKMetrics>)metricsSender
                      tagsReader: (id<UADSConfigurationMetricTagsReader>)tagsReader {
    UADSHeaderBiddingTokenReaderWithMetrics *decorator = [UADSHeaderBiddingTokenReaderWithMetrics new];

    decorator.original = original;
    decorator.statusReader = statusReader;
    decorator.metricsSender = metricsSender;
    decorator.tagsReader = tagsReader;
    return decorator;
}

- (void)getToken: (nonnull UADSHeaderBiddingTokenCompletion)completion {
    __weak typeof(self) weakSelf = self;
    [self.original getToken:^(NSString *_Nullable token, UADSTokenType type) {
        [weakSelf sendMetricsWithToken: token
                                  type: type];
        completion(token, type);
    }];
}

- (void)sendMetricsWithToken: (NSString *)token type: (UADSTokenType)type {
    switch (type) {
        case kUADSTokenRemote:
            [self sendRemoteTokenMetricsIfNeeded: token];
            break;

        case kUADSTokenNative:
            [self sendNativeTokenMetricsIfNeeded: token];
            break;
    }
}

- (void)sendRemoteTokenMetricsIfNeeded: (NSString *)token {
    if (token == nil) {
        [self.metricsSender sendMetric: [UADSTsiMetric newAsyncTokenNullWithTags: self.metricTags]];
    }
}

- (void)sendNativeTokenMetricsIfNeeded: (NSString *)token {
    if (token == nil) {
        [self.metricsSender sendMetric: [UADSTsiMetric newNativeGeneratedTokenNullWithTags: self.metricTags]];
    } else {
        [self.metricsSender sendMetric: [UADSTsiMetric newNativeGeneratedTokenAvailableWithTags: self.metricTags]];
    }
}

- (NSDictionary *)metricTags {
    NSMutableDictionary *tags = [NSMutableDictionary dictionaryWithDictionary: [self.tagsReader metricTags]];

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
