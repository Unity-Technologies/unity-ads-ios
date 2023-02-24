#import <Foundation/Foundation.h>

@protocol UADSConfigurationMetricTagsReader <NSObject>
- (NSDictionary *)metricTags;
- (NSDictionary *)metricContainerConfigurationInfo;
@end
