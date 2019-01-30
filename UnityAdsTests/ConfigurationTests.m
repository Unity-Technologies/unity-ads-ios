#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"

@interface ConfigurationTests : XCTestCase
@end

@implementation ConfigurationTests

- (void)setUp {
    [super setUp];
    
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSetWebViewUrl {
    USRVConfiguration *confClass = [[USRVConfiguration alloc] init];
    NSString *url = @"url world";
    [confClass setWebViewUrl:url];
    XCTAssertEqualObjects([confClass webViewUrl], @"url world", "Contents of webViewUrl not what was expected");
}

- (void)testSetWebViewHash {
    USRVConfiguration *confClass = [[USRVConfiguration alloc] init];
    NSString *hash = @"hash world";
    [confClass setWebViewHash:hash];
    XCTAssertEqualObjects([confClass webViewHash], @"hash world", "Contents of webViewHash not what was expected");
}

- (void)testSetWebViewData {
    USRVConfiguration *confClass = [[USRVConfiguration alloc] init];
    NSString *data = @"data world";
    [confClass setWebViewData:data];
    XCTAssertEqualObjects([confClass webViewData], @"data world", "Contents of webViewData not what was expected");
}

- (void)testSetConfigUrl {
    USRVConfiguration *confClass = [[USRVConfiguration alloc] init];
    NSString *confurl = @"confurl world";
    [confClass setConfigUrl:confurl];
    XCTAssertEqualObjects([confClass configUrl], @"confurl world", "Contents of webViewData not what was expected");
}

@end
