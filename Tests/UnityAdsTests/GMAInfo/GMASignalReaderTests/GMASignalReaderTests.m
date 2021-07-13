#import "GMAQueryInfoReaderMock.h"
#import "GMAQuerySignalReader.h"
#import "UADSDefaultError.h"
#import "NSError+UADSError.h"
#import <XCTest/XCTest.h>
#import "XCTestAssert+Fail.h"
#import "XCTestCase+Convenience.h"
#import "GMATestCommonConstants.h"

typedef NSArray<GADQueryInfoBridge *> QueryList;
typedef void (^SignalCondition)(NSString *);

static NSString *const kFakeRequestID = @"FAKE_REQUEST_ID";
static NSString *const kFakeQuery = @"FAKE_QUERY";
#define FAKE_AD_JSON @{ @"request_id": kFakeRequestID }
#define FAKE_ERROR   [UADSDefaultError newWithString: @"UADSDefaultError"]

@interface GMASignalReaderTests : XCTestCase
@property (nonatomic, strong) GMAQueryInfoReaderMock *mock;
@property (nonatomic, strong) id<GMASignalService> readerToTest;
@end

@implementation GMASignalReaderTests

- (void)setUp {
    _mock = [[GMAQueryInfoReaderMock alloc] init];
    _readerToTest = [self createUsingMock: _mock];
}

- (void)test_should_call_rewarded_ad_signal {
    [self launch_success_test_for_ad_type: GADQueryInfoAdTypeRewarded
                         conditionSuccess: ^void (NSString *signal) {
                             XCTAssertEqual([self.mock numberOfCallsForType: GADQueryInfoAdTypeRewarded], 1);
                         }];
}

- (void)test_should_not_call_interstitial_ad {
    [self launch_success_test_for_ad_type: GADQueryInfoAdTypeRewarded
                         conditionSuccess: ^void (NSString *signal) {
                             XCTAssertEqual([self.mock numberOfCallsForType: GADQueryInfoAdTypeInterstitial], 0);
                         }];
}

- (void)test_should_call_interstitial_ad_signal {
    [self launch_success_test_for_ad_type: GADQueryInfoAdTypeInterstitial
                         conditionSuccess: ^void (NSString *signal) {
                             XCTAssertEqual([self.mock numberOfCallsForType: GADQueryInfoAdTypeInterstitial], 1);
                         }];
}

- (void)test_should_not_call_rewarded_ad {
    [self launch_success_test_for_ad_type: GADQueryInfoAdTypeInterstitial
                         conditionSuccess: ^void (NSString *signal) {
                             XCTAssertEqual([self.mock numberOfCallsForType: GADQueryInfoAdTypeRewarded], 0);
                         }];
}

- (void)test_calls_signal_reader_to_get_rewarded_ad {
    [self launch_success_test_for_ad_type: GADQueryInfoAdTypeRewarded
                         conditionSuccess: ^void (NSString *signal) {
                             XCTAssertEqualObjects(signal, kFakeQuery);
                         }];
}

- (void)test_calls_signal_reader_to_get_interstitial_ad {
    [self launch_success_test_for_ad_type: GADQueryInfoAdTypeInterstitial
                         conditionSuccess: ^void (NSString *signal) {
                             XCTAssertEqualObjects(signal, kFakeQuery);
                         }];
}

- (void)test_returns_error_if_reader_fails_for_rewarded {
    [self launch_test_for_error_flowAdType: GADQueryInfoAdTypeRewarded
                             returnedError: FAKE_ERROR
                            errorCondition: ^(id<UADSError> error) {
                                XCTAssertEqualObjects(error.errorString,  FAKE_ERROR.errorString);
                            }];
}

- (void)test_returns_error_if_reader_fails_for_interstitial {
    [self launch_test_for_error_flowAdType: GADQueryInfoAdTypeInterstitial
                             returnedError: FAKE_ERROR
                            errorCondition: ^(id<UADSError> error) {
                                XCTAssertEqualObjects(error.errorString,  FAKE_ERROR.errorString);
                            }];
}

- (void)test_saves_rewarded_query_into_storage {
    [self launch_success_test_for_ad_type: GADQueryInfoAdTypeRewarded
                         conditionSuccess: ^void (NSString *signal) {
                             GADQueryInfoBridge *info = [self.readerToTest queryForPlacementID: kFakePlacementID];
                             XCTAssertEqualObjects(signal, info.query);
                         }];
}

- (void)test_saves_interstetial_query_into_storage {
    [self launch_success_test_for_ad_type: GADQueryInfoAdTypeInterstitial
                         conditionSuccess: ^void (NSString *signal) {
                             GADQueryInfoBridge *info = [self.readerToTest queryForPlacementID: kFakePlacementID];
                             XCTAssertEqualObjects(signal, info.query);
                         }];
}

