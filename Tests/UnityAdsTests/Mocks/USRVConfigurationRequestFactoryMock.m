#import "USRVConfigurationRequestFactoryMock.h"
#import "WebRequestMock.h"

@implementation USRVConfigurationRequestFactoryMock

+ (instancetype)newFactoryWithExpectedNSDictionaryInRequest: (NSDictionary *)json invalidResponseCode: (BOOL)invalidResponseCode {
    USRVConfigurationRequestFactoryMock *factory = [USRVConfigurationRequestFactoryMock new];
    WebRequestMock *requestMock = [WebRequestMock new];
    NSError *error;
    NSData *jsonData;

    if (json) {
        jsonData = [NSJSONSerialization dataWithJSONObject: json
                                                   options: NSJSONWritingPrettyPrinted
                                                     error: &error];
    }

    requestMock.expectedData = jsonData;
    requestMock.isResponseCodeInvalid = invalidResponseCode;
    factory.expectedRequest = requestMock;
    return factory;
}

- (nonnull NSString *)baseURL {
    return @"baseURL";
}

- (id<USRVWebRequest> _Nullable)configurationRequestFor: (UADSGameMode)mode {
    return _expectedRequest;
}

@end


@implementation USRVConfiguration (LocalHost)

+ (instancetype)getConfigurationWithLocalHost {
    return [self newFromJSON: @{ kUnityServicesConfigValueUrl: @"http://localhost" }];
}

@end
