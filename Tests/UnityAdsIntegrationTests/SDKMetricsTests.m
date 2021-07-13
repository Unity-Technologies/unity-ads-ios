#import <XCTest/XCTest.h>
#import "USRVSDKMetrics.h"

@interface SDKMetricsTest : XCTestCase
@end

@implementation SDKMetricsTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testGetInstance {
    XCTAssertNotNil([USRVSDKMetrics getInstance], @"SDKMetrics Instance should never be nil");
}

- (void)testUsingNilAndEmptyEvents {
    [[USRVSDKMetrics getInstance] sendEvent: nil];
    [[USRVSDKMetrics getInstance] sendEvent: @""];
}

- (void)testNilConfiguration {
    [USRVSDKMetrics setConfiguration: nil];
}

- (void)testEmptyUrlFromConfiguration {
    USRVConfiguration *config = [[USRVConfiguration alloc] init];

    [config setMetricsUrl: @""];
    [USRVSDKMetrics setConfiguration: config];
    [[USRVSDKMetrics getInstance] sendEvent: @"test_event"];
}

- (void)testMalformedUrlFromConfiguration {
    USRVConfiguration *config = [[USRVConfiguration alloc] init];

    [config setMetricsUrl: @"........fakeMalformedUrl"];
    [USRVSDKMetrics setConfiguration: config];
    [[USRVSDKMetrics getInstance] sendEvent: @"test_event"];
}

@end
