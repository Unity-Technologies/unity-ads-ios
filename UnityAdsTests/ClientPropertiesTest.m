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
}

- (void)testGetSupportedOrientations {
    NSNumber *numberOfSupportedOrientations = [NSNumber numberWithUnsignedLong:[[UADSClientProperties getSupportedOrientationsPlist] count]];
    XCTAssertTrue([numberOfSupportedOrientations isEqualToNumber:[NSNumber numberWithInt:4]], "App should support all orientations");
}

- (void)testGetAppName {
    XCTAssertEqualObjects([UADSClientProperties getAppName], @"com.unity3d.ads.example", "App name should be eqaul to 'com.unity3d.ads.example");
}

- (void)testGetAppVersion {
    XCTAssertEqualObjects([UADSClientProperties getAppVersion], @"1.0", "App version not what was expected (1.0)");
}

- (void)testSetCurrentViewController {
    UIViewController *controller = [[UIViewController alloc] init];
    [UADSClientProperties setCurrentViewController:controller];
    
    XCTAssertEqualObjects(controller, [UADSClientProperties getCurrentViewController]);
    
}

- (void)testSetDelegate {
    [UADSClientProperties setDelegate:self];
    XCTAssertEqualObjects(self, [UADSClientProperties getDelegate]);
    
}

- (void)testIsAppDebuggable {
    XCTAssertTrue([UADSClientProperties isAppDebuggable], "App should be debuggable");
}

- (void)testSetGameId {
    [UADSClientProperties setGameId:@"54321"];
    XCTAssertEqualObjects([UADSClientProperties getGameId], @"54321");
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
