#import <XCTest/XCTest.h>
#import "UADSPrivacyLoader.h"
#import "USRVConfigurationRequestFactoryMock.h"
#import "XCTestCase+Convenience.h"
@interface UADSPrivacyLoaderTests : XCTestCase

@end

@implementation UADSPrivacyLoaderTests

- (void)test_if_loader_uses_proper_factory_request_type {
    USRVConfigurationRequestFactoryMock *factory = [USRVConfigurationRequestFactoryMock new];
    UADSPrivacyLoaderBase *sut = [UADSPrivacyLoaderBase newWithFactory: factory];
    XCTestExpectation *exp = [self defaultExpectation];
    id successCheck = ^(id obj) {
        [exp fulfill];
    };

    id errorCheck = ^(id<UADSError> _Nonnull error) {
        [exp fulfill];
    };

    [sut loadPrivacyWithSuccess: successCheck
             andErrorCompletion: errorCheck];

    [self waitForExpectations: @[exp]
                      timeout: 1];

    XCTAssertEqualObjects(factory.requestedTypes, @[@(USRVInitializationRequestTypePrivacy)]);
}

@end
