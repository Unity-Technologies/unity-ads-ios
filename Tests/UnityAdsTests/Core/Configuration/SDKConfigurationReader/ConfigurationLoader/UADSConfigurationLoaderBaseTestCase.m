#import "UADSConfigurationLoader.h"
#import "USRVConfigurationRequestFactoryMock.h"
#import <XCTest/XCTest.h>
#import "XCTestCase+Convenience.h"

@interface UADSConfigurationLoaderBaseTestCase : XCTestCase

@end

@implementation UADSConfigurationLoaderBaseTestCase

- (void)test_if_request_is_not_created_loader_returns_error {
    USRVConfigurationRequestFactoryMock *factory = [USRVConfigurationRequestFactoryMock new];
    UADSConfigurationLoaderBase *sut = [UADSConfigurationLoaderBase newWithFactory: factory];
    XCTestExpectation *exp = [self defaultExpectation];
    id successCheck = ^(id obj) {
        XCTFail(@"Should not call success");
        [exp fulfill];
    };

    id errorCheck = ^(id<UADSError> _Nonnull error) {
        XCTAssertEqualObjects(error.errorDomain, kConfigurationLoaderErrorDomain);
        XCTAssertEqual(error.errorCode.integerValue, kUADSConfigurationLoaderRequestIsNotCreated);
        [exp fulfill];
    };

    [sut loadConfigurationWithSuccess: successCheck
                   andErrorCompletion: errorCheck];
    [self waitForExpectations: @[exp]
                      timeout: 1];
}

- (void)test_if_parsing_fails_should_return_parsing_error {
    UADSConfigurationLoaderBase *sut = [self sutForExpectedPayload: nil
                                               invalidResponseCode: false];
    XCTestExpectation *exp = [self defaultExpectation];
    id successCheck = ^(id obj) {
        XCTFail(@"Should not call success");
        [exp fulfill];
    };

    id errorCheck = ^(id<UADSError> _Nonnull error) {
        XCTAssertEqualObjects(error.errorDomain, kConfigurationLoaderErrorDomain);
        XCTAssertEqual(error.errorCode.integerValue, kUADSConfigurationLoaderParsingError);
        [exp fulfill];
    };

    [sut loadConfigurationWithSuccess: successCheck
                   andErrorCompletion: errorCheck];
    [self waitForExpectations: @[exp]
                      timeout: 1];
}

- (void)test_if_web_url_is_not_present_should_return_invalid_url {
    UADSConfigurationLoaderBase *sut = [self sutForExpectedPayload: @{
                                            @"key1": @"value1"
                                        }
                                               invalidResponseCode: false];
    XCTestExpectation *exp = [self defaultExpectation];
    id successCheck = ^(id obj) {
        XCTFail(@"Should not call success");
        [exp fulfill];
    };

    id errorCheck = ^(id<UADSError> _Nonnull error) {
        XCTAssertEqualObjects(error.errorDomain, kConfigurationLoaderErrorDomain);
        XCTAssertEqual(error.errorCode.integerValue, kUADSConfigurationLoaderInvalidWebViewURL);
        [exp fulfill];
    };

    [sut loadConfigurationWithSuccess: successCheck
                   andErrorCompletion: errorCheck];
    [self waitForExpectations: @[exp]
                      timeout: 1];
}

- (void)test_backend_error_should_return_invalid_code {
    UADSConfigurationLoaderBase *sut = [self sutForExpectedPayload: @{
                                            @"key1": @"value1"
                                        }
                                               invalidResponseCode: true];
    XCTestExpectation *exp = [self defaultExpectation];
    id successCheck = ^(id obj) {
        XCTFail(@"Should not call success");
        [exp fulfill];
    };

    id errorCheck = ^(id<UADSError> _Nonnull error) {
        XCTAssertEqualObjects(error.errorDomain, kConfigurationLoaderErrorDomain);
        XCTAssertEqual(error.errorCode.integerValue, kUADSConfigurationLoaderInvalidResponseCode);
        [exp fulfill];
    };

    [sut loadConfigurationWithSuccess: successCheck
                   andErrorCompletion: errorCheck];
    [self waitForExpectations: @[exp]
                      timeout: 1];
}

- (void)test_if_network_error_should_return_error {
    USRVConfigurationRequestFactoryMock *factory = [USRVConfigurationRequestFactoryMock newFactoryWithExpectedNSDictionaryInRequest: @{}
                                                                                                                invalidResponseCode: false];
    UADSConfigurationLoaderBase *sut = [UADSConfigurationLoaderBase newWithFactory: factory];

    factory.expectedRequest.error = [NSError errorWithDomain: @"network"
                                                        code: 500
                                                    userInfo: nil];
    XCTestExpectation *exp = [self defaultExpectation];
    id successCheck = ^(id obj) {
        XCTFail(@"Should not call success");
        [exp fulfill];
    };

    id errorCheck = ^(id<UADSError> _Nonnull error) {
        XCTAssertEqualObjects(error, factory.expectedRequest.error);
        [exp fulfill];
    };

    [sut loadConfigurationWithSuccess: successCheck
                   andErrorCompletion: errorCheck];
    [self waitForExpectations: @[exp]
                      timeout: 1];
}

- (void)test_should_call_success_for_valid_config_with_web_url {
    NSString *fakeURLValue = @"url";
    UADSConfigurationLoaderBase *sut = [self sutForExpectedPayload: @{
                                            kUnityServicesConfigValueUrl: fakeURLValue
                                        }
                                               invalidResponseCode: false];
    XCTestExpectation *exp = [self defaultExpectation];
    id successCheck = ^(USRVConfiguration *config) {
        XCTAssertEqualObjects(config.webViewUrl, fakeURLValue);
        XCTAssertEqual(config.hasValidWebViewURL, true);
        [exp fulfill];
    };

    id errorCheck = ^(id<UADSError> _Nonnull error) {
        XCTFail(@"Should not fail");
        [exp fulfill];
    };

    [sut loadConfigurationWithSuccess: successCheck
                   andErrorCompletion: errorCheck];
    [self waitForExpectations: @[exp]
                      timeout: 1];
}

- (id<UADSConfigurationLoader>)sutForExpectedPayload: (NSDictionary *)json invalidResponseCode: (BOOL)responseCode {
    USRVConfigurationRequestFactoryMock *factory = [USRVConfigurationRequestFactoryMock newFactoryWithExpectedNSDictionaryInRequest: json
                                                                                                                invalidResponseCode: responseCode];

    return [UADSConfigurationLoaderBase newWithFactory: factory];
}

@end
