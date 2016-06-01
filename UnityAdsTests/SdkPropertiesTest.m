#import <XCTest/XCTest.h>

#import "UnityAdsTests-Bridging-Header.h"

@interface SdkPropertiesTest : XCTestCase

@end

@implementation SdkPropertiesTest

- (void)setUp {
    [super setUp];
    [UnityAds resetForTest];
}

- (void)tearDown {
    [super tearDown];
    [UnityAds resetForTest];
}

- (void)testSetInitialized {
    XCTAssertFalse([UADSSdkProperties isInitialized], @"SDK shouldn't be initialized");
    
    [UADSSdkProperties setInitialized:YES];
    
    XCTAssertTrue([UADSSdkProperties isInitialized], @"Method isInitialized should have returned true");
     
}

- (void)testSetTestMode {
    [UADSSdkProperties setTestMode:NO];
    
    XCTAssertFalse([UADSSdkProperties isTestMode], @"Method isInitialized should have returned false");

    [UADSSdkProperties setTestMode:YES];
    
    XCTAssertTrue([UADSSdkProperties isTestMode], @"Method isInitialized should have returned true");
}

- (void)testGetVersionCode {
    XCTAssertTrue([UADSSdkProperties getVersionCode] >= 2000, @"Version code should be over 2000");
}

- (void)testGetVersionName {
    XCTAssertNotNil([UADSSdkProperties getVersionName], @"Version name shouldn't be null");
}

- (void)testGetCacheDirectory {
    XCTAssertNotNil([UADSSdkProperties getCacheDirectory], @"Cache directory shouldn't be null");
}

- (void)testGetCacheFilePrefix {
    XCTAssertTrue([@"UnityAdsCache-" isEqualToString:[UADSSdkProperties getCacheFilePrefix]], @"Cache file prefix should be equal to 'UnityAdsCache-'");
}

- (void)testGetLocalStorageFilePrefix {
    XCTAssertTrue([@"UnityAdsStorage-" isEqualToString:[UADSSdkProperties getLocalStorageFilePrefix]], @"Local storage file prefix should be equal to 'UnityAdsStorage-'");
}

-(void)testSetConfigUrl {
    NSString *defaultConfigUrl = @"https://cdn.unityads.unity3d.com/webview/master/release/config.json";

    XCTAssertTrue([defaultConfigUrl isEqualToString:[UADSSdkProperties getConfigUrl]], @"defaultConfigUrl should be equal to %@", defaultConfigUrl);
    
    [UADSSdkProperties setConfigUrl:@"https://testitesti.fi/config.json"];
    XCTAssertTrue([@"https://testitesti.fi/config.json" isEqualToString:[UADSSdkProperties getConfigUrl]]);
    
    [UADSSdkProperties setConfigUrl:nil];
    XCTAssertTrue([defaultConfigUrl isEqualToString:[UADSSdkProperties getConfigUrl]], @"defaultConfigUrl should be equal to %@", defaultConfigUrl);
}



-(void)testGetLocalWebViewFile {
    NSString *fileName = [UADSSdkProperties getCacheDirectory];
    fileName = [fileName stringByAppendingString:@"/UnityAdsWebApp.html"];

    XCTAssertTrue([fileName isEqualToString:[UADSSdkProperties getLocalWebViewFile]], @"Local web view file should be equal to %@", fileName);
    
}

-(void)testSetShowTimeout {
    XCTAssertTrue(5000 == [UADSSdkProperties getShowTimeout], @"Default show timeout should be 5000");
    
    [UADSSdkProperties setShowTimeout:4000];
    
    XCTAssertTrue(4000 == [UADSSdkProperties getShowTimeout], @"New show timeout should equal to 4000");
}

@end
