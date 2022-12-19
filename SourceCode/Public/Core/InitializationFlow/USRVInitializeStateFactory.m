#import "USRVInitializeStateFactory.h"
#import "USRVInitializeStateReset.h"
#import "USRVInitializeStateInitModules.h"
#import "USRVInitializeStateConfig.h"
#import "USRVInitializeStateLoadWeb.h"
#import "USRVInitializeStateCreate.h"
#import "USRVInitializeStateComplete.h"
#import "UADSConfigurationCRUDBase.h"
#import "USRVInitializeStateWithMeasurement.h"
#import "UADSServiceProvider.h"
#import "USRVInitializeStateLoadConfigFile.h"

@interface USRVInitializeStateFactory()
@property (nonatomic, strong) id<UADSConfigurationReader> configReader;
@property (nonatomic, weak) id<UADSConfigurationLoaderProvider, UADSNativeNetworkLayerProvider>loaderProvider;
@property (nonatomic, strong) UADSCommonNetworkProxy *networkLayer;
@end

@implementation USRVInitializeStateFactory


+ (instancetype)newWithBuilder:(id<UADSConfigurationLoaderProvider, UADSNativeNetworkLayerProvider>)configurationLoaderBuilder
               andConfigReader:(id<UADSConfigurationReader>)configReader {
    USRVInitializeStateFactory *obj = [self new];
    obj.configReader = configReader;
    obj.loaderProvider = configurationLoaderBuilder;
    return obj;
    
}

- (id<USRVInitializeTask>)stateFor:(USRVInitializeStateType)type {
    id<USRVInitializeTask> originalTask = [self originalStateFor: type];
    return [USRVInitializeStateWithMeasurement newWithOriginal: originalTask];
}

- (id<USRVInitializeTask>)originalStateFor:(USRVInitializeStateType)type {
    switch (type) {
        case USRVInitializeStateTypeConfigLocal:
            return [[USRVInitializeStateLoadConfigFile alloc] init];;
        case USRVInitializeStateTypeConfigFetch:
            return self.configFetchTask;
        case USRVInitializeStateTypeReset:
            return [[USRVInitializeStateReset alloc] initWithConfiguration: self.configuration];
        case USRVInitializeStateTypeInitModules:
            return [[USRVInitializeStateInitModules alloc] initWithConfiguration: self.configuration];
        case USRVInitializeStateTypeLoadWebView:
            return self.loadWebTask;
        case USRVInitializeStateTypeCreateWebView:
            return [[USRVInitializeStateCreate alloc] initWithConfiguration: self.configuration];
        case USRVInitializeStateTypeComplete:
            return [[USRVInitializeStateComplete alloc] initWithConfiguration: self.configuration];
    }
}

- (USRVConfiguration *)configuration {
    return [self.configReader getCurrentConfiguration];
}

- (id<USRVInitializeTask>)configFetchTask {
    USRVConfiguration *config = _configReader.getCurrentConfiguration ?: [[USRVConfiguration alloc] init];
    USRVInitializeStateConfig *state = [[USRVInitializeStateConfig alloc] initWithConfiguration: config retries:0 retryDelay: config.retryDelay];
    state.localConfig = config;
    state.configLoader = _loaderProvider.configurationLoader;
    state.configLoaderBuilder = _loaderProvider;
    return state;
}

- (id<USRVInitializeTask>)loadWebTask {
    USRVInitializeStateLoadWeb *loadWeb = [[USRVInitializeStateLoadWeb alloc] initWithConfiguration: self.configuration retries: 0 retryDelay: self.configuration.retryDelay];
    loadWeb.networkLayer = _loaderProvider.nativeNetworkLayer;
    return loadWeb;
}
@end
