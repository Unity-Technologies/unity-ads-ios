#import <XCTest/XCTest.h>
#import "UADSConfigurationExperiments.h"

@interface UADSConfigurationExperimentsTestCase : XCTestCase

@end

@implementation UADSConfigurationExperimentsTestCase


- (void)test_experiments_returns_false_when_json_is_empty {
    UADSConfigurationExperiments *sut = [UADSConfigurationExperiments newWithJSON: @{}];

    XCTAssertEqual(sut.isPOSTMethodInConfigRequestEnabled, false);
    XCTAssertEqual(sut.isForwardExperimentsToWebViewEnabled, false);
    XCTAssertEqual(sut.isTwoStageInitializationEnabled, false);
}

- (void)test_experiments_returns_value_from_dictionary {
    UADSConfigurationExperiments *sut = [UADSConfigurationExperiments newWithJSON: self.mockData];

    XCTAssertEqual(sut.isPOSTMethodInConfigRequestEnabled, true);
    XCTAssertEqual(sut.isForwardExperimentsToWebViewEnabled, true);
    XCTAssertEqual(sut.isTwoStageInitializationEnabled, true);
}

- (NSDictionary *)mockData {
    return @{
        @"tsi": @"true",
        @"tsi_p": @"true",
        @"fff": @"true",
    };
}

@end
