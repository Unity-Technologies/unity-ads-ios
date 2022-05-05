#import <Foundation/Foundation.h>
#import "USRVConfiguration.h"
#import "UADSConfigurationMetricTagsReader.h"
#import "UADSGenericMediator.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^UADSConfigurationObserver)(USRVConfiguration *);

@protocol UADSConfigurationSaver <NSObject>

- (void)saveConfiguration: (USRVConfiguration *)configuration;

@end

@protocol UADSConfigurationReader <NSObject>

- (USRVConfiguration *)getCurrentConfiguration;

@end



@protocol UADSConfigurationSubject <NSObject>

- (void)subscribeToConfigUpdates: (UADSConfigurationObserver)observer;

@end


@protocol UADSConfigurationCRUD <NSObject, UADSConfigurationSubject, UADSConfigurationReader, UADSConfigurationMetricTagsReader, UADSConfigurationSaver>

@end


@interface UADSConfigurationCRUDBase : NSObject<UADSConfigurationCRUD>
@end

NS_ASSUME_NONNULL_END
