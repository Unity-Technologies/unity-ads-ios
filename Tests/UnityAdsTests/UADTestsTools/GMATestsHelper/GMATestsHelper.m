#import "GMATestsHelper.h"
#import "UADSTools.h"
#import "USRVWebViewCallbackMock.h"
#import "GMAIntegrationTestsConstants.h"
#import "UnityAds+Testability.h"
#import "NSArray+Map.h"

@implementation GMATestsHelper

- (instancetype)init {
    SUPER_INIT;
    self.webViewMock = [USRVWebViewAppMock new];
    return self;
}

- (void)install {
    [USRVWebViewApp setCurrentApp: _webViewMock];
    [_webViewMock installAllowedClasses: @[self.apiClassName]];
}

- (void)clear {
    [UnityAds resetForTest];
}

- (NSString *)apiClassName {
    return @"UADSApiGMAScar";
}

- (void)emulateIsAvailableCall: (UADSSuccessCompletion)completion {
    [self emulateCallOfMethod: @"isAvailable"
                   withParams: @[]
                 withCallback:^(NSArray *_Nullable array) {
                     completion(array[0]);
                     XCTAssertTrue(array.count == 1);
                 }];
}

- (void)emulateGetVersionCall: (UADSSuccessCompletion)completion {
    [self emulateCallOfMethod: @"getVersion"
                   withParams: @[]
                 withCallback:^(NSArray *_Nullable array) {
                     completion(array[0]);
                     XCTAssertTrue(array.count == 1);
                 }];
}

- (void)emulateGetScarSignals: (NSArray *)interstitialPlacements
           rewardedPlacements: (NSArray *)rewardedPlacements
                     testCase: (XCTestCase *)testCase
               expectedEvents: (NSArray<GMAWebViewEvent *> *)expectedEvents {
    XCTestExpectation *exp = [testCase expectationWithDescription: @"Signals Integration  test"];

    _webViewMock.expectation = exp;

    [self emulateCallOfMethod: @"getSCARSignals"
                   withParams: @[interstitialPlacements, rewardedPlacements]
                 withCallback:^(NSArray *_Nullable array) {
                 }];

    [testCase waitForExpectations: @[exp]
                          timeout: DEFAULT_WAITING_INTERVAL];

    [self validateExpectedEvents: expectedEvents];
}

- (void)emulateCallOfMethod: (NSString *)method
                 withParams: (NSArray *)params
               withCallback: (UADSSuccessCompletion)completion {
    USRVWebViewCallbackMock *callback = [USRVWebViewCallbackMock newWithCompletion: completion];


    [_webViewMock emulateInvokeWebExposedMethod: method
                                      className: self.apiClassName
                                         params: params
                                       callback: callback];
}

- (void)emulateLoadWithParams: (NSArray *)params
                     testCase: (XCTestCase *)testCase
               expectedEvents: (NSArray<GMAWebViewEvent *> *)expectedEvents; {
    XCTestExpectation *exp = [testCase expectationWithDescription: @"Signals Integration  test"];

    _webViewMock.expectation = exp;
    [self emulateCallOfMethod: @"load"
                   withParams: params
                 withCallback:^(NSArray *_Nullable array) {
                 }];
    [testCase waitForExpectations: @[exp]
                          timeout: DEFAULT_WAITING_INTERVAL];

    [self validateExpectedEvents: expectedEvents];
}

- (void)emulateShowWithParams: (NSArray *)params
                     testCase: (XCTestCase *)testCase
               expectedEvents: (NSArray<GMAWebViewEvent *> *)expectedEvents; {
    XCTestExpectation *exp = [testCase expectationWithDescription: @"Signals Integration  test"];

    _webViewMock.expectation = exp;
    [self emulateCallOfMethod: @"show"
                   withParams: params
                 withCallback:^(NSArray *_Nullable array) {
                 }];
    [testCase waitForExpectations: @[exp]
                          timeout: DEFAULT_WAITING_INTERVAL];

    [self validateExpectedEvents: expectedEvents];
}

- (void)validateExpectedEvents: (NSArray<GMAWebViewEvent *> *)expectedEvents {
    NSArray *expectedEventNames = [expectedEvents uads_mapObjectsUsingBlock: ^id _Nonnull (GMAWebViewEvent *_Nonnull obj) {
        return obj.eventName;
    }];

    NSArray *expectedCategoryNames = [expectedEvents uads_mapObjectsUsingBlock: ^id _Nonnull (GMAWebViewEvent *_Nonnull obj) {
        return obj.categoryName;
    }];

    NSArray *expectedParams = [expectedEvents uads_mapObjectsUsingBlock:^id _Nonnull (GMAWebViewEvent *_Nonnull obj) {
        return obj.params;
    }];

    XCTAssertEqualObjects(_webViewMock.eventNames, expectedEventNames);

    XCTAssertEqualObjects(_webViewMock.categoryNames, expectedCategoryNames);
    XCTAssertEqualObjects(_webViewMock.params, expectedParams);
}

@end
