#import "UADSMetricCommonTagsProvider.h"
#import "USRVSdkProperties.h"
#import "USRVDevice.h"

@interface UADSMetricCommonTagsProviderBase ()
@property (nonatomic, strong) id<UADSConfigurationMetricTagsReader> tagsReader;
@property (nonatomic, strong) id<UADSJsonStorageReader> storageReader;
@property (nonatomic, strong) id<UADSPrivacyResponseReader> privacyReader;
@property (nonatomic, strong) NSDictionary *mediationMetadata;
@end

@implementation UADSMetricCommonTagsProviderBase

+ (instancetype)newWithTagsReader: (id<UADSConfigurationMetricTagsReader>)tagsReader storageReader: (id<UADSJsonStorageReader>)storageReader privacyReader: (id<UADSPrivacyResponseReader>)privacyReader; {
    UADSMetricCommonTagsProviderBase *provider = [UADSMetricCommonTagsProviderBase new];

    provider.tagsReader = tagsReader;
    provider.storageReader = storageReader;
    provider.privacyReader = privacyReader;
    return provider;
}

- (nonnull UADSMetricCommonTags *)commonTags {
    NSMutableDictionary *metricTags = [NSMutableDictionary dictionary];

    [metricTags addEntriesFromDictionary: self.tagsReader.metricTags];
    [metricTags addEntriesFromDictionary: [self readMediationInfo]];
    [metricTags addEntriesFromDictionary: [self privacyInfo]];

    return [[UADSMetricCommonTags alloc] initWithCountryISO: [USRVDevice getNetworkCountryISOWithLocaleFallback]
                                                   platform: @"ios"
                                                 sdkVersion: [USRVSdkProperties getVersionName]
                                              systemVersion: [USRVDevice getOsVersion]
                                                   testMode: [USRVSdkProperties isTestMode]
                                                 metricTags: metricTags];
}

- (NSDictionary *)commonInfo {
    return [self.tagsReader metricInfo];
}

- (NSDictionary *)readMediationInfo {
    @synchronized (self) {
        if (!_mediationMetadata) {
            NSMutableDictionary *info = [NSMutableDictionary dictionary];
            info[@"m_name"] = [self.storageReader getValueForKey: @"mediation.name.value"];
            info[@"m_ver"] = [self.storageReader getValueForKey: @"mediation.version.value"];
            info[@"m_ad_ver"] = [self.storageReader getValueForKey: @"mediation.adapter_version.value"];
            _mediationMetadata = info;
        }
    }

    return _mediationMetadata;
}

- (NSDictionary *)privacyInfo {
    return @{
        @"prvc": uads_privacyResponseStateToString(self.privacyReader.responseState)
    };
}

@end
