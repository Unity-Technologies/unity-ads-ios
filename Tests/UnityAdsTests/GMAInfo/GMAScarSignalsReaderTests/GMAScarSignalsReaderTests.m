#import "GMASCARSignalsReader.h"
#import "GMAQuerySignalReader.h"
#import "GMASignalServiceMock.h"
#import "UADSDefaultError.h"
#import <XCTest/XCTest.h>
#import "XCTestAssert+Fail.h"
#import "XCTestCase+Convenience.h"

#define FAKE_REWARDED_PLACEMENT     @"FAKE_REWARDED_PLACEMENT"
#define FAKE_INTERSTITIAL_PLACEMENT @"FAKE_INTERSTITIAL_PLACEMENT"
#define FAKE_REWARDED_SIGNAL        @"FAKE_REWARDED_SIGNAL"
#define FAKE_INTERSTITIAL_SIGNAL    @"FAKE_INTERSTITIAL_SIGNAL"

typedef void (^SuccessCompletion)(UADSSCARSignals *);
@interface GMAScarSignalsReaderTests : XCTestCase
@property (nonatomic, strong) GMASignalServiceMock *mock;
@property (nonatomic, strong) id<GMASCARSignalService> readerToTest;
@end

@implementation GMAScarSignalsReaderTests

- (void)setUp {
    _mock = [[GMASignalServiceMock alloc] init];
    _readerToTest = [self createUsingMock: _mock];
}

- (void)test_calls_signal_reader_for_rewarded_list {
    [self launch_success_flow_test_with_interstitialList: @[]
                                         andRewardedList: @[FAKE_REWARDED_PLACEMENT]
                                        conditionSuccess: ^(UADSSCARSignals *signals) {
                                            XCTAssertEqual([self.mock numberOfCallsForType: GADQueryInfoAdTypeRewarded], 1);
                                        }];
}

- (void)test_should_not_call_signal_reader_for_interstitial {
    [self launch_success_flow_test_with_interstitialList: @[]
                                         andRewardedList: @[FAKE_REWARDED_PLACEMENT]
                                        conditionSuccess: ^(UADSSCARSignals *signals) {
                                            XCTAssertEqual([self.mock numberOfCallsForType: GADQueryInfoAdTypeInterstitial], 0);
                                        }];
}

- (void)test_when_both_lists_are_empty_return_empty_dictionary {
    [self launch_success_flow_test_with_interstitialList: @[]
                                         andRewardedList: @[]
                                        conditionSuccess: ^(UADSSCARSignals *signals) {
                                            XCTAssertTrue(signals.allKeys.count == 0);
                                            XCTAssertEqual([self.mock numberOfCallsForType: GADQueryInfoAdTypeInterstitial], 0);
                                            XCTAssertEqual([self.mock numberOfCallsForType: GADQueryInfoAdTypeRewarded], 0);
                                        }];
}

- (void)test_calls_signal_reader_for_interstitial_list {
    [self launch_success_flow_test_with_interstitialList: @[FAKE_INTERSTITIAL_PLACEMENT]
                                         andRewardedList: @[]
                                        conditionSuccess: ^(UADSSCARSignals *signals) {
                                            XCTAssertEqual([self.mock numberOfCallsForType: GADQueryInfoAdTypeInterstitial], 1);
                                        }];
}

- (void)test_should_not_call_signal_reader_for_rewarded {
    [self launch_success_flow_test_with_interstitialList: @[FAKE_INTERSTITIAL_PLACEMENT]
                                         andRewardedList: @[]
                                        conditionSuccess: ^(UADSSCARSignals *signals) {
                                            XCTAssertEqual([self.mock numberOfCallsForType: GADQueryInfoAdTypeRewarded], 0);
                                        }];
}

- (void)test_should_return_proper_signals {
    [self launch_success_flow_test_with_interstitialList: @[FAKE_INTERSTITIAL_PLACEMENT]
                                         andRewardedList: @[FAKE_REWARDED_PLACEMENT]
                                        conditionSuccess: ^(UADSSCARSignals *signals) {
                                            XCTAssertEqualObjects([signals valueForKey: FAKE_INTERSTITIAL_PLACEMENT], FAKE_INTERSTITIAL_SIGNAL);
                                            XCTAssertEqualObjects([signals valueForKey: FAKE_REWARDED_PLACEMENT], FAKE_REWARDED_SIGNAL);
                                            XCTAssertEqual(signals.count, 2);
                                        }];
}

