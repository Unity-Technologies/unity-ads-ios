#import <XCTest/XCTest.h>
#import "UADSGenericMediator.h"
#import "XCTestCase+Convenience.h"
#import "UADSTools.h"
#import "NSArray+Convenience.h"
@interface UADSGenericMediatorTestCase : XCTestCase

@end

@implementation UADSGenericMediatorTestCase

- (void)test_multithreading_doesnt_cause_crash_on_subscription {
    UADSGenericMediator *sut = self.sut;
    XCTestExpectation *exp = [self defaultExpectation];
    int threadCount = 1000;

    exp.expectedFulfillmentCount = threadCount;
    //subscribe from multiple threads
    [self runBlockAsync: threadCount
                  block:^{
                      [sut subscribe:^(id _Nonnull obj) {
                          [exp fulfill];
                      }];
                  }];

    // try to notify in parallel
    [self runBlockAsync: threadCount
                  block:^{
                      [sut notifyObserversWithObjectAndRemove: [NSNull new]];
                  }];

    [self waitForExpectations: @[exp]
                      timeout: 1];
}

- (void)test_synchronization_of_subscribe_and_remove_calls {
    UADSGenericMediator<NSNumber *> *sut = self.sut;
    XCTestExpectation *exp = [self defaultExpectation];
    int threadCount = 1000;

    exp.expectedFulfillmentCount = threadCount;
    __block NSArray *receivedArray = [NSArray new];
    NSArray *expectedArray = [NSArray uads_newWithRepeating: @(1)
                                                      count: threadCount];

    //subscribe from multiple threads
    [sut subscribe:^(NSNumber *_Nonnull obj) {
        receivedArray = [receivedArray arrayByAddingObject: obj];
        [exp fulfill];
    }];

    for (int i = 0; i < threadCount; i++) {
        [sut notifyObserversWithObjectAndRemove: @(1)];
        [sut subscribe:^(NSNumber *_Nonnull obj) {
            receivedArray = [receivedArray arrayByAddingObject: obj];
            [exp fulfill];
        }];
    }

    [self waitForExpectations: @[exp]
                      timeout: 5];

    XCTAssertEqual(receivedArray.count, expectedArray.count);
    XCTAssertEqualObjects(receivedArray, expectedArray);
}

- (void)test_notify_doesnt_remove_subscribers_but_notifies_them {
    UADSGenericMediator<NSNumber *> *sut = self.sut;
    XCTestExpectation *exp = [self defaultExpectation];
    int threadCount = 1000;

    exp.expectedFulfillmentCount = threadCount * 2;
    __block NSArray *receivedArray = [NSArray new];
    NSArray *expectedArray = [NSArray uads_newWithRepeating: @(1)
                                                      count: threadCount * 2];


    [self asyncExecuteTimes: threadCount
                      block:^(XCTestExpectation *_Nonnull expectation, int index) {
                          [sut subscribe:^(NSNumber *_Nonnull obj) {
                              receivedArray = [receivedArray arrayByAddingObject: obj];
                              [exp fulfill];
                          }];

                          [expectation fulfill];
                      }];

    [sut notifyObserversWithObject: @(1)];
    [sut notifyObserversWithObject: @(1)];
    [self waitForExpectations: @[exp]
                      timeout: 1];
    XCTAssertEqualObjects(receivedArray, expectedArray);
}

- (void)test_notify_only_once_and_remove_subscribers {
    UADSGenericMediator<NSNumber *> *sut = self.sut;
    XCTestExpectation *exp = [self defaultExpectation];
    int threadCount = 1000;

    exp.expectedFulfillmentCount = threadCount;
    __block NSArray *receivedArray = [NSArray new];
    NSArray *expectedArray = [NSArray uads_newWithRepeating: @(1)
                                                      count: threadCount];


    [self asyncExecuteTimes: threadCount
                      block:^(XCTestExpectation *_Nonnull expectation, int index) {
                          [sut subscribe:^(NSNumber *_Nonnull obj) {
                              receivedArray = [receivedArray arrayByAddingObject: obj];
                              [exp fulfill];
                          }];

                          [expectation fulfill];
                      }];

    [sut notifyObserversWithObjectAndRemove: @(1)];
    [sut notifyObserversWithObjectAndRemove: @(1)];

    [self waitForExpectations: @[exp]
                      timeout: 1];
    XCTAssertEqual(receivedArray.count, expectedArray.count);
    XCTAssertEqualObjects(receivedArray, expectedArray);
}

