#import <XCTest/XCTest.h>
#import "UADSWebViewURLBuilder.h"
#import "USRVConfiguration+TestConvenience.h"

static NSString *const kDefaultTestURL = @"https://baseurl";

@interface UADSWebViewURLBuilderTestCase : XCTestCase

@end

@implementation UADSWebViewURLBuilderTestCase


- (void)test_queries_and_experiments_are_not_appended_if_nil {
    id<UADSBaseURLBuilder> sut = [self sutWithBaseURL: kDefaultTestURL
                                   andQueryAttributes: nil
                                       andExperiments: nil];

    XCTAssertEqualObjects(sut.baseURL, @"https://baseurl");
}

- (void)test_adds_queries_to_the_request {
    id<UADSBaseURLBuilder> sut = [self sutWithBaseURL: kDefaultTestURL
                                   andQueryAttributes: self.testQueryAttributes
                                       andExperiments: nil];

    XCTAssertEqualObjects(sut.baseURL, @"https://baseurl?key1=value1&key2=value2");
}

- (void)test_adds_experiments_to_the_request {
    NSDictionary *experiments = [self testExperimentsAttributesWithForward: true];
    id<UADSBaseURLBuilder> sut = [self sutWithBaseURL: kDefaultTestURL
                                   andQueryAttributes: nil
                                       andExperiments: experiments];

    XCTAssertEqualObjects(sut.baseURL, @"https://baseurl?experiments=%7B%22experiment2%22%3A%22value2%22,%22fff%22%3Atrue,%22experiment1%22%3A%22value1%22%7D");
}

- (void)test_adds_queries_and_experiments_to_the_request {
    NSDictionary *experiments = [self testExperimentsAttributesWithForward: true];
    id<UADSBaseURLBuilder> sut = [self sutWithBaseURL: kDefaultTestURL
                                   andQueryAttributes: self.testQueryAttributes
                                       andExperiments: experiments];

    XCTAssertEqualObjects(sut.baseURL, @"https://baseurl?key1=value1&experiments=%7B%22experiment2%22%3A%22value2%22,%22fff%22%3Atrue,%22experiment1%22%3A%22value1%22%7D&key2=value2");
}

- (void)test_default_url_builder_passes_required_attributes {
    NSDictionary *experiments = [self testExperimentsAttributesWithForward: true];

    USRVConfiguration *config = [USRVConfiguration newFromJSON: @{
                                     kUnityServicesConfigValueUrl:  @"webViewURL",
                                     kUnityServicesConfigValueVersion: @"webViewVersion",
                                     kUnityServicesConfigValueExperiments: experiments
    }];

    id<UADSBaseURLBuilder> sut = [UADSWebViewURLBuilder newWithBaseURL: kDefaultTestURL
                                                      andConfiguration : config];

    XCTAssertEqualObjects(sut.baseURL, @"https://baseurl?version=webViewVersion&isNativeCollectingMetrics=true&experiments=%7B%22experiment2%22%3A%22value2%22,%22fff%22%3Atrue,%22experiment1%22%3A%22value1%22%7D&origin=webViewURL&platform=ios");
}

- (void)test_default_url_builder_doesnt_pass_attributes_if_flag_is_off {
    NSDictionary *experiments = [self testExperimentsAttributesWithForward: false];


    USRVConfiguration *config = [USRVConfiguration newFromJSON: @{
                                     kUnityServicesConfigValueUrl:  @"webViewURL",
                                     kUnityServicesConfigValueVersion: @"webViewVersion",
                                     kUnityServicesConfigValueMetricSamplingRate: @(-1),
                                     kUnityServicesConfigValueExperiments: experiments
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

- (NSDictionary *)testExperimentsAttributesWithForward: (BOOL)forward {
    return @{
        @"experiment1": @"value1",
        @"experiment2": @"value2",
        @"fff": @(forward)
    };
}

- (id<UADSBaseURLBuilder>)sutWithBaseURL: (NSString *)url
                      andQueryAttributes: (NSDictionary *)queries
                          andExperiments: (NSDictionary *)experiments {
    return [UADSWebViewURLBuilder newWithBaseURL: url
                              andQueryAttributes: queries
                              andExperimentsJSON: experiments];
}

@end
