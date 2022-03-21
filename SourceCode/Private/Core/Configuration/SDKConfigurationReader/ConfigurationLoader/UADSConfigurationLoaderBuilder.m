#import "UADSConfigurationLoaderBuilder.h"
#import "USRVWebRequestFactory.h"
#import "USRVSDKMetrics.h"
#import "UADSConfigurationReader.h"
#import "USRVConfigurationRequestFactoryWithLogs.h"
#import "UADSHeaderBiddingTokenReaderBuilder.h"
#import "UADSConfigurationLegacyLoader.h"

@interface UADSConfigurationLoaderBuilder ()
@property (nonatomic, strong) UADSConfigurationLoaderBuilderConfig config;
@property (nonatomic, strong) id<IUSRVWebRequestFactory> webRequestFactory;
@end

@implementation UADSConfigurationLoaderBuilder

+ (instancetype)newWithConfig: (UADSConfigurationLoaderBuilderConfig)config
         andWebRequestFactory: (id<IUSRVWebRequestFactory>)webRequestFactory {
    UADSConfigurationLoaderBuilder *builder = [self new];

    builder.tagsReader = [UADSConfigurationReaderBase new];
    builder.metricsSender = [USRVSDKMetrics getInstance];
    builder.config = config;
    builder.webRequestFactory = webRequestFactory;

    id<UADSHeaderBiddingTokenCRUD> crud = UADSHeaderBiddingTokenReaderBuilder.sharedInstance.defaultReader;

    builder.configurationSaver = [UADSConfigurationPersistence newWithTokenCRUD: crud];
    return builder;
}

+ (instancetype)newWithConfig: (UADSConfigurationLoaderBuilderConfig)config {
    return [self newWithConfig: config
          andWebRequestFactory      : [USRVWebRequestFactory new]];
}

- (id<UADSConfigurationLoader>)loader {
    id<UADSConfigurationLoader> loaderToReturn = self.baseStrategy;

    loaderToReturn = [self decorateWithSaving: loaderToReturn];
    return loaderToReturn;
}

- (id<UADSConfigurationLoader>)baseStrategy {
    return [UADSConfigurationLoaderStrategy newWithMainLoader: self.mainLoader
                                            andFallbackLoader: self.fallbackLoader
                                                 metricSender: self.metricsSender
                                             metricTagsReader: self.tagsReader];
}

- (id<UADSConfigurationLoader>)decorateWithSaving: (id<UADSConfigurationLoader>)original {
    return [UADSConfigurationLoaderWithPersistence newWithOriginal: original
                                                          andSaver: self.configurationSaver];
}

- (id<UADSConfigurationLoader>)mainLoader {
    id<USRVConfigurationRequestFactory> factory = [self getMainFactory];

    factory = [self addLoggerToFactory: factory];
    return [UADSConfigurationLoaderBase newWithFactory: factory];
}

- (id<UADSConfigurationLoader>)fallbackLoader {
    return [UADSConfigurationLegacyLoader newWithRequestFactory: self.webRequestFactory];
}

- (id<USRVConfigurationRequestFactory>)getMainFactory {
    if (_mainRequestFactory) {
        return _mainRequestFactory;
    }

    return [USRVConfigurationRequestFactoryBase defaultFactoryWithConfig: self.config
                                                    andWebRequestFactory: _webRequestFactory
                                                           metricsSender: _metricsSender
                                                        metricTagsReader: _tagsReader];
}

- (id<USRVConfigurationRequestFactory>)addLoggerToFactory: (id<USRVConfigurationRequestFactory>)factory {
    return [USRVConfigurationRequestFactoryWithLogs newWithOriginal: factory];
}

@end
