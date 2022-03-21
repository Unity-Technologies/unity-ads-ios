#import <Foundation/Foundation.h>
#import "UADSConfigurationLoaderStrategy.h"
#import "UADSConfigurationExperiments.h"
#import "UADSConfigurationLoaderWithPersistence.h"
NS_ASSUME_NONNULL_BEGIN

typedef id<UADSConfigurationRequestFactoryConfig, UADSPIIDataSelectorConfig> UADSConfigurationLoaderBuilderConfig;

@interface UADSConfigurationLoaderBuilder : NSObject
@property (nonatomic, strong) id<USRVConfigurationRequestFactory> mainRequestFactory;
@property (nonatomic, strong) id<UADSConfigurationSaver> configurationSaver;
@property (nonatomic, strong) id<ISDKMetrics> metricsSender;
@property (nonatomic, strong) id<UADSConfigurationMetricTagsReader> tagsReader;
+ (instancetype)newWithConfig: (UADSConfigurationLoaderBuilderConfig)config;
+ (instancetype)newWithConfig: (UADSConfigurationLoaderBuilderConfig)config
         andWebRequestFactory: (id<IUSRVWebRequestFactory>)webRequestFactory;
- (id<UADSConfigurationLoader>)loader;
@end

NS_ASSUME_NONNULL_END
