#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"
#import "XCTestCase+Convenience.h"
#import "USRVModuleConfiguration.h"

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

    [confClass setWebViewUrl: url];
    XCTAssertEqualObjects([confClass webViewUrl], @"url world", "Contents of webViewUrl not what was expected");
}

- (void)testSetWebViewHash {
    USRVConfiguration *confClass = [[USRVConfiguration alloc] init];
    NSString *hash = @"hash world";

    [confClass setWebViewHash: hash];
    XCTAssertEqualObjects([confClass webViewHash], @"hash world", "Contents of webViewHash not what was expected");
}

- (void)testSetWebViewData {
    USRVConfiguration *confClass = [[USRVConfiguration alloc] init];
    NSString *data = @"data world";

    [confClass setWebViewData: data];
    XCTAssertEqualObjects([confClass webViewData], @"data world", "Contents of webViewData not what was expected");
}

- (void)testInitWithConfigUrl {
    NSString *confurl = @"confurl world";
    USRVConfiguration *confClass = [[USRVConfiguration alloc] initWithConfigUrl: confurl];

    XCTAssertEqualObjects([confClass configUrl], @"confurl world", "Contents of configUrl not what was expected");
}

- (void)testInitWithRequiredJsonData {
    NSError *error;
    NSDictionary *configDictionary = @{
        @"url": @"fake-webview-url"
    };

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: configDictionary
                                                       options: kNilOptions
                                                         error: &error];

    XCTAssertNil(error, "Error was thrown parsing JSON");

    USRVConfiguration *confClass = [[USRVConfiguration alloc] initWithConfigJsonData: jsonData];

    XCTAssertNil([confClass error], "Error while parsing in USRVConfiguration");

    XCTAssertNil([confClass configUrl], "configUrl should not be set");
    XCTAssertEqualObjects([confClass webViewUrl], @"fake-webview-url", "Contents of webviewUrl not what was expected");
    XCTAssertNil([confClass webViewHash], "Contents of webviewHash not what was expected");
    XCTAssertNil([confClass webViewVersion], "Contents of webviewVersion not what was expected");
} /* testInitWithRequiredJsonData */

- (void)testDefaultOptionalValues {
    USRVConfiguration *confClass = [[USRVConfiguration alloc] init];

    XCTAssertFalse([confClass delayWebViewUpdate], "Contents of delayWebviewUpdate not what was expected");
    XCTAssertEqualObjects([NSNumber numberWithInt: [confClass resetWebAppTimeout]], [NSNumber numberWithInt: 10000], "Contents of resetWebAppTimeout not what was expected");
    XCTAssertEqualObjects([NSNumber numberWithInt: [confClass maxRetries]], [NSNumber numberWithInt: 6], "Contents of maxRetries not what was expected");
    XCTAssertEqualObjects([NSNumber numberWithLong: [confClass retryDelay]], [NSNumber numberWithLong: 5000], "Contents of retryDelay not what was expected");
    XCTAssertEqualObjects([NSNumber numberWithDouble: [confClass retryScalingFactor]], [NSNumber numberWithDouble: 2.0], "Contents of retryScalingFactor not what was expected");
    XCTAssertEqualObjects([NSNumber numberWithInt: [confClass connectedEventThresholdInMs]], [NSNumber numberWithInt: 10000], "Contents of connectedEventThresholdInMs not what was expected");
    XCTAssertEqualObjects([NSNumber numberWithInt: [confClass maximumConnectedEvents]], [NSNumber numberWithInt: 500], "Contents of maximumConnectedEvents not what was expected");
    XCTAssertEqualObjects([NSNumber numberWithLong: [confClass networkErrorTimeout]], [NSNumber numberWithLong: 60000], "Contents of networkErrorTimeout not what was expected");
    XCTAssertNil([confClass metricsUrl], "Contents of metricsUrl not what was expected");
    XCTAssertEqualObjects([NSNumber numberWithDouble: [confClass metricSamplingRate]], [NSNumber numberWithDouble: 100], "Contents of metricSampleRate not what was expected");
    XCTAssertEqualObjects([NSNumber numberWithLong: [confClass showTimeout]], [NSNumber numberWithLong: 10000], "Contents of showTimeout not what was expected");
    XCTAssertEqualObjects([NSNumber numberWithLong: [confClass loadTimeout]], [NSNumber numberWithLong: 30000], "Contents of loadTimeout not what was expected");
    XCTAssertEqualObjects([NSNumber numberWithLong: [confClass webViewTimeout]], [NSNumber numberWithLong: 5000], "Contents of noFillTimeout not what was expected");
    XCTAssertEqualObjects([NSNumber numberWithLong: [confClass webViewAppCreateTimeout]], [NSNumber numberWithLong: 60000], "Contents of webViewAppCreateTimeout not what was expected");
    XCTAssertNil([confClass sdkVersion], "Contents of sdkVersion not what was expected");
}

