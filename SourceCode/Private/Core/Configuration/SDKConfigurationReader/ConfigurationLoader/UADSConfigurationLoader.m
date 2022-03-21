#import "UADSConfigurationLoader.h"
#import "NSError+UADSError.h"
#import "USRVConfiguration.h"

NSString *const kConfigurationLoaderErrorDomain = @"com.unity.ads.UADSConfigurationLoader";

@interface UADSConfigurationLoaderBase ()
@property (nonatomic, strong) id<USRVConfigurationRequestFactory>requestFactory;
@end

@implementation UADSConfigurationLoaderBase

+ (id<UADSConfigurationLoader>)newWithFactory: (id<USRVConfigurationRequestFactory>)requestFactory {
    UADSConfigurationLoaderBase *base = [UADSConfigurationLoaderBase new];

    base.requestFactory = requestFactory;
    return base;
}

- (void)loadConfigurationWithSuccess: (NS_NOESCAPE UADSConfigurationCompletion)success
                  andErrorCompletion: (NS_NOESCAPE UADSErrorCompletion)errorCompletion {
    id<USRVWebRequest> request;

    @try {
        request = [self.requestFactory configurationRequestFor: UADSGameModeMix];
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
