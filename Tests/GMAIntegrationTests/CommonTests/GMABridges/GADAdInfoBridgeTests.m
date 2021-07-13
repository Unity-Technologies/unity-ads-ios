#import <XCTest/XCTest.h>
#import "GADAdInfoBridge.h"
#import "GMABaseQueryInfoReader+TestCategory.h"
#import "GMAIntegrationTestsConstants.h"
@interface GADAdInfoBridgeTests : XCTestCase

@end

@implementation GADAdInfoBridgeTests

- (void)test_the_class_exists {
    XCTAssertTrue([GADAdInfoBridge exists]);
}

- (void)test_creates_ad_info_bridge {
    XCTAssertNotNil(self.bridgeToTest);
}

- (GADAdInfoBridge *)bridgeToTest {
    GADQueryInfoBridge *queryInfo = self.queryInfoBridge;
    NSString *request_id = queryInfo.sourceQueryDictionary[@"request_id"];
    //this is fragile, if GMA sdk changes the format of adString, it will affect the test
    NSString *adString = [NSString stringWithFormat: @"{\"request_id\":\"%@\"}", request_id];

    return [GADAdInfoBridge newWithQueryInfo: queryInfo
                                    adString: adString];
}

- (GADQueryInfoBridge *)queryInfoBridge {
    return [GMABaseQueryInfoReader getQueryInfoSyncOfType: GADQueryInfoAdTypeInterstitial
                                              forTestCase: self];
}

@end
