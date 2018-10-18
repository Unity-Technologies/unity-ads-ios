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
    XCTAssertFalse([USRVSdkProperties isInitialized], @"SDK shouldn't be initialized");
    
    [USRVSdkProperties setInitialized:YES];
    
    XCTAssertTrue([USRVSdkProperties isInitialized], @"Method isInitialized should have returned true");
     
}

- (void)testSetTestMode {
    [USRVSdkProperties setTestMode:NO];
    
    XCTAssertFalse([USRVSdkProperties isTestMode], @"Method isInitialized should have returned false");

    [USRVSdkProperties setTestMode:YES];
    
    XCTAssertTrue([USRVSdkProperties isTestMode], @"Method isInitialized should have returned true");
}

- (void)testGetVersionCode {
    XCTAssertTrue([USRVSdkProperties getVersionCode] >= 2000, @"Version code should be over 2000");
}

- (void)testGetVersionName {
    XCTAssertNotNil([USRVSdkProperties getVersionName], @"Version name shouldn't be null");
}

- (void)testGetCacheDirectory {
    XCTAssertNotNil([USRVSdkProperties getCacheDirectory], @"Cache directory shouldn't be null");
}

- (void)testGetCacheFilePrefix {
    XCTAssertTrue([@"UnityAdsCache-" isEqualToString:[USRVSdkProperties getCacheFilePrefix]], @"Cache file prefix should be equal to 'UnityAdsCache-'");
}

- (void)testGetLocalStorageFilePrefix {
    XCTAssertTrue([@"UnityAdsStorage-" isEqualToString:[USRVSdkProperties getLocalStorageFilePrefix]], @"Local storage file prefix should be equal to 'UnityAdsStorage-'");
}


-(void)testGetLocalWebViewFile {
    NSString *fileName = [USRVSdkProperties getCacheDirectory];
    fileName = [fileName stringByAppendingString:@"/UnityAdsWebApp.html"];

    XCTAssertTrue([fileName isEqualToString:[USRVSdkProperties getLocalWebViewFile]], @"Local web view file should be equal to %@", fileName);
    
}

-(void)testSetShowTimeout {
    XCTAssertTrue(5000 == [UADSProperties getShowTimeout], @"Default show timeout should be 5000");
    
    [UADSProperties setShowTimeout:4000];
    
    XCTAssertTrue(4000 == [UADSProperties getShowTimeout], @"New show timeout should equal to 4000");
}

@end
