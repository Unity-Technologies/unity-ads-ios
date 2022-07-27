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
    factory.requestedTypes = [NSArray new];
    return factory;
}

- (nonnull NSString *)baseURL {
    return @"baseURL";
}

- (instancetype)init
{
    self = [super init];

    if (self) {
        _requestedTypes = [NSArray new];
    }

    return self;
}

- (id<USRVWebRequest> _Nullable)requestOfType: (USRVInitializationRequestType)type {
    _requestedTypes = [_requestedTypes arrayByAddingObject: @(type)];
    return _expectedRequest;
}

@end


@implementation USRVConfiguration (LocalHost)

+ (instancetype)getConfigurationWithLocalHost {
    return [self newFromJSON: @{ kUnityServicesConfigValueUrl: @"http://localhost" }];
}

@end
