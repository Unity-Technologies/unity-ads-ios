#import "UADSConfigurationLoader.h"
#import "NSError+UADSError.h"
#import "USRVConfiguration.h"

NSString *const kConfigurationLoaderErrorDomain = @"com.unity.ads.UADSConfigurationLoader";

extern NSString * uads_configurationErrorTypeToString(UADSConfigurationLoaderError type) {
    switch (type) {
        case kUADSConfigurationLoaderParsingError:
            return @"ResponseParsing";

        case kUADSConfigurationLoaderRequestIsNotCreated:
            return @"ConfigurationRequestNotCreated";

        case kUADSConfigurationLoaderInvalidResponseCode:
            return @"RequestFailed";

        case kUADSConfigurationLoaderInvalidWebViewURL:
            return @"URLNotFound";

        default:
            return nil;
    }
}

@interface UADSConfigurationLoaderBase ()
@property (nonatomic, strong) id<USRVInitializationRequestFactory>requestFactory;
@end

@implementation UADSConfigurationLoaderBase

+ (id<UADSConfigurationLoader>)newWithFactory: (id<USRVInitializationRequestFactory>)requestFactory {
    UADSConfigurationLoaderBase *base = [self new];

    base.requestFactory = requestFactory;
    return base;
}

- (void)loadConfigurationWithSuccess: (NS_NOESCAPE UADSConfigurationCompletion)success
                  andErrorCompletion: (NS_NOESCAPE UADSErrorCompletion)errorCompletion {
    id<USRVWebRequest> request;

    @try {
        request = [self.requestFactory requestOfType: USRVInitializationRequestTypeToken];
    } @catch (NSException *exception) {
        errorCompletion(uads_requestIsNotCreatedLoaderError);
        return;
    }

    if (request == nil) {
        errorCompletion(uads_requestIsNotCreatedLoaderError);
        return;
    }

    NSData *responseData = [request makeRequest];
    NSError *error = [request error];

    if (error) {
        errorCompletion(error);
        return;
    }

    if (![request is2XXResponse]) {
        errorCompletion(uads_invalidResponseCodeError);
        return;
    }

    if (!responseData) {
        errorCompletion(uads_jsonParsingLoaderError(@{}));
        return;
    }

    NSDictionary *configDictionary = [NSJSONSerialization JSONObjectWithData: responseData
                                                                     options: kNilOptions
                                                                       error: &error];

    if (error) {
        errorCompletion(uads_jsonParsingLoaderError(error.userInfo));
        return;
    }

    USRVConfiguration *config = [USRVConfiguration newFromJSON: configDictionary];

    if (config.hasValidWebViewURL) {
        success(config);
        return;
    } else {
        errorCompletion(uads_invalidWebViewURLLoaderError);
        return;
    }
}

@end
