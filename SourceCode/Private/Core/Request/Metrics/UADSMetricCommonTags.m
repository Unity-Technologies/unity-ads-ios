#import "UADSMetricCommonTags.h"

@interface UADSMetricCommonTags ()
@property (nonatomic, strong) NSString *countryISO;
@property (nonatomic, strong) NSString *platform;
@property (nonatomic, strong) NSString *sdkVersion;
@property (nonatomic, strong) NSString *systemVersion;
@end

@implementation UADSMetricCommonTags

- (instancetype)initWithCountryISO: (NSString *)countryISO platform: (NSString *)platform sdkVersion: (NSString *)sdkVersion systemVersion: (NSString *)systemVersion {
    SUPER_INIT;
    _countryISO = countryISO;
    _platform = platform;
    _sdkVersion = sdkVersion;
    _systemVersion = systemVersion;
    return self;
}

- (NSDictionary *)dictionary {
    return @{
        @"iso": self.countryISO,
        @"plt": self.platform,
        @"sdk": self.sdkVersion,
        @"system": self.systemVersion
    };
}

@end
