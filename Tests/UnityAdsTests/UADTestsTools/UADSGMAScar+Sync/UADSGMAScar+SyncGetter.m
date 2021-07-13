#import "UADSGMAScar+SyncGetter.h"
#import "GMAIntegrationTestsConstants.h"

@implementation UADSGMAScar (SyncCategory)
- (void)getSignalsSyncWithErrorTest: (NSArray *)interstitialList
                    andRewardedList: (NSArray *)rewardedList
                            forTest: (XCTestCase *)testCase
                      andCompletion: (UADSSuccessCompletion)success {
    [self getSignalsSyncFor: interstitialList
            andRewardedList: rewardedList
                    forTest: testCase
              andCompletion: success
         andErrorCompletion: self.errorHandlerWithCheck];
}

- (void)getSignalsSyncWithSuccessTest: (NSArray *)interstitialList
                      andRewardedList: (NSArray *)rewardedList
                              forTest: (XCTestCase *)testCase
                   andErrorCompletion: (UADSErrorCompletion)errorCompletion {
    [self getSignalsSyncFor: interstitialList
            andRewardedList: rewardedList
                    forTest: testCase
              andCompletion: self.successHandlerWithCheck
         andErrorCompletion: errorCompletion];
}

- (void)getSignalsSyncFor: (NSArray *)interstitialList
          andRewardedList: (NSArray *)rewardedList
                  forTest: (XCTestCase *)testCase
            andCompletion: (UADSSuccessCompletion)success
       andErrorCompletion: (UADSErrorCompletion)errorCompletion {
    XCTestExpectation *exp = [testCase expectationWithDescription: @"GetSignalsExpectation"];
    id successHandler = ^(NSString *_Nullable encodedString) {
        [exp fulfill];
        success(encodedString);
    };

    id errorHandler = ^(id error) {
        [exp fulfill];
        errorCompletion(error);
    };

    UADSGMAEncodedSignalsCompletion *completion = [UADSGMAEncodedSignalsCompletion newWithSuccess: successHandler
                                                                                         andError: errorHandler];

    [self getSCARSignalsUsingInterstitialList: interstitialList
                              andRewardedList: rewardedList
                                   completion: completion];
    [testCase waitForExpectations: @[exp]
                          timeout: DEFAULT_WAITING_INTERVAL];
}

- (void)getSignalsSyncWithTestCase: (XCTestCase *)testCase
               andInterstitialList: (NSArray *)interstitialList
                   andRewardedList: (NSArray *)rewardedList {
    [self getSignalsSyncWithErrorTest: interstitialList
                      andRewardedList: rewardedList
                              forTest: testCase
                        andCompletion:^(id _Nullable obj) {
                            XCTAssertNotNil(obj);
                        }];
}

- (void)loadAdSyncWithTestCase: (XCTestCase *)testCase
                   andMetaData: (GMAAdMetaData *)meta
          andSuccessCompletion: (UADSSuccessCompletion)completion
            andErrorCompletion: (UADSErrorCompletion)errorCompletion {
    XCTestExpectation *exp = [testCase expectationWithDescription: @"LoadAdsExpectation"];
    id successHandler = ^(id _Nullable ad) {
        completion(ad);
        [exp fulfill];
    };
    id errorHandler = ^(id<UADSError> error) {
        errorCompletion(error);
        [exp fulfill];
    };

    UADSAnyCompletion *anyCompletion = [UADSAnyCompletion newWithSuccess: successHandler
                                                                andError: errorHandler];

    [self loadAdUsingMetaData: meta
                andCompletion: anyCompletion];

    [testCase waitForExpectations: @[exp]
                          timeout: DEFAULT_WAITING_INTERVAL];
}

- (void)loadSuccessSyncWithTestCase: (XCTestCase *)testCase
                        andMetaData: (GMAAdMetaData *)meta
               andSuccessCompletion: (UADSSuccessCompletion)completion {
    [self loadAdSyncWithTestCase: testCase
                     andMetaData: meta
            andSuccessCompletion: completion
              andErrorCompletion: self.errorHandlerWithCheck];
}

- (void)loadErrorSyncWithTestCase: (XCTestCase *)testCase
                      andMetaData: (GMAAdMetaData *)meta
               andErrorCompletion: (UADSErrorCompletion)completion {
    [self loadAdSyncWithTestCase: testCase
                     andMetaData: meta
            andSuccessCompletion: self.successHandlerWithCheck
              andErrorCompletion: completion];
}

- (id)errorHandlerWithCheck {
    return ^(id<UADSError> _Nonnull error) {
               XCTFail("Doesnt expect to have an error here %@", error.errorString);
    };
}

- (id)successHandlerWithCheck {
    return ^(id<UADSError> _Nonnull error) {
               XCTFail("Doesnt expect to have a success here");
    };
}

@end
