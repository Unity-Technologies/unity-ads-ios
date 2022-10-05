#import <Foundation/Foundation.h>
#import "UADSConfigurationLoaderStrategy.h"
#import "UADSConfigurationExperiments.h"
#import "UADSConfigurationLoaderWithPersistence.h"
#import "UADSPrivacyStorage.h"
#import "UADSPrivacyLoader.h"
#import "UADSCurrentTimestamp.h"
#import "UADSLogger.h"
#import "UADSInitializeEventsMetricSender.h"
#import "UADSGameSessionIdReader.h"

NS_ASSUME_NONNULL_BEGIN

typedef id<UADSClientConfig, UADSPrivacyConfig> UADSConfigurationLoaderBuilderConfig;

@interface UADSConfigurationLoaderBuilder : NSObject
@property (nonatomic, strong) id<USRVInitializationRequestFactory> mainRequestFactory;
@property (nonatomic, strong) id<UADSConfigurationSaver> configurationSaver;
@property (nonatomic, strong) id<ISDKMetrics> metricsSender;
@property (nonatomic, strong) id<UADSPrivacyResponseSaver, UADSPrivacyResponseReader> privacyStorage;
@property (nonatomic, strong) id<UADSPrivacyLoader>privacyLoader;
@property (nonatomic, strong) id<UADSDeviceInfoReader>deviceInfoReader;
@property (nonatomic, strong) id<UADSBaseURLBuilder>urlBuilder;
@property (nonatomic, strong) id<UADSCurrentTimestamp>currentTimeStampReader;
@property (nonatomic, strong) id<UADSLogger>logger;
@property (nonatomic, strong) id<UADSRetryInfoReader> retryInfoReader;
@property (nonatomic, strong) id<UADSGameSessionIdReader> gameSessionIdReader;
@property (nonatomic) BOOL noCompression;

- (id<UADSConfigurationLoader>)         loader;
- (id<USRVInitializationRequestFactory>)requestFactoryWithExtendedInfo: (BOOL)hasExtendedInfo;

+ (instancetype)newWithConfig: (UADSConfigurationLoaderBuilderConfig)config
         andWebRequestFactory: (id<IUSRVWebRequestFactory>)webRequestFactory
                 metricSender: (id<ISDKMetrics>)metricSender;
@end

NS_ASSUME_NONNULL_END
