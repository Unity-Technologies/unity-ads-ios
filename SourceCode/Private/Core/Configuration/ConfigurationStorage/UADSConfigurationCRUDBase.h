#import <Foundation/Foundation.h>
#import "USRVConfiguration.h"
#import "UADSConfigurationMetricTagsReader.h"
#import "UADSGenericMediator.h"
#import "UADSServiceProviderProxy.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^UADSConfigurationObserver)(USRVConfiguration *);

@protocol UADSConfigurationSaver <NSObject>

- (void)saveConfiguration: (USRVConfiguration *)configuration;
- (void)triggerSaved: (USRVConfiguration *)config;
@end

@protocol UADSConfigurationReader <NSObject>

- (USRVConfiguration *)getCurrentConfiguration;
- (NSDictionary *)     currentSessionExperimentsAsDictionary;
- (UADSConfigurationExperiments *)     currentSessionExperiments;
- (NSString *)getCurrentMetricsUrl;
@end



@protocol UADSConfigurationSubject <NSObject>

- (void)subscribeToConfigUpdates: (UADSConfigurationObserver)observer;

@end


@protocol UADSConfigurationCRUD <NSObject, UADSConfigurationSubject, UADSConfigurationReader, UADSConfigurationMetricTagsReader, UADSConfigurationSaver>

@end


@interface UADSConfigurationCRUDBase : NSObject<UADSConfigurationCRUD>
@property (nonatomic, weak) UADSServiceProviderProxy *serviceProviderBridge;
@end

NS_ASSUME_NONNULL_END
