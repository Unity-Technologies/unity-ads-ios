#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface ClientPropertiesTest : XCTestCase <UnityAdsDelegate>
@end

@implementation ClientPropertiesTest

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    [super tearDown];
    [UADSProperties removeDelegate:self];
}

- (void)testGetSupportedOrientations {
    NSNumber *numberOfSupportedOrientations = [NSNumber numberWithUnsignedLong:[[USRVClientProperties getSupportedOrientationsPlist] count]];
    XCTAssertTrue([numberOfSupportedOrientations isEqualToNumber:[NSNumber numberWithInt:4]], "App should support all orientations");
}

- (void)testGetAppName {
    XCTAssertEqualObjects([USRVClientProperties getAppName], @"com.unity3d.ads.exampleapp", "App name should be eqaul to 'com.unity3d.ads.exampleapp");
}

- (void)testGetAppVersion {
    XCTAssertEqualObjects([USRVClientProperties getAppVersion], @"1.0", "App version not what was expected (1.0)");
}

- (void)testSetCurrentViewController {
    UIViewController *controller = [[UIViewController alloc] init];
    [USRVClientProperties setCurrentViewController:controller];
    
    XCTAssertEqualObjects(controller, [USRVClientProperties getCurrentViewController]);
    
}

- (void)testAddDelegate {
    [UADSProperties addDelegate:self];
    XCTAssertTrue([[UADSProperties getDelegates] containsObject:self]);
}

- (void)testIsAppDebuggable {
    XCTAssertFalse([USRVClientProperties isAppDebuggable], "App should not be debuggable");
}

- (void)testSetGameId {
    [USRVClientProperties setGameId:@"54321"];
    XCTAssertEqualObjects([USRVClientProperties getGameId], @"54321");
}

- (void)testGetAdNetworkIds {
    NSArray* ids = [USRVClientProperties getAdNetworkIdsPlist];
    NSArray* expected = @[@"4DZT52R2T5.skadnetwork", @"example.skadnetwork"];

    XCTAssertTrue([expected isEqualToArray:ids], @"Both arrays should be equal: %@ %@", ids, expected);
}

/* TEST DELEGATE */

- (void)unityAdsReady:(NSString *)placementId {
    
}

- (void)unityAdsDidStart:(NSString *)placementId {
    
}

- (void)unityAdsDidError:(UnityAdsError)error withMessage:(NSString *)message {
    
}

- (void)unityAdsDidFinish:(NSString *)placementId withFinishState:(UnityAdsFinishState)state {
    
}

@end
