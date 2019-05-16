#import <XCTest/XCTest.h>
#import "UnityAnalyticsAcquisitionType.h"

@interface UnityAnalyticsAcquisitionTypeTests : XCTestCase
@end

@implementation UnityAnalyticsAcquisitionTypeTests

-(void)testNSStringFromUnityAnalyticsAcquisitionType {
    XCTAssertEqualObjects(@"premium", NSStringFromUnityAnalyticsAcquisitionType(kUnityAnalyticsAcquisitionTypePremium));
    XCTAssertEqualObjects(@"soft", NSStringFromUnityAnalyticsAcquisitionType(kUnityAnalyticsAcquisitionTypeSoft));
    XCTAssertEqualObjects(@"", NSStringFromUnityAnalyticsAcquisitionType(kUnityAnalyticsAcquisitionTypeUnset));
}

@end
