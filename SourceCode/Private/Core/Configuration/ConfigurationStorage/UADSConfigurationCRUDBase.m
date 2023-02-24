#import "UADSConfigurationCRUDBase.h"
#import "USRVSdkProperties.h"
#import "USRVWebViewApp.h"
#import "UADSServiceProviderProxy.h"
#import "NSMutableDictionary+SafeOperations.h"

NSString *const kMetricsContainerSessionTokenKey = @"sTkn";

@interface UADSConfigurationCRUDBase ()
@property (nonatomic, assign) BOOL localRead;
@property (nonatomic, strong) USRVConfiguration *localConfig;
@property (nonatomic, strong) USRVConfiguration *remoteConfig;
@property (nonatomic, strong) dispatch_queue_t syncQueue;
@property (nonatomic, strong) UADSGenericMediator<USRVConfiguration *> *mediator;
@end

@implementation UADSConfigurationCRUDBase
@synthesize remoteConfig = _remoteConfig;
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
            self.localRead = true;
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

- (USRVConfiguration *)remoteConfig {
    __block USRVConfiguration *cfg;
    dispatch_sync(self.syncQueue, ^{
        cfg = _remoteConfig;
    });
    return  cfg;
}

- (void)setRemoteConfig:(USRVConfiguration *)remoteConfig {
    dispatch_sync(self.syncQueue, ^{
        _remoteConfig = remoteConfig;
    });
}

- (NSString *)getCurrentMetricsUrl {
    if (![self.remoteConfig.metricsUrl isEqualToString: @""]) {
        return self.remoteConfig.metricsUrl;
    }

    return self.localConfiguration.metricsUrl;
}

- (UADSConfigurationExperiments *)currentSessionExperiments {
    return [UADSConfigurationExperiments newWithJSON: self.currentSessionExperimentsAsDictionary];
}

- (NSDictionary *)currentSessionExperimentsAsDictionary {
    USRVConfiguration *config = [ self getCurrentConfiguration];

    if (config == nil) {
        return nil;
    }

    NSDictionary *currentFlags = [config.experiments currentSessionFlags] ? : @{};
    NSMutableDictionary *experiments = [NSMutableDictionary dictionaryWithDictionary:  currentFlags];

    NSDictionary *appliedFlags = [self.localConfiguration.experiments nextSessionFlags] ? : @{};

    [experiments setValuesForKeysWithDictionary: appliedFlags];

    return experiments;
}

#pragma mark UADSConfigurationMetricTagsReader
- (NSDictionary *)metricTags {
    USRVConfiguration *currentConfig = [self getCurrentConfiguration];

    if (currentConfig == nil) {
        return nil;
    }

    NSMutableDictionary *tags = [NSMutableDictionary dictionaryWithDictionary: self.currentSessionExperimentsAsDictionary];

    tags[kUnityServicesConfigValueSource] = currentConfig.source;

    return tags;
}

- (NSDictionary *)metricContainerConfigurationInfo {
    USRVConfiguration *currentConfig = [self getCurrentConfiguration];

    if (currentConfig == nil) {
        return nil;
    }
    NSMutableDictionary *info = [NSMutableDictionary new];
    info[kUnityServicesConfigValueMetricSamplingRate] = [@(currentConfig.metricSamplingRate) stringValue];
    
    [info uads_setValueIfNotNil: currentConfig.sessionToken
                         forKey: kMetricsContainerSessionTokenKey];

    return info;
}


- (void)subscribeToConfigUpdates: (UADSConfigurationObserver)observer {
    [self.mediator subscribe: observer];
}

- (void)saveConfiguration: (USRVConfiguration *)configuration {
    [self saveConfiguration:configuration notifyBridge:YES];
}

- (void)saveConfiguration: (USRVConfiguration *)configuration notifyBridge: (bool)notify {
    self.remoteConfig = configuration;
    if (notify) {
        [self.serviceProviderBridge saveConfiguration: configuration.originalJSON];
    }

    [self.mediator notifyObserversWithObjectAndRemove: configuration];
}

- (void)triggerSaved: (USRVConfiguration *)config {
    [self saveConfiguration: config notifyBridge: NO];
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


#pragma mark - scar hb
const NSString* kDefaultScarURL = @"https://scar.unityads.unity3d.com/v1/capture-scar-signals";
- (NSString *)getCurrentScarHBURL {
    NSString *scarURL;
    if (![self.remoteConfig.scarHbUrl isEqualToString: @""]) {
        scarURL = self.remoteConfig.scarHbUrl;
    } else {
        scarURL = self.localConfiguration.scarHbUrl;
    }


    return scarURL ?: kDefaultScarURL;
}

- (UADSSCARHBStrategyType) selectedSCARHBStrategyType {
    USRVConfiguration *config = [ self getCurrentConfiguration];
    if (!config.experiments.json) {
        return UADSSCARHeaderBiddingStrategyTypeDisabled;
    }
    NSDictionary* strategyDictionary = config.experiments.json[@"scar_bm"];
    if (![strategyDictionary isKindOfClass:[NSDictionary class]]) {
        return UADSSCARHeaderBiddingStrategyTypeDisabled;
    }
    NSString* strategyValue = strategyDictionary[@"value"];
    return [self selectedStrategyTypeForString:strategyValue];
}

- (UADSSCARHBStrategyType) selectedStrategyTypeForString:(NSString*)stringValue {
    if ([stringValue isEqualToString:@"eag"]) {
        return UADSSCARHeaderBiddingStrategyTypeEager;
    }
    if ([stringValue isEqualToString:@"laz"]) {
        return UADSSCARHeaderBiddingStrategyTypeLazy;
    }
    if ([stringValue isEqualToString:@"hyb"]) {
        return UADSSCARHeaderBiddingStrategyTypeHybrid;
    }
    return UADSSCARHeaderBiddingStrategyTypeDisabled;
}


@end
