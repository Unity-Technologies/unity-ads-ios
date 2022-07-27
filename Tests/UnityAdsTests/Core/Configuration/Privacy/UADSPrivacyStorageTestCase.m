#import <XCTest/XCTest.h>
#import "UADSPrivacyStorage.h"
#import "XCTestCase+Convenience.h"

@interface UADSPrivacyStorageTestCase : XCTestCase

@end

@implementation UADSPrivacyStorageTestCase

- (void)test_subscribe_and_notify_from_multiple_threads {
    UADSPrivacyStorage *sut = [self getSut];

    [self asyncExecuteTimes: 1000
                      block:^(XCTestExpectation *_Nonnull expectation, int index) {
                          [sut subscribe:^(UADSInitializationResponse *_Nonnull response) {}];
                          [sut saveResponse: [UADSInitializationResponse new]];
                          [expectation fulfill];
                      }];
}

- (void)test_notifies_all_the_subscribers_once_from_multiple_threads {
    UADSPrivacyStorage *sut = [self getSut];
    int testCount = 1000;
    XCTestExpectation *exp = [self defaultExpectation];

    exp.expectedFulfillmentCount = testCount;
    [self asyncExecuteTimes: testCount
                      block:  ^(XCTestExpectation *_Nonnull expectation, int index) {
                          [sut subscribe:^(UADSInitializationResponse *_Nonnull response) {
                              [exp fulfill];
                          }];
                          [expectation fulfill];
                      }];

    [self asyncExecuteTimes: testCount
                      block:^(XCTestExpectation *_Nonnull expectation, int index) {
                          [sut saveResponse: [UADSInitializationResponse new]];
                          [expectation fulfill];
                      }];

    [self waitForExpectations: @[exp]
                      timeout: 2];
}

- (UADSPrivacyStorage *)getSut {
    return [UADSPrivacyStorage new];
}

@end
