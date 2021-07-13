#import <XCTest/XCTest.h>
#import "SKAdImpressionProxy.h"
#import <StoreKit/StoreKit.h>


static NSString const *kJSONStringForTesting = @"{\"version\": \"version\",\"signature\": \"signature\",\"adNetworkIdentifier\": \"adNetworkIdentifier\",\"adCampaignIdentifier\": 1,\"advertisedAppStoreItemIdentifier\": 1,\"adImpressionIdentifier\": \"adImpressionIdentifier\",\"sourceAppStoreItemIdentifier\": 1,\"timestamp\": 0,\"adType\": \"adType\",\"adDescription\": \"adDescription\",\"adPurchaserName\": \"adPurchaserName\"}";


#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 140500
@interface SKAdImpressionReflectionTests : XCTestCase

@end

@implementation SKAdImpressionReflectionTests


- (void)test_reflection_maps_properly_from_a_json  API_AVAILABLE(ios(14.5)) {
    SKAdImpression *impressionToTest = self.proxiedObject;

    XCTAssertEqualObjects(impressionToTest.version, @"version");
    XCTAssertEqualObjects(impressionToTest.signature, @"signature");
    XCTAssertEqualObjects(impressionToTest.adNetworkIdentifier, @"adNetworkIdentifier");
    XCTAssertEqualObjects(impressionToTest.adCampaignIdentifier, @1);
    XCTAssertEqualObjects(impressionToTest.advertisedAppStoreItemIdentifier, @1);
    XCTAssertEqualObjects(impressionToTest.adImpressionIdentifier, @"adImpressionIdentifier");
    XCTAssertEqualObjects(impressionToTest.sourceAppStoreItemIdentifier, @1);
    XCTAssertEqualObjects(impressionToTest.timestamp, @0);
    XCTAssertEqualObjects(impressionToTest.adType, @"adType");
    XCTAssertEqualObjects(impressionToTest.adDescription, @"adDescription");
    XCTAssertEqualObjects(impressionToTest.adPurchaserName, @"adPurchaserName");
}

- (SKAdImpression *)proxiedObject  API_AVAILABLE(ios(14.5)) {
    return (SKAdImpression *)self.objectForTesting.proxyObject;
}

- (SKAdImpressionProxy *)objectForTesting {
    return [SKAdImpressionProxy newFromJSON: self.dictionaryForTesting];
}

- (NSDictionary *)dictionaryForTesting {
    return [NSJSONSerialization JSONObjectWithData: self.dataForTesting
                                           options: NSJSONReadingAllowFragments
                                             error: nil];
}

- (NSData *)dataForTesting {
    return [kJSONStringForTesting dataUsingEncoding: NSUTF8StringEncoding];
}

@end
#endif /* if __IPHONE_OS_VERSION_MIN_REQUIRED >= 140500 */
