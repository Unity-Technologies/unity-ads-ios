#import <XCTest/XCTest.h>
#import "USRVDevice.h"

@interface DeviceNetworkingGetterPerformanceTests : XCTestCase

@end

@implementation DeviceNetworkingGetterPerformanceTests

- (void)testPerformanceGetNetworkOperator {
    [self measureBlock:^{
        [USRVDevice getNetworkOperator];
    }];
}

- (void)testPerformanceIsUsingWifi {
    [self measureBlock:^{
        [USRVDevice isUsingWifi];
    }];
}

- (void)testPerformanceGetNetworkType {
    [self measureBlock:^{
        [USRVDevice getNetworkType];
    }];
}

- (void)testPerformanceGetNetworkOperatorName {
    [self measureBlock:^{
        [USRVDevice getNetworkOperatorName];
    }];
}

- (void)testPerformanceIsActiveNetworkConnected {
    [self measureBlock:^{
        [USRVDevice isActiveNetworkConnected];
    }];
}

@end
