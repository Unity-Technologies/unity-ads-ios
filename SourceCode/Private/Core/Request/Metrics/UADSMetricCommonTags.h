#import "UADSDictionaryConvertible.h"

@interface UADSMetricCommonTags : NSObject <UADSDictionaryConvertible>
- (instancetype)initWithCountryISO: (NSString *)countryISO platform: (NSString *)platform sdkVersion: (NSString *)sdkVersion systemVersion: (NSString *)systemVersion;
@end
