#import <XCTest/XCTest.h>
#import "UADSConfigurationCRUDBase.h"
#import "USRVWebViewApp.h"
#import "UADSConfigurationExperiments.h"
#import "USRVSdkProperties.h"
#import "XCTestCase+Convenience.h"
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

- (void)test_returns_correct_experiments_as_metric_tags {
    [self checkCurrentExperimentsFlagsLocalWithObjects: false
                                      remoteWithObjest: false];                       // 4.3.0 and before
    [self checkCurrentExperimentsFlagsLocalWithObjects: false
                                      remoteWithObjest: true];                        // upgade to 4.4.0,
    [self checkCurrentExperimentsFlagsLocalWithObjects: true
                                      remoteWithObjest: false];                       // could happen only if we rollback "expo"
    [self checkCurrentExperimentsFlagsLocalWithObjects: true
                                      remoteWithObjest: true];                        // subsequent 4.4.0 inits
}

- (void)checkCurrentExperimentsFlagsLocalWithObjects: (BOOL)localWithObjects remoteWithObjest: (BOOL)withObject {
    UADSConfigurationCRUDBase *sut = [UADSConfigurationCRUDBase new];

    [self saveLocalConfigWithObject: localWithObjects];
    USRVConfiguration *config = [sut getCurrentConfiguration];

    XCTAssertEqualObjects(config.webViewUrl, self.localWebViewUrl);
    XCTAssertEqualObjects(sut.metricTags, [self expectedTagsWithRemote: false]);
    XCTAssertEqualObjects(sut.metricTags[@"tsi"], @"false");
    XCTAssertFalse(config.experiments.isTwoStageInitializationEnabled);
    XCTAssertNil(sut.metricTags[@"tsi_p"]);

    [sut saveConfiguration: [self mockConfigWithUrl: self.remoteWebViewUrl
                                        experiments: withObject ? self.
                             experimentsWithObject : self.experiments
                                   experimentObject: withObject]];

    config = [sut getCurrentConfiguration];
    XCTAssertEqualObjects(config.webViewUrl, self.remoteWebViewUrl);
    XCTAssertEqualObjects(sut.metricTags, [self expectedTagsWithRemote: true]);
    XCTAssertTrue(config.experiments.isTwoStageInitializationEnabled);
    XCTAssertEqualObjects(sut.metricTags[@"tsi"], @"false", @"Metric tag should have tsi flag from cached configuration");
    XCTAssertNil(sut.metricTags[@"tsi_p"], @"Feature flag should be applied from the next session only");
}

- (void)test_subscribing_and_notifying_observers_is_multithread_protected {
    UADSConfigurationCRUDBase *sut = [UADSConfigurationCRUDBase new];
    XCTestExpectation *exp = [self defaultExpectation];
    USRVConfiguration *localConfiguration = [self mockConfigWithUrl: self.localWebViewUrl
                                                        experiments: self.experiments
                                                   experimentObject: false];
    int threadCount = 1000;

    exp.expectedFulfillmentCount = threadCount;
    //subscribe from multiple threads

    [self runBlockAsync: threadCount
                  block:^{
                      [sut subscribeToConfigUpdates:^(USRVConfiguration *_Nonnull cfg) {
                          [exp fulfill];
                      }];
                  }];

    // try to notify in parallel
    [self runBlockAsync: threadCount
                  block:^{
                      [sut saveConfiguration: localConfiguration];
                  }];

    [self waitForExpectations: @[exp]
                      timeout: 1];
}

- (void)test_saving_empty_config_notifies_observers_but_doesnt_save_to_persistence {
    UADSConfigurationCRUDBase *sut = [UADSConfigurationCRUDBase new];
    XCTestExpectation *exp = [self defaultExpectation];

    [sut subscribeToConfigUpdates:^(USRVConfiguration *_Nonnull config) {
        [exp fulfill];
    }];

    USRVConfiguration *local = [self mockConfigWithUrl: self.localWebViewUrl
                                           experiments: self.localExperiments
                                      experimentObject: false];

    [self saveLocalConfigWithObject: false];
    [sut saveConfiguration: [USRVConfiguration newFromJSON: @{}]];

    [self waitForExpectations: @[exp]
                      timeout: 1];
    USRVConfiguration *received = [sut getCurrentConfiguration];

    XCTAssertEqualObjects(received.webViewUrl, local.webViewUrl);
}

- (void)saveLocalConfigWithObject: (BOOL)withObject {
    USRVConfiguration *localConfiguration = [self mockConfigWithUrl: self.localWebViewUrl
                                                        experiments: withObject ? self.
                                             localExperimentsObject : self.localExperiments
                                                   experimentObject: withObject];

    [[localConfiguration toJson] writeToFile: [USRVSdkProperties getLocalConfigFilepath]
                                  atomically: YES];
}

- (USRVConfiguration *)mockConfigWithUrl: (NSString *)url experiments: (NSDictionary *)experiments experimentObject: (BOOL)isObjest {
    NSString *experimentsKey = isObjest ? kUnityServicesConfigValueExperimentsObject : kUnityServicesConfigValueExperiments;
    USRVConfiguration *configuration = [USRVConfiguration newFromJSON: @{
                                            kUnityServicesConfigValueUrl:  url,
                                            experimentsKey: experiments,
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

- (NSDictionary *)localExperiments {
    return @{ @"tsi": @"false", @"fff": @"false" };
}

- (NSDictionary *)localExperimentsObject {
    return @{
        @"tsi": @{
            @"value": @"false",
            @"applied": @"next"
        },
        @"fff": @{
            @"value": @"false",
            @"applied": @"immediate"
        }
    };
}

- (NSDictionary *)experiments {
    return @{
        @"tsi": @"true",
        @"fff": @"true",
        @"nwt": @"true",
        @"tsi_p": @"true"
    };
}

- (NSDictionary *)experimentsWithObject {
    return @{
        @"tsi": @{
            @"value": @"true",
            @"applied": @"next"
        },
        @"fff": @{
            @"value": @"true",
            @"applied": @"immediate"
        },
        @"nwt": @{
            @"value": @"true",
            @"applied": @"immediate"
        },
        @"tsi_p": @{
            @"value": @"true",
            @"applied": @"next"
        }
    };
}

- (NSString *)source {
    return @"srvc";
}

- (NSDictionary *)expectedTagsWithRemote: (BOOL)remote  {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (remote) {
        [dict addEntriesFromDictionary: @{ @"tsi": @"false", @"fff": @"true", @"nwt": @"true" }];
    } else {
        [dict addEntriesFromDictionary: self.localExperiments];
    }

    dict[kUnityServicesConfigValueSource] = self.source;

    return dict;
}

@end
