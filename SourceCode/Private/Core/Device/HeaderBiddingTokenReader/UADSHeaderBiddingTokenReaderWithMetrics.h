#import <Foundation/Foundation.h>
#import "UADSTokenStorage.h"
#import "UADSHeaderBiddingTokenReaderBase.h"
#import "USRVSDKMetrics.h"
#import "UADSConfigurationMetricTagsReader.h"
#import "UADSInitializationStatusReader.h"

NS_ASSUME_NONNULL_BEGIN

@interface UADSHeaderBiddingTokenReaderWithMetrics : NSObject<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>

+ (instancetype)decorateOriginal: (id<UADSHeaderBiddingAsyncTokenReader, UADSHeaderBiddingTokenCRUD>)original
                 andStatusReader: (id<UADSInitializationStatusReader>)statusReader
                   metricsSender: (id<ISDKMetrics>)metricsSender
                      tagsReader: (id<UADSConfigurationMetricTagsReader>)tagsReader;

@end

NS_ASSUME_NONNULL_END
