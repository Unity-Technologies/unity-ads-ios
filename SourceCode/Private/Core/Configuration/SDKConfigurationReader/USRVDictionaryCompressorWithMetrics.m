#import "USRVDictionaryCompressorWithMetrics.h"
#import "UADSTsiMetric.h"
#import "UADSCurrentTimestampBase.h"

@interface USRVDictionaryCompressorWithMetrics ()
@property (nonatomic, strong) id<USRVDataCompressor> original;
@property (nonatomic, strong) id<ISDKMetrics> metricsSender;
@property (nonatomic, strong) id<UADSCurrentTimestamp>timestampReader;
@end

@implementation USRVDictionaryCompressorWithMetrics

+ (instancetype)decorateOriginal: (id<USRVDataCompressor>)original
                andMetricsSender: (id<ISDKMetrics>)metricsSender
                currentTimestamp: (id<UADSCurrentTimestamp>)timestampReader {
    USRVDictionaryCompressorWithMetrics *decorator = [USRVDictionaryCompressorWithMetrics new];

    decorator.original = original;
    decorator.metricsSender = metricsSender;
    decorator.timestampReader = timestampReader;
    return decorator;
}

+ (instancetype)defaultDecorateOriginal: (id<USRVDataCompressor>)original
                       andMetricsSender: (id<ISDKMetrics>)metricsSender {
    return [USRVDictionaryCompressorWithMetrics decorateOriginal: original
                                                andMetricsSender: metricsSender
                                                currentTimestamp: [UADSCurrentTimestampBase new]];
}

- (NSData *)compressedIntoData: (NSDictionary *)dictionary {
    NSTimeInterval start = self.timestampReader.currentTimestamp;
    NSData *compressed = [self.original compressedIntoData: dictionary];
    NSNumber *duration = [self.timestampReader msDurationFrom: start];

    [self.metricsSender sendMetric: [UADSTsiMetric newDeviceInfoCompressionLatency: duration]];
    return compressed;
}

@end
