#import "UADSConfigurationLoaderWithPrivacy.h"

@interface UADSConfigurationLoaderWithPrivacy ()
@property (nonatomic, strong) id<UADSConfigurationLoader>original;
@property (nonatomic, strong) id<UADSPrivacyLoader>privacyLoader;
@property (nonatomic, strong) id<UADSPrivacyResponseSaver, UADSPrivacyResponseReader>responseStorage;
@end

@implementation UADSConfigurationLoaderWithPrivacy


+ (instancetype)newWithOriginal: (id<UADSConfigurationLoader>)original
               andPrivacyLoader: (id<UADSPrivacyLoader>)privacyLoader
             andResponseStorage: (id<UADSPrivacyResponseSaver, UADSPrivacyResponseReader>)responseStorage {
    UADSConfigurationLoaderWithPrivacy *decorator = [UADSConfigurationLoaderWithPrivacy new];

    decorator.original = original;
    decorator.privacyLoader = privacyLoader;
    decorator.responseStorage = responseStorage;
    return decorator;
}

- (void)loadConfigurationWithSuccess: (nonnull UADSConfigurationCompletion NS_NOESCAPE)success
                  andErrorCompletion: (nonnull UADSErrorCompletion NS_NOESCAPE)error {
    if (_responseStorage.responseState != kUADSPrivacyResponseUnknown) {
        [self callLoadConfigWithSuccess: success
                     andErrorCompletion: error];
    } else {
        [self performPrivacyRequestFirstWithSuccess: success
                                 andErrorCompletion: error];
    }
}

- (void)performPrivacyRequestFirstWithSuccess: (nonnull UADSConfigurationCompletion NS_NOESCAPE)success
                           andErrorCompletion: (nonnull UADSErrorCompletion NS_NOESCAPE)error {
    [_privacyLoader loadPrivacyWithSuccess:^(UADSInitializationResponse *_Nonnull response) {
        [self processPrivacyResponse: response
                         withSuccess: success
                  andErrorCompletion: error];
    }
                        andErrorCompletion:^(id<UADSError> _Nonnull privacyError) {
                            [self processPrivacyError: privacyError
                                          withSuccess: success
                                   andErrorCompletion: error];
                        }];
}

- (void)callLoadConfigWithSuccess: (nonnull UADSConfigurationCompletion NS_NOESCAPE)success
               andErrorCompletion: (nonnull UADSErrorCompletion NS_NOESCAPE)error  {
    [self.original loadConfigurationWithSuccess: success
                             andErrorCompletion: error];
}

- (void)processPrivacyResponse: (UADSInitializationResponse *)response
                   withSuccess: (nonnull UADSConfigurationCompletion NS_NOESCAPE)success
            andErrorCompletion: (nonnull UADSErrorCompletion NS_NOESCAPE)error {
    [_responseStorage saveResponse: response];
    [self callLoadConfigWithSuccess: success
                 andErrorCompletion: error];
}

- (void)processPrivacyError: (id<UADSError>)privacyError
                withSuccess: (nonnull UADSConfigurationCompletion NS_NOESCAPE)success
         andErrorCompletion: (nonnull UADSErrorCompletion NS_NOESCAPE)error {
    if ([self shouldProceedWithTheCallForError: privacyError]) {
        [self processPrivacyResponse: [UADSInitializationResponse newFromDictionary: @{}]
                         withSuccess: success
                  andErrorCompletion: error];
    } else {
        error(privacyError);
    }
}

- (BOOL)shouldProceedWithTheCallForError: (id<UADSError>)error {
    return error.errorDomain == kPrivacyLoaderErrorDomain;
}

@end
