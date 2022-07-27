#import "UADSDictionaryConvertible.h"
#import "UADSConfigurationMetricTagsReader.h"

@interface UADSMetricCommonTags : NSObject <UADSDictionaryConvertible>
- (instancetype)initWithCountryISO: (NSString *)countryISO platform: (NSString *)platform sdkVersion: (NSString *)sdkVersion systemVersion: (NSString *)systemVersion testMode: (BOOL)testMode metricTags: (NSDictionary *)metricTags;
@end
