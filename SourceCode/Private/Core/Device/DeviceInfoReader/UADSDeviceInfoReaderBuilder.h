#import <Foundation/Foundation.h>
#import "UADSDeviceInfoReader.h"
#import "UADSPIIDataSelector.h"
#import "UADSConfigurationMetricTagsReader.h"
#import "USRVSDKMetrics.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSDeviceInfoReaderBuilder : NSObject

- (id<UADSDeviceInfoReader>)defaultReaderWithConfig: (id<UADSPIIDataSelectorConfig>)config
                                      metricsSender: (id<ISDKMetrics>)metricsSender
                                   metricTagsReader: (id<UADSConfigurationMetricTagsReader>)tagsReader;

@end

NS_ASSUME_NONNULL_END
