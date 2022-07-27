
#import <Foundation/Foundation.h>
#import "UADSConfigurationLoader.h"
#import "USRVSDKMetrics.h"
#import "UADSInitializeEventsMetricSender.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSConfigurationLoaderWithMetrics : NSObject<UADSConfigurationLoader>
+ (instancetype)decorateOriginal: (id<UADSConfigurationLoader>)original
                andMetricsSender: (id<ISDKMetrics>)metricsSender
                 retryInfoReader: (id<UADSRetryInfoReader>)retryInfoReader;
@end

NS_ASSUME_NONNULL_END
