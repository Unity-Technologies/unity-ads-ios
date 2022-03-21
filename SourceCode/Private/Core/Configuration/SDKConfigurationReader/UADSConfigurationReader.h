#import <Foundation/Foundation.h>
#import "USRVConfiguration.h"
#import "UADSConfigurationMetricTagsReader.h"

NS_ASSUME_NONNULL_BEGIN

@protocol UADSConfigurationReader <NSObject>
- (USRVConfiguration *)getCurrentConfiguration;
@end

@interface UADSConfigurationReaderBase : NSObject <UADSConfigurationReader, UADSConfigurationMetricTagsReader>
@end

NS_ASSUME_NONNULL_END
