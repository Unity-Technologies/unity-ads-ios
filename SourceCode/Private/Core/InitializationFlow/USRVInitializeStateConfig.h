#import "USRVInitialize.h"
#import <Foundation/Foundation.h>
#import "UADSConfigurationLoaderBuilder.h"

NS_ASSUME_NONNULL_BEGIN

@interface USRVInitializeStateConfig : USRVInitializeState

@property (nonatomic, strong) USRVConfiguration *localConfig;
@property (nonatomic, assign) int retries;
@property (nonatomic, assign) long retryDelay;
@property (nonatomic, strong) id<UADSConfigurationLoader> configLoader;
@property (nonatomic, strong) UADSConfigurationLoaderBuilder *configLoaderBuilder;

- (instancetype)initWithConfiguration: (USRVConfiguration *)configuration retries: (int)retries retryDelay: (long)retryDelay;

@end

NS_ASSUME_NONNULL_END
