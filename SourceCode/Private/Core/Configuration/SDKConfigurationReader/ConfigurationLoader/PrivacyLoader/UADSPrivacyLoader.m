#import "UADSPrivacyLoader.h"
#import "NSError+UADSError.h"
#import "UADSDeviceInfoReaderOptimizer.h"

NSString *const kPrivacyLoaderErrorDomain = @"com.unity.ads.UADSPrivacyLoader";

NSString * uads_privacyErrorTypeToString(UADSPrivacyLoaderError type) {
    switch (type) {
        case kUADSPrivacyLoaderParsingError:
            return @"ResponseParsing";

        case kUADSPrivacyLoaderIsNotCreated:
            return @"PrivacyRequestNotCreated";

        case kUADSPrivacyLoaderInvalidResponseCode:
            return @"RequestFailed";

        default:
            return nil;
    }
}

@interface UADSPrivacyLoaderBase ()
@property (nonatomic, strong) id<USRVInitializationRequestFactory>requestFactory;
@property (nonatomic, strong) UADSDeviceInfoReaderOptimizer *optimizer;
@end


@implementation UADSPrivacyLoaderBase
+ (instancetype)newWithFactory: (id<USRVInitializationRequestFactory>)requestFactory {
    UADSPrivacyLoaderBase *base = [self new];

    base.requestFactory = requestFactory;
    base.optimizer = [UADSDeviceInfoReaderOptimizer new];
    return base;
}

- (void)loadPrivacyWithSuccess: (nonnull UADSPrivacyCompletion)success
            andErrorCompletion: (nonnull UADSErrorCompletion)errorCompletion { \
    [self.optimizer startOptimization];

    [self makePrivacyRequestWithSuccess: success
                     andErrorCompletion: errorCompletion];
}

- (void)makePrivacyRequestWithSuccess: (nonnull UADSPrivacyCompletion)success
                   andErrorCompletion: (nonnull UADSErrorCompletion)errorCompletion {
    id<USRVWebRequest> request;

    @try {
        request = [self.requestFactory requestOfType: USRVInitializationRequestTypePrivacy];
    } @catch (NSException *exception) {
        errorCompletion(uads_privacyRequestIsNotCreatedLoaderError);
        return;
    }

    if (request == nil) {
        errorCompletion(uads_privacyRequestIsNotCreatedLoaderError);
        return;
    }

    NSData *responseData = [request makeRequest];
    NSError *error = [request error];

    if (error) {
        errorCompletion(error);
        return;
    }

    if (![request is2XXResponse]) {
        if (request.responseCode == 423) {
            errorCompletion(uads_privacyGameDisabledError);
            return;
        }
        errorCompletion(uads_privacyInvalidResponseCodeError);
        return;
    }

    if (!responseData) {
        errorCompletion(uads_privacyJsonParsingLoaderError(@{}));
        return;
    }

    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData: responseData
                                                               options: kNilOptions
                                                                 error: &error];

    if (error) {
        errorCompletion(uads_privacyJsonParsingLoaderError(error.userInfo));
        return;
    }

    UADSInitializationResponse *privacyResponse = [UADSInitializationResponse newFromDictionary: dictionary];

    privacyResponse.responseCode = request.responseCode;

    success(privacyResponse);
}

@end
