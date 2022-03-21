#import <Foundation/Foundation.h>
#import "UADSConfigurationLoader.h"
NS_ASSUME_NONNULL_BEGIN

@interface UADSConfigurationLoaderStrategy : NSObject<UADSConfigurationLoader>

+ (id<UADSConfigurationLoader>)newWithMainLoader: (id<UADSConfigurationLoader>)mainLoader
                               andFallbackLoader: (id<UADSConfigurationLoader>)fallbackLoader
                                    metricSender: (id<ISDKMetrics>)metricSender
                                metricTagsReader: (id<UADSConfigurationMetricTagsReader>)tagsReader;
@end

NS_ASSUME_NONNULL_END
