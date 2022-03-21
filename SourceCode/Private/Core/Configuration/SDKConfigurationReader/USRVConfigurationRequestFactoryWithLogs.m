#import "USRVConfigurationRequestFactoryWithLogs.h"
#import "USRVDeviceLog.h"
@interface USRVConfigurationRequestFactoryWithLogs ()
@property (nonatomic, strong) id<USRVConfigurationRequestFactory>original;
@end

@implementation USRVConfigurationRequestFactoryWithLogs
+ (instancetype)newWithOriginal: (id<USRVConfigurationRequestFactory>)original {
    USRVConfigurationRequestFactoryWithLogs *factory = [USRVConfigurationRequestFactoryWithLogs new];

    factory.original = original;
    return factory;
}

- (nonnull NSString *)baseURL {
    return _original.baseURL;
}

- (id<USRVWebRequest> _Nullable)configurationRequestFor: (UADSGameMode)mode {
    id<USRVWebRequest> request = [_original configurationRequestFor: mode];

    USRVLogInfo(@"Configuration Request URL: %@", request.url);
    return request;
}

@end
