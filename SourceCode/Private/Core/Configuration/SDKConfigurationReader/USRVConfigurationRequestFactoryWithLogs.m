#import "USRVConfigurationRequestFactoryWithLogs.h"
#import "USRVDeviceLog.h"
@interface USRVConfigurationRequestFactoryWithLogs ()
@property (nonatomic, strong) id<USRVInitializationRequestFactory>original;
@end

@implementation USRVConfigurationRequestFactoryWithLogs
+ (instancetype)newWithOriginal: (id<USRVInitializationRequestFactory>)original {
    USRVConfigurationRequestFactoryWithLogs *factory = [USRVConfigurationRequestFactoryWithLogs new];

    factory.original = original;
    return factory;
}

- (nonnull NSString *)baseURL {
    return _original.baseURL;
}

- (id<USRVWebRequest> _Nullable)requestOfType: (USRVInitializationRequestType)type {
    __block id<USRVWebRequest> request;

    uads_measure_performance_and_log(@"Create request", ^{
        request = [self.original requestOfType: type];
    });
    USRVLogInfo(@"Configuration Request URL: %@", request.url);
    return request;
}

@end
