#import <Foundation/Foundation.h>
#import "UADSConfigurationMetricTagsReader.h"

@interface ConfigurationMetricTagsReaderMock : NSObject <UADSConfigurationMetricTagsReader>
@property (nonatomic, strong) NSDictionary *expectedTags;
+ (instancetype)newWithExpectedTags: (NSDictionary *)expectedTags;
@end
