#import "UADSConfigurationReader.h"
#import "USRVSdkProperties.h"
#import "USRVWebViewApp.h"

@interface UADSConfigurationReaderBase ()
@property (nonatomic, assign) BOOL localRead;
@property (nonatomic, strong) USRVConfiguration *localConfig;
@end

@implementation UADSConfigurationReaderBase

- (USRVConfiguration *)localConfiguration {
    if (self.localRead) {
        return self.localConfig;
    }

    self.localRead = YES;

    if ([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalConfigFilepath]]) {
        NSData *configData = [NSData dataWithContentsOfFile: [USRVSdkProperties getLocalConfigFilepath]
                                                    options: NSDataReadingUncached
                                                      error: nil];
        self.localConfig = [[USRVConfiguration alloc] initWithConfigJsonData: configData];
        return self.localConfig;
    }

    return nil;
}

- (USRVConfiguration *)remoteConfiguration {
    return [[USRVWebViewApp getCurrentApp] configuration];
}

#pragma mark UADSConfigurationReader
- (USRVConfiguration *)getCurrentConfiguration {
    if (self.remoteConfiguration) {
        return self.remoteConfiguration;
    }

    return [self localConfiguration];
}

#pragma mark UADSConfigurationMetricTagsReader
- (NSDictionary *)metricTags {
    USRVConfiguration *currentConfig = [self getCurrentConfiguration];

    if (currentConfig == nil) {
        return nil;
    }

    NSMutableDictionary *tags = [NSMutableDictionary dictionaryWithDictionary: currentConfig.experiments.json];
    NSString *source = currentConfig.source;

    if (source != nil) {
        tags[kUnityServicesConfigValueSource] = source;
    }

    return tags;
}

@end
