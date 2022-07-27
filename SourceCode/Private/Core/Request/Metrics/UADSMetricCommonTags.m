#import "UADSMetricCommonTags.h"

@interface UADSMetricCommonTags ()
@property (nonatomic, strong) NSString *countryISO;
@property (nonatomic, strong) NSString *platform;
@property (nonatomic, strong) NSString *sdkVersion;
@property (nonatomic, strong) NSString *systemVersion;
@property (nonatomic, assign) BOOL testMode;
@property (nonatomic, strong) NSDictionary *metricTags;
@end

@implementation UADSMetricCommonTags

- (instancetype)initWithCountryISO: (NSString *)countryISO platform: (NSString *)platform sdkVersion: (NSString *)sdkVersion systemVersion: (NSString *)systemVersion testMode: (BOOL)testMode metricTags: (NSDictionary *)metricTags {
    SUPER_INIT;
    _countryISO = countryISO;
    _platform = platform;
    _sdkVersion = sdkVersion;
    _systemVersion = systemVersion;
    _testMode = testMode;
    _metricTags = metricTags;
    return self;
}

- (NSDictionary *)dictionary {
    NSMutableDictionary *tags = [NSMutableDictionary dictionaryWithDictionary: self.metricTags];

    [tags addEntriesFromDictionary: @{
         @"iso": self.countryISO,
         @"plt": self.platform,
         @"sdk": self.sdkVersion,
         @"system": self.systemVersion,
         @"tm": [@(self.testMode) stringValue]
    }];
    return tags;
}

@end
