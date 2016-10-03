#import <XCTest/XCTest.h>
#import "UADSDevice.h"

@interface DeviceNetworkingGetterPerformanceTests : XCTestCase

@end

@implementation DeviceNetworkingGetterPerformanceTests

- (void)testPerformanceGetNetworkOperator {
    [self measureBlock:^{
        [UADSDevice getNetworkOperator];
    }];
}

- (void)testPerformanceIsUsingWifi {
    [self measureBlock:^{
        [UADSDevice isUsingWifi];
    }];
}

- (void)testPerformanceGetNetworkType {
    [self measureBlock:^{
        [UADSDevice getNetworkType];
    }];
}

- (void)testPerformanceGetNetworkOperatorName {
    [self measureBlock:^{
        [UADSDevice getNetworkOperatorName];
    }];
}

- (void)testPerformanceIsActiveNetworkConnected {
    [self measureBlock:^{
        [UADSDevice isActiveNetworkConnected];
    }];
}

@end
