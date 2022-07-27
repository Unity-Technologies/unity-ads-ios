#import <Foundation/Foundation.h>
#import "USRVDataGzipCompressor.h"
#import "USRVSDKMetrics.h"
#import "UADSCurrentTimestampBase.h"

NS_ASSUME_NONNULL_BEGIN

@interface USRVDictionaryCompressorWithMetrics : NSObject<USRVDataCompressor>
+ (instancetype)decorateOriginal: (id<USRVDataCompressor>)original
                andMetricsSender: (id<ISDKMetrics>)metricsSender
                currentTimestamp: (id<UADSCurrentTimestamp>)timestampReader;

+ (instancetype)defaultDecorateOriginal: (id<USRVDataCompressor>)original
                       andMetricsSender: (id<ISDKMetrics>)metricsSender;
@end

NS_ASSUME_NONNULL_END
