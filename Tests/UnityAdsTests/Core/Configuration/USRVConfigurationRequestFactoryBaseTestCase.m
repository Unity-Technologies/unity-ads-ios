#import <XCTest/XCTest.h>
#import "USRVInitializationRequestFactory.h"
#import "UADSDeviceReaderMock.h"
#import "USRVBodyURLEncodedCompressorDecorator.h"
#import "USRVClientProperties.h"
#import "UADSBaseURLBuilderMock.h"
#import "UADSFactoryConfigMock.h"
#import "SDKMetricsSenderMock.h"
#import "UADSTsiMetric.h"
#import "NSData+GZIP.h"
#import "NSDictionary+JSONString.h"
#import "USRVWebRequestFactory.h"
#import "UADSConfigurationLoaderBuilder.h"
#import "UADSCurrentTimestampMock.h"
#import "UADSConfigurationCRUDBase.h"
#import "UADSCurrentTimestampMock.h"
#import "WebRequestFactoryMock.h"
NSString *const kUnityMockedBaseURL = @"https:/baseURL";
NSString *const kUnityConfigURLHost = @"https://ads-sdk-configuration.unityads.unity3d.com/webview/4.0.0/release/config";

@interface USRVConfigurationRequestFactoryBaseTestCase : XCTestCase
@property (nonatomic, strong) UADSDeviceReaderMock *infoReaderMock;
@property (nonatomic, strong) SDKMetricsSenderMock *metricsMock;
@property (nonatomic, strong) UADSCurrentTimestampMock *timestampMock;
@end

@implementation USRVConfigurationRequestFactoryBaseTestCase

- (void)setUp {
    self.infoReaderMock = [UADSDeviceReaderMock new];
    [USRVClientProperties setGameId: @"-1"];
    self.metricsMock = [SDKMetricsSenderMock new];
    self.timestampMock = [UADSCurrentTimestampMock new];
    self.timestampMock.currentTime = 0;
}

- (void)test_selects_post_method {
    self.infoReaderMock.expectedInfo = @{};
    id<USRVWebRequest> request = [self getWebRequestUsingCompression: true
                                                     usingPostMethod: true
                                                        isTSIEnabled: true
                                                              ofType: USRVInitializationRequestTypeToken];

    XCTAssertEqualObjects(request.requestType, @"POST");
    [self validateCompressionLatencyMetricSent: NO];
}

- (void)test_post_request_contains_proper_url {
    self.infoReaderMock.expectedInfo = @{};
    id<USRVWebRequest> request = [self getWebRequestUsingCompression: true
                                                     usingPostMethod: true
                                                        isTSIEnabled: true
                                                              ofType: USRVInitializationRequestTypeToken];

    XCTAssertEqualObjects(request.url, kUnityMockedBaseURL);
    [self validateCompressionLatencyMetricSent: NO];
}

- (void)test_post_request_contains_gzip_headers {
    self.infoReaderMock.expectedInfo = @{};
    id<USRVWebRequest> request = [self getWebRequestUsingCompression: true
                                                     usingPostMethod: true
                                                        isTSIEnabled: true
                                                              ofType: USRVInitializationRequestTypeToken];

    NSDictionary *expectedHeaders = @{ @"Content-Encoding": @[@"gzip"],
                                       @"Content-Type": @[@"application/json"] };

    XCTAssertEqualObjects(request.headers, expectedHeaders);
    [self validateCompressionLatencyMetricSent: NO];
}

- (void)test_body_contains_gzip_data_for_token_type {
    self.infoReaderMock.expectedInfo = self.expectedDeviceInfo;
    id<USRVWebRequest> request = [self getWebRequestUsingCompression: true
                                                     usingPostMethod: true
                                                        isTSIEnabled: true
                                                              ofType: USRVInitializationRequestTypeToken];

    NSDictionary *dict =  [self expectedPostDataWithCallType: USRVInitializationRequestTypeToken];
    NSData *expectedData = [[dict uads_jsonData] uads_gzippedData];

    XCTAssertNil(request.body);
    XCTAssertEqualObjects(request.bodyData, expectedData);
    [self validateCompressionLatencyMetricSent: YES];
}

