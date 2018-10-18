
#import <XCTest/XCTest.h>
#import "UPURStore.h"

@interface UPURStoreTests: XCTestCase
@end

@implementation UPURStoreTests

-(void)testNSStringFromUPURStore {
    XCTAssertEqualObjects(@"GOOGLE_PLAY", NSStringFromUPURAppStore(kUPURStoreGooglePlay));
    XCTAssertEqualObjects(@"AMAZON_APP_STORE", NSStringFromUPURAppStore(kUPURStoreAmazonAppStore));
    XCTAssertEqualObjects(@"CLOUD_MOOLAH", NSStringFromUPURAppStore(kUPURStoreCloudMoolah));
    XCTAssertEqualObjects(@"SAMSUNG_APPS", NSStringFromUPURAppStore(kUPURStoreSamsungApps));
    XCTAssertEqualObjects(@"XIAOMI_MI_PAY", NSStringFromUPURAppStore(kUPURStoreXiaomiMiPay));
    XCTAssertEqualObjects(@"MAC_APP_STORE", NSStringFromUPURAppStore(kUPURStoreMacAppStore));
    XCTAssertEqualObjects(@"APPLE_APP_STORE", NSStringFromUPURAppStore(kUPURStoreAppleAppStore));
    XCTAssertEqualObjects(@"WIN_RT", NSStringFromUPURAppStore(kUPURStoreWinRT));
    XCTAssertEqualObjects(@"TIZEN_STORE", NSStringFromUPURAppStore(kUPURStoreTizenStore));
    XCTAssertEqualObjects(@"FACEBOOK_STORE", NSStringFromUPURAppStore(kUPURStoreFacebookStore));
    XCTAssertEqualObjects(@"NOT_SPECIFIED", NSStringFromUPURAppStore(kUPURStoreNotSpecified));
}

@end
