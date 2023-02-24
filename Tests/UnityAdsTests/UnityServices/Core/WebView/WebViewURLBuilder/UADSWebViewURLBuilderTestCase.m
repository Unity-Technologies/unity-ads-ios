#import <XCTest/XCTest.h>
#import "UADSWebViewURLBuilder.h"
#import "USRVConfiguration+TestConvenience.h"

static NSString *const kDefaultTestURL = @"https://baseurl";

@interface UADSWebViewURLBuilderTestCase : XCTestCase

@end

@implementation UADSWebViewURLBuilderTestCase


- (void)test_queries_and_experiments_are_not_appended_if_nil {
    id<UADSBaseURLBuilder> sut = [self sutWithBaseURL: kDefaultTestURL
                                   andQueryAttributes: nil];

    XCTAssertEqualObjects(sut.baseURL, @"https://baseurl");
}

- (void)test_adds_queries_to_the_request {
    id<UADSBaseURLBuilder> sut = [self sutWithBaseURL: kDefaultTestURL
                                   andQueryAttributes: self.testQueryAttributes];

    XCTAssertEqualObjects(sut.baseURL, @"https://baseurl?key1=value1&key2=value2");
}

- (void)test_default_url_builder_passes_required_attributes {

    USRVConfiguration *config = [USRVConfiguration newFromJSON: @{
                                     kUnityServicesConfigValueUrl:  @"webViewURL",
                                     kUnityServicesConfigValueVersion: @"webViewVersion"
    }];

    id<UADSBaseURLBuilder> sut = [UADSWebViewURLBuilder newWithBaseURL: kDefaultTestURL
                                                      andConfiguration : config];

    XCTAssertEqualObjects(sut.baseURL, @"https://baseurl?version=webViewVersion&isNativeCollectingMetrics=true&origin=webViewURL&platform=ios");
}

- (void)test_default_url_builder_doesnt_pass_attributes_if_flag_is_off {

    USRVConfiguration *config = [USRVConfiguration newFromJSON: @{
                                     kUnityServicesConfigValueUrl:  @"webViewURL",
                                     kUnityServicesConfigValueVersion: @"webViewVersion",
                                     kUnityServicesConfigValueMetricSamplingRate: @(-1)
    }];
    id<UADSBaseURLBuilder> sut = [UADSWebViewURLBuilder newWithBaseURL: kDefaultTestURL
                                                      andConfiguration : config];

    XCTAssertEqualObjects(sut.baseURL, @"https://baseurl?version=webViewVersion&isNativeCollectingMetrics=false&origin=webViewURL&platform=ios");
}

- (NSDictionary *)testQueryAttributes {
    return @{
        @"key1": @"value1",
        @"key2": @"value2"
    };
}

- (id<UADSBaseURLBuilder>)sutWithBaseURL: (NSString *)url
                      andQueryAttributes: (NSDictionary *)queries {
    return [UADSWebViewURLBuilder newWithBaseURL: url
                              andQueryAttributes: queries];
}

@end
