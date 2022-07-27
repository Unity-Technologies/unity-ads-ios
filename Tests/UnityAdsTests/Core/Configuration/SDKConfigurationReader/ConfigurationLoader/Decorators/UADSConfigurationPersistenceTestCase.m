#import <XCTest/XCTest.h>
#import "UADSConfigurationLoaderWithPersistence.h"
#import "UADSConfigurationPersistenceMock.h"
#import "UADSConfigurationLoaderMock.h"
#import "NSError+UADSError.h"
#import "XCTestCase+Convenience.h"

@interface UADSConfigurationPersistenceTestCase : XCTestCase
@property (strong, nonatomic) UADSConfigurationPersistenceMock *saverMock;
@property (strong, nonatomic) UADSConfigurationLoaderMock *loaderMock;
@end

@implementation UADSConfigurationPersistenceTestCase

- (void)setUp {
    _saverMock = [UADSConfigurationPersistenceMock new];
    _loaderMock = [UADSConfigurationLoaderMock new];
}

- (void)test_error_trigger_saver_with_empty_config {
    _loaderMock.expectedError = uads_invalidWebViewURLLoaderError;
    XCTestExpectation *exp = self.defaultExpectation;
    id errorCompletion = ^(id error) {
        [exp fulfill];
    };

    id successCompletion = ^(id obj) {
        XCTFail(@"Should not succeed");
        [exp fulfill];
    };

    [self.sut loadConfigurationWithSuccess: successCompletion
                        andErrorCompletion: errorCompletion];

    [self waitForExpectations: @[exp]
                      timeout: 1];

    USRVConfiguration *received = self.saverMock.receivedConfig.lastObject;

    XCTAssertEqual(received.hasValidWebViewURL, false);
}

- (void)test_saves_config_on_success {
    _loaderMock.expectedConfig = [USRVConfiguration newFromJSON: @{}];
    XCTestExpectation *exp = self.defaultExpectation;
    id errorCompletion = ^(id error) {
        XCTFail(@"Should not succeed");
        [exp fulfill];
    };

    id successCompletion = ^(id obj) {
        XCTAssertEqual(self.saverMock.receivedConfig.count, 1);
        [exp fulfill];
    };

    [self.sut loadConfigurationWithSuccess: successCompletion
                        andErrorCompletion: errorCompletion];

    [self waitForExpectations: @[exp]
                      timeout: 1];
}

- (id<UADSConfigurationLoader>)sut {
    return [UADSConfigurationLoaderWithPersistence newWithOriginal: _loaderMock
                                                          andSaver: _saverMock];
}

@end
