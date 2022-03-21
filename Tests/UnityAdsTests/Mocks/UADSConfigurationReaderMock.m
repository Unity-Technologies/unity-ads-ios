#import "NSDictionary+JSONString.h"
#import "UADSConfigurationReaderMock.h"

@implementation UADSConfigurationReaderMock

+ (instancetype)newWithExperiments: (NSDictionary *)experiments {
    UADSConfigurationReaderMock *mock = [UADSConfigurationReaderMock new];

    mock.experiments = experiments;
    return mock;
}

- (nonnull USRVConfiguration *)getCurrentConfiguration {
    if (_expectedConfiguration) {
        return _expectedConfiguration;
    }

    NSMutableDictionary *configDictionary = [NSMutableDictionary dictionaryWithObject: @"fake-webview-url"
                                                                               forKey: @"url"];


    configDictionary[@"exp"] = self.experiments;

    return [[USRVConfiguration alloc] initWithConfigJsonData: configDictionary.jsonData];
}

- (NSDictionary *)metricTags {
    return self.experiments;
}

@end
