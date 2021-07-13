#import <XCTest/XCTest.h>
#import "GMAVersionReaderV7.h"
#import "GMAVersionReaderStrategy.h"
#import "GMAAdLoaderStrategy.h"
#import "GADRequestFactoryMock.h"
#import "UADSWebViewErrorHandler.h"

static NSString const *expectedVersion = @"afma-sdk-i-v7.69.0";

@interface GMAVersionReaderV7Tests : XCTestCase

@end

@implementation GMAVersionReaderV7Tests


- (void)test_class_exists {
    XCTAssertTrue([GMAVersionReaderV7 exists]);
}

- (void)test_returns_sdk_version {
    XCTAssertEqualObjects([GMAVersionReaderV7 sdkVersion], expectedVersion);
}

- (void)test_strategy_selects_proper_version {
    GMAVersionReaderStrategy *strategy = [[GMAVersionReaderStrategy alloc] init];

    XCTAssertEqualObjects([strategy sdkVersion], expectedVersion);
}

- (void)test_loader_strategy_selects_proper_version {
    GMAAdLoaderStrategy *strategy = [GMAAdLoaderStrategy newWithRequestFactory: [GADRequestFactoryMock new]
                                                            andDelegateFactory: self.delegatesFactory];

    XCTAssertEqualObjects([strategy currentVersion], expectedVersion);
}

- (id<GMADelegatesFactory>)delegatesFactory {
    id<UADSWebViewEventSender>eventSender = [UADSWebViewEventSenderBase new];

    id<UADSErrorHandler>errorHandler = [UADSWebViewErrorHandler newWithEventSender: eventSender];

    return [GMADelegatesBaseFactory newWithEventSender: eventSender
                                          errorHandler: errorHandler];
}

@end