- (void)test_should_return_error_if_there_is_no_signal_map {
    [self launch_test_with_interstitial_list: @[FAKE_INTERSTITIAL_PLACEMENT]
                             andRewardedList: @[]
                                       error: [UADSDefaultError newWithString: @"error"]
                                 callSuccess: false
                              conditionError: ^(id<UADSError> _Nonnull error) {
                                  XCTAssertEqualObjects(error.errorString, @"error");
                              }
                            conditionSuccess: self.failIfSuccess];
}

- (void)test_should_call_success_if_map_is_not_empty_even_if_error_is_present {
    [self launch_test_with_interstitial_list: @[]
                             andRewardedList: @[FAKE_REWARDED_PLACEMENT]
                                       error: [UADSDefaultError newWithString: @"error"]
                                 callSuccess: true
                              conditionError: self.failIfError
                            conditionSuccess: ^(UADSSCARSignals *signals) {
                                XCTAssertEqualObjects([signals valueForKey: FAKE_REWARDED_PLACEMENT], FAKE_REWARDED_SIGNAL);
                                XCTAssertEqual(signals.count, 1);
                            }];
}

//MARK: - HELPER METHODS

- (SuccessCompletion)failIfSuccess {
    return ^(UADSSCARSignals *signals) {
               XCTFail(@"Should not fall through success branch");
    };
}

- (void)launch_success_flow_test_with_interstitialList: (NSArray *)interstitialList
                                       andRewardedList: (NSArray *)rewardedList
                                      conditionSuccess: (SuccessCompletion)condition  {
    [self launch_test_with_interstitial_list: interstitialList
                             andRewardedList: rewardedList
                                       error: nil
                                 callSuccess: true
                              conditionError: self.failIfError
                            conditionSuccess: condition];
}

- (void)launch_test_with_interstitial_list: (NSArray *)interstitialList
                           andRewardedList: (NSArray *)rewardedList
                                     error: (id<UADSError>)error
                               callSuccess: (bool)shouldCallSuccess
                            conditionError: (ErrorCompletion)errorCompletion
                          conditionSuccess: (SuccessCompletion)condition {
    XCTestExpectation *expectation = self.defaultExpectation;

    [self emulate_reader_call_with_interstitial_list: interstitialList
                                     andRewardedList: rewardedList
                                     withExpectation: expectation
                                    conditionSuccess: condition
                                      errorCondition: errorCompletion];

    if (error) {
        [_mock callErrorForType: GADQueryInfoAdTypeInterstitial
                 forPlacementId: FAKE_INTERSTITIAL_PLACEMENT
                          error: error];
    }

    if (shouldCallSuccess) {
        for (NSString *placementID in interstitialList) {
            [_mock callSuccessForType: GADQueryInfoAdTypeInterstitial
                       forPlacementId: placementID
                               signal: FAKE_INTERSTITIAL_SIGNAL];
        }

        for (NSString *placementID in rewardedList) {
            [_mock callSuccessForType: GADQueryInfoAdTypeRewarded
                       forPlacementId: placementID
                               signal: FAKE_REWARDED_SIGNAL];
        }
    }

    [self waitForExpectations: @[expectation]
                      timeout: 5];
}

- (void)emulate_reader_call_with_interstitial_list: (NSArray *)interstitialList
                                   andRewardedList: (NSArray *)rewardedList
                                   withExpectation: (XCTestExpectation *)expectation
                                  conditionSuccess: (SuccessCompletion)condition
                                    errorCondition: (ErrorCompletion)errorCondition {
    UADSGMAScarSignalsCompletion *completion = [UADSGMAScarSignalsCompletion newWithSuccess: ^(UADSSCARSignals *_Nullable signal) {
        condition(signal);
        [expectation fulfill];
    }
                                                                                   andError: ^(id<UADSError> error) {
                                                                                       errorCondition(error);
                                                                                       [expectation fulfill];
                                                                                   }];

    [_readerToTest getSCARSignalsUsingInterstitialList: interstitialList
                                       andRewardedList: rewardedList
                                            completion: completion];
}

- (id<GMASCARSignalService>)createUsingMock: (GMASignalServiceMock *)mock {
    return [GMABaseSCARSignalsReader newWithSignalService: mock];
}

@end
