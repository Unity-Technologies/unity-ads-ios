#import <XCTest/XCTest.h>
#import "UADSServiceProviderContainer.h"
#import "WebRequestFactoryMock.h"
#import "XCTestCase+Convenience.h"
#import "UADSLoaderIntegrationTestsHelper.h"
#import "NSDictionary+JSONString.h"
#import "UADSTokenStorage.h"
#import "UADSHeaderBiddingToken+Compressed.h"
#import "UADSDeviceTestsHelper.h"
#import "UADSJsonStorageKeyNames.h"
#import "UADSRetryInfoReaderMock.h"
#import "UADSConfigurationReaderMock.h"

#define DEFAULT_TTO  3
#define DEFAULT_PRWO 1

@interface UADSAsyncTokenWithPrivacyIntegrationTests : XCTestCase
@property (strong, nonatomic) UADSServiceProvider *serviceProvider;
@property (strong, nonatomic) WebRequestFactoryMock *webRequestFactoryMock;
@property (strong, nonatomic) UADSDeviceTestsHelper *infoTester;
@property (strong, nonatomic) UADSLoaderIntegrationTestsHelper *configTester;
@property (strong, nonatomic) UADSConfigurationReaderMock *configurationReaderMock;
@end

@implementation UADSAsyncTokenWithPrivacyIntegrationTests

- (void)setUp {
    [UADSTokenStorage.sharedInstance deleteTokens];
    _serviceProvider = [UADSServiceProvider new];
    _webRequestFactoryMock = [WebRequestFactoryMock new];
    _serviceProvider.webViewRequestFactory = _webRequestFactoryMock;
    _infoTester = [UADSDeviceTestsHelper new];
    _configTester = [UADSLoaderIntegrationTestsHelper new];
    _configurationReaderMock = [UADSConfigurationReaderMock new];
    [self deleteConfigFile];
    [_infoTester clearAllStorages];
}

- (void)test_returns_null_invalid_token_when_sdk_not_initialized {
    [self setInitState: NOT_INITIALIZED];
    XCTestExpectation *exp = self.defaultExpectation;

    [_serviceProvider.hbTokenReader getToken:^(UADSHeaderBiddingToken *_Nullable token) {
        XCTAssertFalse(token.isValid);
        [exp fulfill];
    }];

    [self waitForExpectations: @[exp]
                      timeout: 1];
}

- (void)test_returns_contextual_token_when_privacy_fails {
    [self run_test_with_privacy_wait: true
                     makePrivacyFail: true
                      makeConfigFail: false
              shouldReturnContextual: true];
}

- (void)test_returns_behavioral_token_after_privacy_succeeds {
    [self run_test_with_privacy_wait: true
                     makePrivacyFail: false
                      makeConfigFail: false
              shouldReturnContextual: false];
}

- (void)test_returns_contextual_token_while_waiting_for_privacy {
    [self run_test_with_privacy_wait: false
                     makePrivacyFail: false
                      makeConfigFail: false
              shouldReturnContextual: true];
}

- (void)run_test_with_privacy_wait: (BOOL)privacyWait
                   makePrivacyFail: (BOOL)privacyFail
                    makeConfigFail: (BOOL)configFail
            shouldReturnContextual: (BOOL)isContextual {
    [_infoTester commitAllTestData];
    self.webRequestFactoryMock.expectedRequestData = @[
        privacyFail ? [NSData new] : _configTester.successPayloadPrivacy.uads_jsonData,
        configFail ? [NSData new] : _configTester.successPayload.uads_jsonData
    ];

    USRVConfiguration *config = [self configWithPrivacyWait: privacyWait];

    [self saveConfigurationToFile: config];

    [self setInitState: INITIALIZED_SUCCESSFULLY];

    _webRequestFactoryMock.requestSleepTime = DEFAULT_PRWO;
    XCTestExpectation *exp = self.defaultExpectation;

    exp.expectedFulfillmentCount = 2;
    _serviceProvider.retryReader = [UADSRetryInfoReaderMock newWithInfo: @{}];
    _configurationReaderMock.expectedConfiguration = config;
    id<UADSConfigurationLoader> loader = [_serviceProvider configurationLoader];


    dispatch_async(self.globalQueue, ^{
        [self.serviceProvider.hbTokenReader getToken:^(UADSHeaderBiddingToken *_Nullable token) {
            [self validateIfTokenContextual: token
                               isContextual: isContextual];
            [exp fulfill];
        }];
    });

    dispatch_async(self.globalQueue, ^{
        [loader loadConfigurationWithSuccess:^(USRVConfiguration *_Nonnull config) {
            [exp fulfill];
        }
                          andErrorCompletion:^(id<UADSError> _Nonnull error) {
                              [exp fulfill];
                          }];
    });

    [self waitForExpectations: @[exp]
                      timeout: DEFAULT_TTO + DEFAULT_PRWO + 1];
}

- (dispatch_queue_t)globalQueue {
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
}

- (void)validateIfTokenContextual: (UADSHeaderBiddingToken *)token isContextual: (BOOL)isContextual {
    XCTAssertTrue(token.isValid);
    NSArray *expectedKeys = isContextual ? self.contextualTokenKeys : self.behavioralTokenKeys;
    NSMutableArray *fullExpectedKeys = [NSMutableArray arrayWithArray:expectedKeys];
    [fullExpectedKeys addObject:@"tid"];

    [_infoTester validateDataContains: token.tokenDictionary
                              allKeys: fullExpectedKeys];
}

- (NSArray *)contextualTokenKeys {
    return _infoTester.allExpectedKeys;
}

- (NSArray *)behavioralTokenKeys {
    return [self.contextualTokenKeys arrayByAddingObjectsFromArray: _infoTester.piiDecisionContentData.allKeys];
}

- (void)deleteConfigFile {
    NSString *fileName = [USRVSdkProperties getLocalConfigFilepath];

    [[NSFileManager defaultManager] removeItemAtPath: fileName
                                               error: nil];
}

- (void)saveConfigurationToFile: (USRVConfiguration *)config {
    [[config toJson] writeToFile: [USRVSdkProperties getLocalConfigFilepath]
                      atomically: YES];
}

- (void)setInitState: (InitializationState)state {
    [USRVSdkProperties setInitializationState: state];
}

- (USRVConfiguration *)configWithPrivacyWait: (BOOL)privacyWait {
    return [USRVConfiguration newFromJSON: @{
                @"tto": @(DEFAULT_TTO * 1000),
                @"prwo": @(DEFAULT_PRWO * 1000),
                kUnityServicesConfigValueUrl: @"url",
                @"exp": [self experimentsWithPrivacyWait: privacyWait]
    }];
}

- (NSDictionary *)experimentsWithPrivacyWait: (BOOL)privacyWait {
    return @{
        @"tsi_prw": @(privacyWait)
    };
}

@end