- (void)test_body_contains_gzip_data_for_privacy_type {
    self.infoReaderMock.expectedInfo = self.expectedDeviceInfo;
    id<USRVWebRequest> request = [self getWebRequestUsingCompression: true
                                                     usingPostMethod: true
                                                        isTSIEnabled: true
                                                              ofType: USRVInitializationRequestTypePrivacy];

    NSDictionary *dict =  [self expectedPostDataWithCallType: USRVInitializationRequestTypePrivacy];
    NSData *expectedData = [[dict uads_jsonData] uads_gzippedData];

    XCTAssertNil(request.body);
    XCTAssertEqualObjects(request.bodyData, expectedData);
    [self validateCompressionLatencyMetricSent: YES];
}

- (void)test_body_contains_creates_gzip_encoded_string_of_the_info {
    id<USRVWebRequest> request = [self getWebRequestUsingCompression: true
                                                     usingPostMethod: false
                                                        isTSIEnabled: true
                                                              ofType: USRVInitializationRequestTypeToken];

    XCTAssertEqualObjects(request.body, NULL);
    [self validateCompressionLatencyMetricSent: NO];
}

- (id<USRVWebRequest>)getWebRequestUsingCompression: (BOOL)compressed
                                    usingPostMethod: (BOOL)isPostMethod
                                       isTSIEnabled: (BOOL)isTSIEnabled
                                             ofType: (USRVInitializationRequestType)type {
    UADSFactoryConfigMock *config = [UADSFactoryConfigMock new];

    config.isPOSTMethodInConfigRequestEnabled = isPostMethod;
    config.isTwoStageInitializationEnabled = isTSIEnabled;
    id<USRVInitializationRequestFactory> sut = [self sutWithMockedInfoReaderCompressed: compressed
                                                                             andConfig: config
                                                                            andBaseURL: kUnityMockedBaseURL];

    return [sut requestOfType: type];
}

- (id<USRVInitializationRequestFactory>)sutWithMockedInfoReaderCompressed: (BOOL)compressed
                                                                andConfig: (UADSFactoryConfigMock *)config
                                                               andBaseURL: (NSString *)baseURL {
    id< UADSBaseURLBuilder> urlBuilder;

    if (baseURL) {
        UADSBaseURLBuilderMock *builderMock = [UADSBaseURLBuilderMock new];

        builderMock.baseURL = baseURL;
        urlBuilder = builderMock;
    } else {
        urlBuilder = [UADSBaseURLBuilderBase newWithHostNameProvider: UADSConfigurationEndpointProvider.defaultProvider];
    }

    UADSConfigurationLoaderBuilder *builder = [UADSConfigurationLoaderBuilder newWithConfig: config
                                                                       andWebRequestFactory: [WebRequestFactoryMock new]
                                                                               metricSender: [SDKMetricsSenderMock new]];

    builder.metricsSender = self.metricsMock;
    builder.deviceInfoReader = self.infoReaderMock;
    builder.urlBuilder = urlBuilder;
    builder.currentTimeStampReader = _timestampMock;
    builder.noCompression = !compressed;
    builder.configurationSaver =  [UADSConfigurationCRUDBase new];
    return [builder requestFactoryWithExtendedInfo: true];
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
        XCTAssertEqualObjects(self.metricsMock.sentMetrics, @[ [UADSTsiMetric newDeviceInfoCompressionLatency: UADSCurrentTimestampMock.mockedDuration] ]);
    } else {
        XCTAssertEqual(self.metricsMock.callCount, 0);
    }
}

- (NSDictionary *)expectedPostDataWithCallType: (USRVInitializationRequestType)type {
    return @{
        @"sdkVersionName": @"SDKVersionName",
        @"key": @"value",
        @"callType": uads_requestTypeString(type)
    };
}

@end
