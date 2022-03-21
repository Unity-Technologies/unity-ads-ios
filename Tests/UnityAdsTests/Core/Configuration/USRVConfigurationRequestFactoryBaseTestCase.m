#import <XCTest/XCTest.h>
#import "USRVConfigurationRequestFactory.h"
#import "UADSDeviceReaderMock.h"
#import "USRVBodyCompressorMock.h"
#import "USRVBodyURLEncodedCompressorDecorator.h"
#import "USRVClientProperties.h"
#import "UADSBaseURLBuilderMock.h"
#import "UADSFactoryConfigMock.h"
#import "SDKMetricsSenderMock.h"
#import "ConfigurationMetricTagsReaderMock.h"
#import "UADSTsiMetric.h"
#import "NSData+GZIP.h"
#import "NSDictionary+JSONString.h"

NSString *const kUnityMockedBaseURL = @"https:/baseURL";
NSString *const kUnityConfigURLHost = @"https://ads-sdk-configuration.unityads.unity3d.com/webview/4.0.0/release/config";

@interface USRVConfigurationRequestFactoryTester : USRVConfigurationRequestFactoryBase

@end

@implementation USRVConfigurationRequestFactoryTester
- (NSNumber *)currentTimeStamp {
    return @(0);
}

@end

@interface USRVConfigurationRequestFactoryBaseTestCase : XCTestCase
@property (nonatomic, strong)  UADSDeviceReaderMock *infoReaderMock;
@property (nonatomic, strong) SDKMetricsSenderMock *metricsMock;
@property (nonatomic, strong) ConfigurationMetricTagsReaderMock *tagsReaderMock;
@end

@implementation USRVConfigurationRequestFactoryBaseTestCase

- (void)setUp {
    self.infoReaderMock = [UADSDeviceReaderMock new];
    [USRVClientProperties setGameId: @"-1"];
    self.metricsMock = [SDKMetricsSenderMock new];
    self.tagsReaderMock = [ConfigurationMetricTagsReaderMock newWithExpectedTags: self.expectedTags];
}

- (void)test_creates_request_with_queries_tsi_is_on_not_using_compressor {
    self.infoReaderMock.expectedInfo = self.expectedDeviceInfo;
    id<USRVConfigurationRequestFactory> factory = [self sutWithMockedInfoToTestGetFlow: false
                                                                            andBaseURL: kUnityMockedBaseURL];
    id<USRVWebRequest> request = [factory configurationRequestFor: UADSGameModeMix];

    XCTAssertEqualObjects(request.url, @"https:/baseURL?sdkVersionName=SDKVersionName&gameId=GameID&key=value&callType=token");
    [self validateCompressionLatencyMetricSent: NO];
}

- (void)test_creates_request_with_compressed_body {
    self.infoReaderMock.expectedInfo = self.expectedDeviceInfo;
    id<USRVConfigurationRequestFactory> factory = [self sutWithMockedInfoToTestGetFlow: true
                                                                            andBaseURL: kUnityMockedBaseURL];
    id<USRVWebRequest> request = [factory configurationRequestFor: UADSGameModeMix];


    /**
         base64 -> gzip of the next json
        {"sdkVersionName":"SDKVersionName","gameId":"GameID","key":"value","callType":"token"}
     */
    XCTAssertEqualObjects(request.url, @"https:/baseURL?c=H4sIAAAAAAAAE6tWKk7JDkstKs7Mz%2FNLzE1VslIKdvFGFtBRSgdSnilAGXcQwwUokp1aCeSWJeaUguSTE3NyQioLQHpL8rNT85RqAaoAZHRWAAAA");
    [self validateCompressionLatencyMetricSent: YES];
}

- (void)test_doesnt_append_compressed_if_device_info_is_empty {
    self.infoReaderMock.expectedInfo = @{};
    id<USRVConfigurationRequestFactory> factory = [self sutWithMockedInfoToTestGetFlow: true
                                                                            andBaseURL: kUnityMockedBaseURL];
    id<USRVWebRequest> request = [factory configurationRequestFor: UADSGameModeMix];
    NSString *query = @"";
    NSString *expectedString = [NSString stringWithFormat: @"%@%@", kUnityMockedBaseURL, query];

    XCTAssertEqualObjects(request.url, expectedString);
    [self validateCompressionLatencyMetricSent: NO];
}

- (void)test_selects_get_method {
    self.infoReaderMock.expectedInfo = @{};
    id<USRVConfigurationRequestFactory> factory = [self sutWithMockedInfoToTestGetFlow: true
                                                                            andBaseURL: kUnityMockedBaseURL];
    id<USRVWebRequest> request = [factory configurationRequestFor: UADSGameModeMix];

    XCTAssertEqualObjects(request.requestType, @"GET");
    [self validateCompressionLatencyMetricSent: NO];
}

- (void)test_selects_post_method {
    self.infoReaderMock.expectedInfo = @{};
    id<USRVConfigurationRequestFactory> factory = [self sutWithMockedInfoToTestPOSTFlow: true
                                                                             andBaseURL: kUnityMockedBaseURL];
    id<USRVWebRequest> request = [factory configurationRequestFor: UADSGameModeMix];

    XCTAssertEqualObjects(request.requestType, @"POST");
    [self validateCompressionLatencyMetricSent: NO];
}

- (void)test_post_request_contains_proper_url {
    self.infoReaderMock.expectedInfo = @{};
    id<USRVConfigurationRequestFactory> factory = [self sutWithMockedInfoToTestPOSTFlow: true
                                                                             andBaseURL: kUnityMockedBaseURL];
    id<USRVWebRequest> request = [factory configurationRequestFor: UADSGameModeMix];

    XCTAssertEqualObjects(request.url, kUnityMockedBaseURL);
    [self validateCompressionLatencyMetricSent: NO];
}