- (void)testInitWithOptionalJsonData {
    NSError *error;
    NSDictionary *configDictionary = @{
        @"url": @"fake-webview-url",
        @"hash":  @"fake-hash",
        @"version": @"fake-version",
        @"dwu": [NSNumber numberWithBool: YES],
        @"rwt": @1,
        @"mr": @2,
        @"rd": @3,
        @"rcf": @4.1,
        @"cet": @5,
        @"mce": @6,
        @"net": @7,
        @"murl": @"unity3d.com",
        @"msr": @8.1,
        @"wct": @9,
        @"sdkv": @"1.2.3"
    };

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: configDictionary
                                                       options: kNilOptions
                                                         error: &error];

    XCTAssertNil(error, "Error was thrown parsing JSON");

    USRVConfiguration *confClass = [[USRVConfiguration alloc] initWithConfigJsonData: jsonData];

    XCTAssertNil([confClass error], "Error while parsing in USRVConfiguration");

    XCTAssertNil([confClass configUrl], "configUrl should not be set");
    XCTAssertEqualObjects([confClass webViewUrl], @"fake-webview-url", "Contents of webviewUrl not what was expected");
    XCTAssertEqualObjects([confClass webViewHash], @"fake-hash", "Contents of webviewHash not what was expected");
    XCTAssertEqualObjects([confClass webViewVersion], @"fake-version", "Contents of webviewVersion not what was expected");
    XCTAssertTrue([confClass delayWebViewUpdate], "Contents of delayWebviewUpdate not what was expected");
    XCTAssertEqualObjects([NSNumber numberWithInt: [confClass resetWebAppTimeout]], [NSNumber numberWithInt: 1], "Contents of resetWebAppTimeout not what was expected");
    XCTAssertEqualObjects([NSNumber numberWithInt: [confClass maxRetries]], [NSNumber numberWithInt: 2], "Contents of maxRetries not what was expected");
    XCTAssertEqualObjects([NSNumber numberWithLong: [confClass retryDelay]], [NSNumber numberWithLong: 3], "Contents of retryDelay not what was expected");
    XCTAssertEqualObjects([NSNumber numberWithDouble: [confClass retryScalingFactor]], [NSNumber numberWithDouble: 4.1], "Contents of retryScalingFactor not what was expected");
    XCTAssertEqualObjects([NSNumber numberWithInt: [confClass connectedEventThresholdInMs]], [NSNumber numberWithInt: 5], "Contents of connectedEventThresholdInMs not what was expected");
    XCTAssertEqualObjects([NSNumber numberWithInt: [confClass maximumConnectedEvents]], [NSNumber numberWithInt: 6], "Contents of maximumConnectedEvents not what was expected");
    XCTAssertEqualObjects([NSNumber numberWithLong: [confClass networkErrorTimeout]], [NSNumber numberWithLong: 7], "Contents of networkErrorTimeout not what was expected");
    XCTAssertEqualObjects([confClass metricsUrl], @"unity3d.com", "Contents of metricsUrl not what was expected");
    XCTAssertEqualObjects([NSNumber numberWithDouble: [confClass metricSamplingRate]], [NSNumber numberWithDouble: 8.1], "Contents of metricSamplingRate not what was expected");
    XCTAssertEqualObjects([NSNumber numberWithLong: [confClass webViewAppCreateTimeout]], [NSNumber numberWithLong: 9], "Contents of webViewAppCreateTimeout not what was expected");
    XCTAssertEqualObjects([confClass sdkVersion], @"1.2.3", "Contents of sdkVersion not what was expected");
} /* testInitWithOptionalJsonData */

