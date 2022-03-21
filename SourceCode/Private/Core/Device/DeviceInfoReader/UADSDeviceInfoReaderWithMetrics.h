#import <Foundation/Foundation.h>
#import "UADSDeviceInfoReader.h"
#import "USRVSDKMetrics.h"
#import "UADSConfigurationMetricTagsReader.h"
#import "UADSCurrentTimestampBase.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSDeviceInfoReaderWithMetrics : NSObject<UADSDeviceInfoReader>
+ (instancetype)decorateOriginal: (id<UADSDeviceInfoReader>)original
                andMetricsSender: (id<ISDKMetrics>)metricsSender
                      tagsReader: (id<UADSConfigurationMetricTagsReader>)tagsReader
                currentTimestamp: (id<UADSCurrentTimestamp>)timestampReader;

+ (instancetype)defaultDecorationOfOriginal: (id<UADSDeviceInfoReader>)original metricsSender: (id<ISDKMetrics>)metricsSender tagsReader: (id<UADSConfigurationMetricTagsReader>)tagsReader;
@end

NS_ASSUME_NONNULL_END