- (void)test_notifies_about_time_out_and_removes_subscriber {
    UADSGenericMediator<NSNumber *> *sut = self.sut;
    XCTestExpectation *exp = [self defaultExpectation];

    sut.timeoutInSeconds = 1;
    sut.removeOnTimeout = true;

    [sut subscribe:^(NSNumber *_Nonnull obj) {
        XCTFail(@"should go through failure part");
    }
        andTimeout:^{
         [exp fulfill];
     }];

    [self waitForExpectations: @[exp]
                      timeout: 2];
    [sut notifyObserversWithObjectAndRemove: @(1)];
    [NSThread sleepForTimeInterval: 1];
}

- (UADSGenericMediator *)sut {
    return [UADSGenericMediator new];
}

- (void)test_notifies_objects_separately_in_separate_chunks_multi_thread_protected {
    UADSGenericMediator *sut = self.sut;
    XCTestExpectation *exp = [self defaultExpectation];
    int threadCount = 1000;

    exp.expectedFulfillmentCount = threadCount;
    //subscribe from multiple threads
    [self asyncExecuteTimes: threadCount
                      block:^(XCTestExpectation *_Nonnull expectation, int index) {
                          [sut subscribe:^(NSNumber *_Nonnull obj) {
                              [exp fulfill];
                          }];

                          [expectation fulfill];
                      }];

    NSArray *array = @[@(1), @(2), @(3), @(4), @(5)];

    // try to notify in parallel
    [self runBlockAsync: threadCount / array.count
                  block:^{
                      [sut notifyObserversSeparatelyWithObjectsAndRemove: array];
                  }];

    [self waitForExpectations: @[exp]
                      timeout: 1];
    [NSThread sleepForTimeInterval: 1];
}

- (void)test_notifies_first_objects_in_batches {
    UADSGenericMediator *sut = self.sut;
    XCTestExpectation *exp = [self defaultExpectation];
    NSArray *array = @[@(1), @(2), @(3), @(4), @(5)];
    unsigned long threadCount = array.count * 2;
    __block NSArray *receivedArray = [NSArray new];

    exp.expectedFulfillmentCount = threadCount;

    for (int i = 0; i < threadCount; i++) {
        [sut subscribe:^(NSNumber *_Nonnull obj) {
            receivedArray = [receivedArray arrayByAddingObject: obj];
            [exp fulfill];
        }];
    }

    NSArray *expected = [array arrayByAddingObjectsFromArray: array];

    [sut notifyObserversSeparatelyWithObjectsAndRemove: array];
    [sut notifyObserversSeparatelyWithObjectsAndRemove: array];
    [self waitForExpectations: @[exp]
                      timeout: 2];

    XCTAssertEqual(receivedArray.count, expected.count);
    XCTAssertEqualObjects(receivedArray, expected);
}

- (void)test_notifies_first_objects_in_batches_multithread_protection {
    UADSGenericMediator *sut = self.sut;
    NSArray *array = @[@(1), @(2), @(3), @(4), @(5)];
    XCTestExpectation *exp = [self defaultExpectation];
    int threadCount = (int)array.count;

    exp.expectedFulfillmentCount = threadCount;
    __block NSArray *receivedArray = [NSArray new];


    [self asyncExecuteTimes: threadCount
                      block:^(XCTestExpectation *_Nonnull expectation, int index) {
                          [sut subscribe:^(NSNumber *_Nonnull obj) {
                              receivedArray = [receivedArray arrayByAddingObject: obj];
                              [exp fulfill];
                          }];

                          [expectation fulfill];
                      }];


    // try to notify in parallel
    [self runBlockAsync: threadCount
                  block:^{
                      [sut notifyObserversSeparatelyWithObjectsAndRemove: array];
                  }];

    [self waitForExpectations: @[exp]
                      timeout: 1];

    XCTAssertEqual(receivedArray.count, threadCount);
}

@end
