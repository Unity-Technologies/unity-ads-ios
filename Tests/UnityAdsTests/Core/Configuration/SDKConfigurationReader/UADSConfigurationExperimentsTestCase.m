#import <XCTest/XCTest.h>
#import "UADSConfigurationExperiments.h"

@interface UADSConfigurationExperimentsTestCase : XCTestCase

@end

@implementation UADSConfigurationExperimentsTestCase


- (void)test_experiments_returns_default_values_when_json_is_empty {
    UADSConfigurationExperiments *sut = [UADSConfigurationExperiments newWithJSON: @{}];

    XCTAssertFalse(sut.isSwiftInitFlowEnabled);
}

- (void)test_experiments_returns_value_from_dictionary {
    UADSConfigurationExperiments *sut = [UADSConfigurationExperiments newWithJSON: self.mockData];

    XCTAssertTrue(sut.isSwiftInitFlowEnabled);
}

- (NSDictionary *)mockData {
    return @{
        @"s_init": @"true"
    };
}

@end