- (void)testToJson {
    NSError *error;
    NSDictionary *configDictionary = @{
        @"url": @"fake-webview-url",
        @"fake-field": @"fake-stuff",
        @"fake-field1": @"fake-stuff",
        @"fake-field2": @"fake-stuff"
    };

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject: configDictionary
                                                       options: kNilOptions
                                                         error: &error];

    XCTAssertNil(error, "Error was thrown parsing JSON");

    USRVConfiguration *confClass = [[USRVConfiguration alloc] initWithConfigJsonData: jsonData];

    XCTAssertNil([confClass error], "Error while parsing in USRVConfiguration");

    NSDictionary *toJsonDictionary = [NSJSONSerialization JSONObjectWithData: [confClass toJson]
                                                                     options: kNilOptions
                                                                       error: &error];

    XCTAssertNil(error, "Error was thrown parsing JSON");

    XCTAssertEqualObjects([NSNumber numberWithInteger: [toJsonDictionary count]], [NSNumber numberWithInt: 20], "Size of JSON Objects was not as expected");
    XCTAssertTrue([[toJsonDictionary allKeys] containsObject: @"hash"], "hash should be set");
    XCTAssertTrue([[toJsonDictionary allKeys] containsObject: @"url"], "url should be set");
    XCTAssertTrue([[toJsonDictionary allKeys] containsObject: @"version"], "version should be set");
    XCTAssertTrue([[toJsonDictionary allKeys] containsObject: @"dwu"], "dwu should be set");
    XCTAssertTrue([[toJsonDictionary allKeys] containsObject: @"rwt"], "rwt should be set");
    XCTAssertTrue([[toJsonDictionary allKeys] containsObject: @"mr"], "mr should be set");
    XCTAssertTrue([[toJsonDictionary allKeys] containsObject: @"rd"], "rd should be set");
    XCTAssertTrue([[toJsonDictionary allKeys] containsObject: @"rcf"], "rcf should be set");
    XCTAssertTrue([[toJsonDictionary allKeys] containsObject: @"cet"], "cet should be set");
    XCTAssertTrue([[toJsonDictionary allKeys] containsObject: @"mce"], "mce should be set");
    XCTAssertTrue([[toJsonDictionary allKeys] containsObject: @"murl"], "murl should be set");
    XCTAssertTrue([[toJsonDictionary allKeys] containsObject: @"msr"], "msr should be set");
    XCTAssertTrue([[toJsonDictionary allKeys] containsObject: @"sto"], "sto should be set");
    XCTAssertTrue([[toJsonDictionary allKeys] containsObject: @"lto"], "lto should be set");
    XCTAssertTrue([[toJsonDictionary allKeys] containsObject: @"wto"], "nft should be set");
    XCTAssertTrue([[toJsonDictionary allKeys] containsObject: @"wct"], "wct should be set");
    XCTAssertTrue([[toJsonDictionary allKeys] containsObject: @"sdkv"], "sdkv should be set");
} /* testToJson */

- (void)testMultithreadAccessToConfig {
    for (int i = 0; i < 300; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            USRVConfiguration *configuration = [[USRVConfiguration alloc] init];

            for (NSString *moduleName in [configuration getModuleConfigurationList]) {
                USRVModuleConfiguration *moduleConfiguration = [configuration getModuleConfiguration: moduleName];

                if (moduleConfiguration) {
                    XCTAssertNotEqual([moduleConfiguration getWebAppApiClassList].count, 0);
                }
            }
        });
    }

    [self waitForTimeInterval: 3.0];
}

@end
