#import <XCTest/XCTest.h>
#import "UADSBaseURLBuilder.h"
#import "USRVSdkProperties.h"
#import "NSBundle+TypecastGet.h"
#import "UADSConfigurationEndpointProviderMock.h"

@interface UADSBaseURLBuilderBaseTestCase : XCTestCase
@property (nonatomic, strong) UADSConfigurationEndpointProviderMock *hostnameProviderMock;

@end

@implementation UADSBaseURLBuilderBaseTestCase

- (void)setUp {
    self.hostnameProviderMock = [UADSConfigurationEndpointProviderMock new];
}

- (void)test_returns_proper_base_url_with_mocked_hostname_provider {
    NSString *expectedHostname = @"hosthame";

    self.hostnameProviderMock.hostname = expectedHostname;
    id<UADSBaseURLBuilder> sut = [UADSBaseURLBuilderBase newWithHostNameProvider: _hostnameProviderMock];

    [self runTestWithExpectedHostName: expectedHostname
                               forSut: sut];
}

- (void)test_returns_proper_base_url_integration_with_real_provider {
    NSString *expectedHostname = self.expectedHostName;
    id<UADSHostnameProvider> hostNameProvider = UADSConfigurationEndpointProvider.defaultProvider;
    id<UADSBaseURLBuilder> sut = [UADSBaseURLBuilderBase newWithHostNameProvider: hostNameProvider];

    [self runTestWithExpectedHostName: expectedHostname
                               forSut: sut];
}

- (void)runTestWithExpectedHostName: (NSString *)expectedHostname
                             forSut: (id<UADSBaseURLBuilder>)sut {
    NSString *version = [NSBundle uads_getFromMainBundleValueForKey: kUnityServicesWebviewBranchInfoDictionaryKey];

    version = version ? : [USRVSdkProperties getVersionName];
    NSString *expectedURL = [@"https://" stringByAppendingFormat: @"%@/webview/%@/release/config.json", expectedHostname, version];

    XCTAssertEqualObjects(sut.baseURL, expectedURL);
}

- (id<UADSBaseURLBuilder>)sut {
    return [UADSBaseURLBuilderBase newWithHostNameProvider: _hostnameProviderMock];
}

- (NSString *)expectedHostName {
    return [kDefaultConfigVersion stringByAppendingFormat: @".%@", kDefaultConfigHostNameBase];
}

@end
