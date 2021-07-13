#import "GMABaseQueryInfoReader+TestCategory.h"
#import "GMAIntegrationTestsConstants.h"

@implementation GMABaseQueryInfoReader (TestCategory)
+ (GADQueryInfoBridge *)getQueryInfoSyncOfType: (GADQueryInfoAdType)type
                                   forTestCase: (XCTestCase *)testCase {
    __block GADQueryInfoBridge *returnedValue;
    XCTestExpectation *exp = [testCase expectationWithDescription: @"GADQueryInfoBridgeTestsExpectation"];
    id successHandler = ^(GADQueryInfoBridge *_Nullable info) {
        [exp fulfill];
        returnedValue = info;
    };

    id errorHandler = ^(id<UADSError> _Nonnull error) {
        XCTFail("Doesnt expect to fail");
        [exp fulfill];
    };

    GADQueryInfoBridgeCompletion *completion = [GADQueryInfoBridgeCompletion newWithSuccess: successHandler
                                                                                   andError: errorHandler];

    [GADQueryInfoBridge createQueryInfo: [GADRequestBridge getNewRequest]
                                 format: GADQueryInfoAdTypeInterstitial
                             completion: completion];
    [testCase waitForExpectations: @[exp]
                          timeout: DEFAULT_WAITING_INTERVAL];
    return returnedValue;
}

@end