- (void)test_post_request_contains_gzip_headers {
    self.infoReaderMock.expectedInfo = @{};
    id<USRVConfigurationRequestFactory> factory = [self sutWithMockedInfoToTestPOSTFlow: true
                                                                             andBaseURL: kUnityMockedBaseURL];
    id<USRVWebRequest> request = [factory configurationRequestFor: UADSGameModeMix];

    NSDictionary *expectedHeaders = @{ @"Content-Encoding": @[@"gzip"],
                                       @"Content-Type": @[@"application/json"] };

    XCTAssertEqualObjects(request.headers, expectedHeaders);
    [self validateCompressionLatencyMetricSent: NO];
}

- (void)test_body_contains_gzip_data {
    self.infoReaderMock.expectedInfo = self.expectedDeviceInfo;
    id<USRVConfigurationRequestFactory> factory = [self sutWithMockedInfoToTestPOSTFlow: true
                                                                             andBaseURL: kUnityMockedBaseURL];
    id<USRVWebRequest> request = [factory configurationRequestFor: UADSGameModeMix];

    NSDictionary *dict = @{ @"sdkVersionName": @"SDKVersionName", @"gameId": @"GameID", @"key": @"value", @"callType": @"token" };
    NSData *expectedData = [[dict jsonData] gzippedData];

    XCTAssertNil(request.body);
    XCTAssertEqualObjects(request.bodyData, expectedData);
    [self validateCompressionLatencyMetricSent: YES];
}

- (void)test_body_contains_creates_gzip_encoded_string_of_the_info {
    id<USRVConfigurationRequestFactory> factory = [self sutWithMockedInfoToTestPOSTFlow: true
                                                                             andBaseURL: kUnityMockedBaseURL];
    id<USRVWebRequest> request = [factory configurationRequestFor: UADSGameModeMix];

    XCTAssertEqualObjects(request.body, NULL);
    [self validateCompressionLatencyMetricSent: NO];
}

- (void)test_if_two_stage_init_disabled_should_create_request_with_legacy_url {
    UADSFactoryConfigMock *config = [UADSFactoryConfigMock new];

    config.isPOSTMethodInConfigRequestEnabled = false;
    config.isTwoStageInitializationEnabled = false;
    id<USRVConfigurationRequestFactory> sut = [self sutWithMockedInfoReaderCompressed: true
                                                                            andConfig: config
                                                                           andBaseURL: kUnityMockedBaseURL];
    id<USRVWebRequest> request = [sut configurationRequestFor: UADSGameModeMix];
    NSString *query = @"?sdkVersionName=SDKVersionName&ts=0&gameId=GameID&sdkVersion=4000";
    NSString *expectedString = [NSString stringWithFormat: @"%@%@", kUnityMockedBaseURL, query];

    XCTAssertEqualObjects(request.url, expectedString);
    [self validateCompressionLatencyMetricSent: NO];
}

- (id<USRVConfigurationRequestFactory>)sutWithMockedInfoToTestGetFlow: (BOOL)compressed
                                                           andBaseURL: (NSString *)baseURL {
    UADSFactoryConfigMock *config = [UADSFactoryConfigMock new];

    config.isPOSTMethodInConfigRequestEnabled = false;
    config.isTwoStageInitializationEnabled = true;
    return [self sutWithMockedInfoReaderCompressed: compressed
                                         andConfig: config
                                        andBaseURL: baseURL];
}

- (id<USRVConfigurationRequestFactory>)sutWithMockedInfoToTestPOSTFlow: (BOOL)compressed
                                                            andBaseURL: (NSString *)baseURL {
    UADSFactoryConfigMock *config = [UADSFactoryConfigMock new];

    config.isPOSTMethodInConfigRequestEnabled = true;
    config.isTwoStageInitializationEnabled = true;
    return [self sutWithMockedInfoReaderCompressed: compressed
                                         andConfig: config
                                        andBaseURL: baseURL];
}

- (id<USRVConfigurationRequestFactory>)sutWithMockedInfoReaderCompressed: (BOOL)compressed
                                                               andConfig: (id<UADSConfigurationRequestFactoryConfig>)config
                                                              andBaseURL: (NSString *)baseURL {
    id< UADSBaseURLBuilder> urlBuilder;

    if (baseURL) {
        UADSBaseURLBuilderMock *builderMock = [UADSBaseURLBuilderMock new];

        builderMock.baseURL = baseURL;
        urlBuilder = builderMock;
    } else {
        urlBuilder = [UADSBaseURLBuilderBase newWithHostNameProvider: UADSConfigurationEndpointProvider.defaultProvider];
    }

    return [USRVConfigurationRequestFactoryTester newWithCompression: compressed
                                                 andDeviceInfoReader: self.infoReaderMock
                                                      andBaseBuilder: urlBuilder
                                                    andFactoryConfig: config
                                                       metricsSender: self.metricsMock
                                                    metricTagsReader: self.tagsReaderMock];
}

- (NSDictionary *)expectedDeviceInfo {
    return @{
        @"key": @"value"
    };
}

- (NSDictionary *)expectedTags {
    return @{ @"1": @"a" };
}

- (void)validateCompressionLatencyMetricSent: (BOOL)sent {
    if (sent) {
        XCTAssertEqualObjects(self.metricsMock.sentMetrics, @[ [UADSTsiMetric newDeviceInfoCompressionLatency: @(0)
                                                                                                     withTags: self.expectedTags] ]);
    } else {
        XCTAssertEqual(self.metricsMock.callCount, 0);
    }
}

@end