#warning the test requires GMA SDK to be installed.
//-(void)test_creates_proper_request_for_rewarded_ad {
//
//    [self launch_success_test_forAdType: GADQueryInfoAdTypeRewarded
//                       conditionSuccess: ^void(NSString * signal) {
//        GADRequestBridge *request = [self.readerToTest getAdRequestFor: FAKE_PLACEMENT_ID
//                                                         usingAdString: self.fakeAdIDString
//                                                                 error: nil];
//
//        NSString *query = [[((id)request.adInfo) valueForKey: @"queryInfo"] valueForKey: @"query"];
//        XCTAssertEqualObjects(signal, query);
//    }];
//}

- (void)test_returns_error_if_request_cannot_be_created {
    XCTestExpectation *expectation = self.defaultExpectation;

    GMAAdMetaData *meta = [GMAAdMetaData new];

    meta.placementID = kFakePlacementID;
    meta.adString = self.fakeAdIDString;
    [self emulateReaderCallForAdType: GADQueryInfoAdTypeRewarded
                     withExpectation: expectation
                    conditionSuccess: ^(NSString *signal) {
                        NSError *error;
                        [self.readerToTest getAdRequestFor: meta
                                                     error: &error];
                        XCTAssertNotNil(error);
                    }
                      errorCondition: self.failIfError];
    [_mock callSuccessWithQuery: self.brokenQuery
                      forAdType: GADQueryInfoAdTypeRewarded];
    [self waitForExpectations: @[expectation]
                      timeout: 5];
}

- (void)test_returns_error_for_query_not_found {
    NSError *error;
    GMAAdMetaData *meta = [GMAAdMetaData new];

    meta.placementID = @"NON_EXIST";
    meta.adString = @"DOESNT MATTER";
    [self.readerToTest getAdRequestFor: meta
                                 error: &error];
    XCTAssertNotNil(error);
}

- (void)launch_success_test_for_ad_type: (GADQueryInfoAdType)type
                       conditionSuccess: (SignalCondition)condition {
    XCTestExpectation *expectation = self.defaultExpectation;

    [self emulateReaderCallForAdType: type
                     withExpectation: expectation
                    conditionSuccess: condition
                      errorCondition: self.failIfError];

    [_mock callSuccessWithQuery: self.defaultQuery
                      forAdType: type];

    [self waitForExpectations: @[expectation]
                      timeout: 5];
}

- (void)launch_test_for_error_flowAdType: (GADQueryInfoAdType)type
                           returnedError: (id<UADSError>)error
                          errorCondition: (ErrorCompletion)errorCondition  {
    XCTestExpectation *expectation = self.defaultExpectation;

    [self emulateReaderCallForAdType: type
                     withExpectation: expectation
                    conditionSuccess: self.failIfSuccess
                      errorCondition: errorCondition];

    [_mock callErrorWith: error
               forAdType: type];

    [self waitForExpectations: @[expectation]
                      timeout: 5];
}

- (void)emulateReaderCallForAdType: (GADQueryInfoAdType)type
                   withExpectation: (XCTestExpectation *)expectation
                  conditionSuccess: (SignalCondition)condition
                    errorCondition: (ErrorCompletion)errorCondition {
    UADSGMASCARCompletion *completion = [UADSGMASCARCompletion newWithSuccess: ^(NSString *_Nullable signal) {
        condition(signal);
        [expectation fulfill];
    }
                                                                     andError: ^(id<UADSError> error) {
                                                                         errorCondition(error);
                                                                         [expectation fulfill];
                                                                     }];

    [_readerToTest getSignalOfAdType: type
                      forPlacementId: kFakePlacementID
                          completion: completion];
}

//MARK: - HELPERS

- (SignalCondition)failIfSuccess {
    return ^(NSString *str) {
               XCTFail(@"Should not fall into success flow");
    };
}

- (id<GMASignalService>)createUsingMock: (GMAQueryInfoReaderMock *)mock {
    return [GMABaseQuerySignalReader newWithInfoReader: mock];
}

- (GADQueryInfoBridge *)defaultQuery {
    NSDictionary *mockObject = @{
        @"requestIdentifier": kFakeRequestID,
        @"request_id": kFakeRequestID,
        @"query": kFakeQuery
    };

    return [[GADQueryInfoBridge alloc] initWithProxyObject: mockObject];
}

- (GADQueryInfoBridge *)brokenQuery {
    NSDictionary *mockObject = @{
        @"requestIdentifier": @"NON_MATCHING",
        @"request_id": @"NON_MATCHING",
        @"query": @"NON_MATCHING"
    };

    return [[GADQueryInfoBridge alloc] initWithProxyObject: mockObject];
}

- (NSString *)fakeAdIDString {
    NSData *addStringAsData = [NSJSONSerialization dataWithJSONObject: FAKE_AD_JSON
                                                              options: 1UL << 2 //  CI fails for some reason if use  NSJSONWritingFragmentsAllowed
                                                                error: nil];

    return [[NSString alloc] initWithData: addStringAsData
                                 encoding: NSUTF8StringEncoding];
}

@end
