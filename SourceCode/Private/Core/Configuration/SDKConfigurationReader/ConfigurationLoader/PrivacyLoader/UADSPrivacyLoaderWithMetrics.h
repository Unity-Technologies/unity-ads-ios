#import <Foundation/Foundation.h>
#import "UADSPrivacyLoader.h"
#import "USRVSDKMetrics.h"
#import "UADSInitializeEventsMetricSender.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSPrivacyLoaderWithMetrics : NSObject<UADSPrivacyLoader>

+ (instancetype)decorateOriginal: (id<UADSPrivacyLoader>)original
                andMetricsSender: (id<ISDKMetrics>)metricsSender
                 retryInfoReader: (id<UADSRetryInfoReader>)retryInfoReader;
@end

NS_ASSUME_NONNULL_END
