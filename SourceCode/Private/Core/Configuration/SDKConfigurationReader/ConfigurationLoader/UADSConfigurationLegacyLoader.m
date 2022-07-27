#import "UADSConfigurationLegacyLoader.h"
#import "USRVSdkProperties.h"
#import "NSError+UADSError.h"

@interface UADSConfigurationLegacyLoader ()
@property (nonatomic, strong) id<IUSRVWebRequestFactory> requestFactory;
@end

@implementation UADSConfigurationLegacyLoader

+ (instancetype)newWithRequestFactory: (id<IUSRVWebRequestFactory>)requestFactory {
    UADSConfigurationLegacyLoader *loader = [self new];

    loader.requestFactory = requestFactory;
    return loader;
}

- (void)loadConfigurationWithSuccess: (NS_NOESCAPE UADSConfigurationCompletion)success
                  andErrorCompletion: (NS_NOESCAPE UADSErrorCompletion)error {
    USRVConfiguration *configuration = [[USRVConfiguration alloc] initWithConfigUrl: [USRVSdkProperties getConfigUrl]];

    [configuration setRequestFactory: self.requestFactory];
    [configuration makeRequest];

    if (configuration.requestError) {
        error(configuration.requestError);
        return;
    }

    if (configuration.error) {
        error(configuration.error);
        return;
    }

    success(configuration);
}

@end
