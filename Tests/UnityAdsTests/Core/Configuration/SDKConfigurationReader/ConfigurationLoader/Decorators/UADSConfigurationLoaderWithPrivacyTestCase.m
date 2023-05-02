#import <XCTest/XCTest.h>
#import "UADSConfigurationLoaderWithPrivacy.h"
#import "UADSConfigurationLoaderMock.h"
#import "UADSPrivacyStorageMock.h"
#import "UADSPrivacyLoaderMock.h"
#import "XCTestCase+Convenience.h"
#import "NSError+UADSError.h"

@interface UADSConfigurationLoaderWithPrivacyTestCase : XCTestCase
@property (nonatomic, strong) UADSConfigurationLoaderMock *configLoaderMock;
@property (nonatomic, strong) UADSPrivacyLoaderMock *privacyLoaderMock;
@property (nonatomic, strong) UADSPrivacyStorageMock *storageMock;
@end

@implementation UADSConfigurationLoaderWithPrivacyTestCase

- (void)setUp {
    self.configLoaderMock = [UADSConfigurationLoaderMock new];
    self.privacyLoaderMock = [UADSPrivacyLoaderMock new];
    self.storageMock = [UADSPrivacyStorageMock new];
}

- (id<UADSConfigurationLoader>)sut {
    return [UADSConfigurationLoaderWithPrivacy newWithOriginal: _configLoaderMock
                                              andPrivacyLoader: _privacyLoaderMock
                                            andResponseStorage: _storageMock];
}

- (void)test_privacy_with_success_calls_saver_and_loader {
    [self runFlowWithPrivacyCodeAndValidate: 200
                          allowTrackingFlag: true
                         expectedSaverCalls: 1
                               privacyCalls: 1
                               loaderCalled: 1
                               errorPrivacy: nil];
}

- (void)test_network_error_doesnt_call_loader_and_saver_hardware_error {
    [self runFlowWithPrivacyCodeAndValidate: 0
                          allowTrackingFlag: false
                         expectedSaverCalls: 0
                               privacyCalls: 1
                               loaderCalled: 0
                               errorPrivacy: self.privacyErrorMock];
}

- (void)test_game_disabled_error_doesnt_call_loader_and_saver {
    [self runFlowWithPrivacyCodeAndValidate: 0
                          allowTrackingFlag: false
                         expectedSaverCalls: 0
                               privacyCalls: 1
                               loaderCalled: 0
                               errorPrivacy: uads_privacyGameDisabledError];
}

- (void)test_privacy_error_doesnt_block_loader_request_but_calls_saver {
    [self runFlowWithPrivacyCodeAndValidate: 0
                          allowTrackingFlag: false
                         expectedSaverCalls: 1
                               privacyCalls: 1
                               loaderCalled: 1
                               errorPrivacy: uads_privacyRequestIsNotCreatedLoaderError];
}

- (void)runFlowWithPrivacyCodeAndValidate: (long)responseCode
                        allowTrackingFlag: (BOOL)flag
                       expectedSaverCalls: (int)saveCalled
                             privacyCalls: (int)privacyCalled
                             loaderCalled: (int)loaderCalled
                             errorPrivacy: (id<UADSError>)privacyError {
    UADSInitializationResponse *response = [UADSInitializationResponse newFromDictionary: @{
                                                @"pas": @(flag)
                                            }
        ];

    response.responseCode = responseCode;

    if (!privacyError) {
        self.privacyLoaderMock.expectedResponse = response;
    } else {
        self.privacyLoaderMock.expectedError = privacyError;
    }

    self.configLoaderMock.expectedConfig = [USRVConfiguration new];
    [self.sut loadConfigurationWithSuccess:^(USRVConfiguration *_Nonnull config) {
    }
                        andErrorCompletion:^(id<UADSError> _Nonnull error) {
                            XCTAssertEqualObjects(error.errorString, privacyError.errorString);
                        }];
    [self waitForTimeInterval: 0.1];
    XCTAssertEqual(self.storageMock.responses.count, saveCalled);
    XCTAssertEqual(self.storageMock.responses.lastObject.allowTracking, flag);
    XCTAssertEqual(self.privacyLoaderMock.loadCallCount, privacyCalled);
    XCTAssertEqual(self.configLoaderMock.loadCallCount, loaderCalled);
}

- (NSError *)privacyErrorMock {
    return [[NSError alloc] initWithDomain: @"UADSConfigurationLoaderWithPrivacyTestCase"
                                      code: 999
                                  userInfo: nil];
}

@end
