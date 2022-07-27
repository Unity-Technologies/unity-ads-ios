#import "UADSConfigurationCRUDBase.h"
#import "USRVSdkProperties.h"
#import "USRVWebViewApp.h"

@interface UADSConfigurationCRUDBase ()
@property (nonatomic, assign) BOOL localRead;
@property (nonatomic, strong) USRVConfiguration *localConfig;
@property (nonatomic, strong) USRVConfiguration *remoteConfig;
@property (nonatomic, strong) dispatch_queue_t syncQueue;
@property (nonatomic, strong) UADSGenericMediator<USRVConfiguration *> *mediator;
@end

@implementation UADSConfigurationCRUDBase

- (instancetype)init {
    SUPER_INIT;
    self.syncQueue = dispatch_queue_create("com.dispatch.UADSConfigurationReaderBase", DISPATCH_QUEUE_SERIAL);
    self.mediator = [UADSGenericMediator new];
    return self;
}

- (USRVConfiguration *)localConfiguration {
    dispatch_sync(self.syncQueue, ^{
        if (!self.localRead) {
            self.localConfig = [self getConfigFromFile];
            self.localRead = YES;
        }
    });

    return self.localConfig;
}

#pragma mark UADSConfigurationReader
- (USRVConfiguration *)getCurrentConfiguration {
    if ([self.remoteConfig hasValidWebViewURL]) {
        return self.remoteConfig;
    }

    return [self localConfiguration];
}

- (UADSConfigurationExperiments *)currentSessionExperiments {
    USRVConfiguration *config = [ self getCurrentConfiguration];

    if (config == nil) {
        return nil;
    }

    NSDictionary *currentFlags = [config.experiments currentSessionFlags] ? : @{};
    NSMutableDictionary *experiments = [NSMutableDictionary dictionaryWithDictionary:  currentFlags];

    NSDictionary *appliedFlags = [self.localConfiguration.experiments nextSessionFlags] ? : @{};

    [experiments setValuesForKeysWithDictionary: appliedFlags];

    return [UADSConfigurationExperiments newWithJSON: experiments];
}

#pragma mark UADSConfigurationMetricTagsReader
- (NSDictionary *)metricTags {
    USRVConfiguration *currentConfig = [self getCurrentConfiguration];

    if (currentConfig == nil) {
        return nil;
    }

    NSMutableDictionary *tags = [NSMutableDictionary dictionaryWithDictionary: self.currentSessionExperiments.json];

    tags[kUnityServicesConfigValueSource] = currentConfig.source;

    return tags;
}

- (NSDictionary *)metricInfo {
    USRVConfiguration *currentConfig = [self getCurrentConfiguration];

    if (currentConfig == nil) {
        return nil;
    }

    return @{
        kUnityServicesConfigValueMetricSamplingRate: [@(currentConfig.metricSamplingRate) stringValue]
    };
}

- (void)subscribeToConfigUpdates: (UADSConfigurationObserver)observer {
    [self.mediator subscribe: observer];
}

- (void)saveConfiguration: (USRVConfiguration *)configuration {
    dispatch_sync(self.syncQueue, ^{
        [configuration saveToDisk];
        self.remoteConfig = configuration;
    });

    [self.mediator notifyObserversWithObjectAndRemove: configuration];
}

- (USRVConfiguration *)getConfigFromFile {
    if ([[NSFileManager defaultManager] fileExistsAtPath: [USRVSdkProperties getLocalConfigFilepath]]) {
        NSData *configData = [NSData dataWithContentsOfFile: [USRVSdkProperties getLocalConfigFilepath]
                                                    options: NSDataReadingUncached
                                                      error: nil];
        return [[USRVConfiguration alloc] initWithConfigJsonData: configData];
    }

    return nil;
}

@end
