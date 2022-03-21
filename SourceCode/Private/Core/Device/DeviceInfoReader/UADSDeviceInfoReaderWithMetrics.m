#import "UADSDeviceInfoReaderWithMetrics.h"
#import "UADSTsiMetric.h"
#import "UADSJsonStorageKeyNames.h"
#import "UADSCurrentTimestampBase.h"

@interface UADSDeviceInfoReaderWithMetrics ()
@property (nonatomic, strong) id<UADSDeviceInfoReader> original;
@property (nonatomic, strong) id<ISDKMetrics> metricsSender;
@property (nonatomic, strong) id<UADSConfigurationMetricTagsReader> tagsReader;
@property (nonatomic, strong) id<UADSCurrentTimestamp>timestampReader;
@end

@implementation UADSDeviceInfoReaderWithMetrics

+ (instancetype)defaultDecorationOfOriginal: (id<UADSDeviceInfoReader>)original metricsSender: (id<ISDKMetrics>)metricsSender tagsReader: (id<UADSConfigurationMetricTagsReader>)tagsReader {
    return [UADSDeviceInfoReaderWithMetrics decorateOriginal: original
                                            andMetricsSender: metricsSender
                                                  tagsReader: tagsReader
                                            currentTimestamp: [UADSCurrentTimestampBase new]];
}

+ (instancetype)decorateOriginal: (id<UADSDeviceInfoReader>)original andMetricsSender: (id<ISDKMetrics>)metricsSender tagsReader: (id<UADSConfigurationMetricTagsReader>)tagsReader currentTimestamp: (id<UADSCurrentTimestamp>)timestampReader {
    UADSDeviceInfoReaderWithMetrics *decorator = [UADSDeviceInfoReaderWithMetrics new];

    decorator.metricsSender = metricsSender;
    decorator.original = original;
    decorator.tagsReader = tagsReader;
    decorator.timestampReader = timestampReader;

    return decorator;
}

- (nonnull NSDictionary *)getDeviceInfoForGameMode: (UADSGameMode)mode {
    NSTimeInterval startTime = self.timestampReader.currentTimestamp;
    NSDictionary *deviceInfo = [self.original getDeviceInfoForGameMode: mode];
    NSNumber *duration = [self.timestampReader msDurationFrom: startTime];

    [self.metricsSender sendMetric: [UADSTsiMetric newDeviceInfoCollectionLatency: duration
                                                                         withTags: self.tagsReader.metricTags]];

    if (!deviceInfo[UADSJsonStorageKeyNames.webViewDataGameSessionIdKey]) {
        [self.metricsSender sendMetric: [UADSTsiMetric newMissingGameSessionIdWithTags: self.tagsReader.metricTags]];
    }

    return deviceInfo;
}

@end
