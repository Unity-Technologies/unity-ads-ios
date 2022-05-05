#import <XCTest/XCTest.h>
#import "UADSConfigurationCRUDBase.h"
#import "USRVWebViewApp.h"
#import "UADSConfigurationExperiments.h"
#import "USRVSdkProperties.h"

@interface UADSConfigurationReaderBaseTestCase : XCTestCase

@end

@implementation UADSConfigurationReaderBaseTestCase

- (void)setUp {
    [super setUp];
    USRVWebViewApp *webViewApp = [[USRVWebViewApp alloc] init];

    [USRVWebViewApp setCurrentApp: webViewApp];

    [[NSFileManager defaultManager] removeItemAtPath: [USRVSdkProperties getLocalConfigFilepath]
                                               error: nil];
}

- (void)test_returns_nil_when_no_config {
    UADSConfigurationCRUDBase *sut = [UADSConfigurationCRUDBase new];
    USRVConfiguration *config = [sut getCurrentConfiguration];

    XCTAssertNil(config);
    XCTAssertNil(sut.metricTags);
}

- (void)test_returns_correct_config {
    UADSConfigurationCRUDBase *sut = [UADSConfigurationCRUDBase new];

    [self saveLocalConfig];
    USRVConfiguration *config = [sut getCurrentConfiguration];

    XCTAssertEqualObjects(config.webViewUrl, self.localWebViewUrl);
    XCTAssertEqualObjects(sut.metricTags, self.experiments);

    USRVWebViewApp.getCurrentApp.configuration = [self mockConfigWithUrl: self.remoteWebViewUrl];

    config = [sut getCurrentConfiguration];
    XCTAssertEqualObjects(config.webViewUrl, self.remoteWebViewUrl);
    XCTAssertEqualObjects(sut.metricTags, self.expectedTags);
}

- (void)saveLocalConfig {
    USRVConfiguration *localConfiguration = [self mockConfigWithUrl: self.localWebViewUrl];

    [[localConfiguration toJson] writeToFile: [USRVSdkProperties getLocalConfigFilepath]
                                  atomically: YES];
}

- (USRVConfiguration *)mockConfigWithUrl: (NSString *)url {
    USRVConfiguration *configuration = [USRVConfiguration newFromJSON: @{
                                            kUnityServicesConfigValueUrl:  url,
                                            kUnityServicesConfigValueExperiments: self.experiments,
                                            kUnityServicesConfigValueSource: self.source
    }];

    return configuration;
}

- (NSString *)localWebViewUrl {
    return @"local-fake-url";
}

- (NSString *)remoteWebViewUrl {
    return @"remote-fake-url";
}

- (NSDictionary *)experiments {
    return @{ @"ff1": @"t" };
}

- (NSString *)source {
    return @"srvc";
}

- (NSDictionary *)expectedTags {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary: self.experiments];

    dict[kUnityServicesConfigValueSource] = self.source;
    return dict;
}

@end
