#import "UADSConfigurationCRUDBase.h"
#import "USRVSdkProperties.h"
#import "USRVWebViewApp.h"

@interface UADSConfigurationCRUDBase ()
@property (nonatomic, assign) BOOL localRead;
@property (nonatomic, strong) USRVConfiguration *localConfig;
@property (nonatomic, strong) USRVConfiguration *cachedConfig;
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

- (void)subscribeToConfigUpdates: (UADSConfigurationObserver)observer {
    dispatch_sync(self.syncQueue, ^{
        [self.mediator subscribe: observer];
    });
}

- (void)saveConfiguration: (USRVConfiguration *)configuration {
    dispatch_sync(self.syncQueue, ^{
        [configuration saveToDisk];
        self.cachedConfig = configuration;
    });

    [self.mediator notifyObserversWithObject: configuration];

    dispatch_sync(self.syncQueue, ^{
        [self.mediator removeAllObservers];
    });
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
