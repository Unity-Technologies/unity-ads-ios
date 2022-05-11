#import <XCTest/XCTest.h>
#import "UADSTimer.h"
#import "XCTestCase+Convenience.h"
#import "UADSAppLifeCycleNotificationCenter.h"

@interface UADSAppLifeCycleListenerTests : XCTestCase

@end

@implementation UADSAppLifeCycleListenerTests

- (void)test_calls_blocks_on_lifecycle_events {
    UADSAppLifeCycleMediator *sut = [UADSAppLifeCycleMediator new];
    XCTestExpectation *didBecomeActive = [self expectationWithDescription: @"didBecomeActive"];
    XCTestExpectation *didEnterBackground = [self expectationWithDescription: @"didEnterBackground"];
    NSString *identifier = [sut addEventsListenerWithDidBecomeActive:^{
        [didBecomeActive fulfill];
    }
                                                  didEnterBackground:^{
                                                      [didEnterBackground fulfill];
                                                  }];

    [self postDidBecomeActive];
    [self postDidEnterBackground];
    [self waitForExpectations: @[didBecomeActive, didEnterBackground]
                      timeout: 1.0];
    [sut removeListener: identifier];
    [self postDidBecomeActive];
    [self postDidEnterBackground];
}

@end
