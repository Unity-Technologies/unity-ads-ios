
#import <XCTest/XCTest.h>

#import "USRVSensorInfo.h"
#import "USRVDevice.h"

@interface SensorInfoTests : XCTestCase

@end

@implementation SensorInfoTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
    [USRVSensorInfo stopAccelerometerUpdates];
}

- (void)testStartAccelerometerUpdates {
    if ([USRVDevice isSimulator]) {
        NSLog(@"--- IGNORED IN SIMULATOR ---");
        return;
    }
    
    BOOL started = [USRVSensorInfo startAccelerometerUpdates:0.01];
    XCTAssertTrue(started, @"Accelerometer should be started");
    
    XCTestExpectation *delayExpectation  = [self expectationWithDescription:@"delayEndExpectation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        XCTAssertTrue([USRVSensorInfo isAccelerometerActive], @"Accelerometer should be active");
        [delayExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError * _Nullable error) {
    }];
}

- (void)testStopAccelerometerUpdates {
    if ([USRVDevice isSimulator]) {
        NSLog(@"--- IGNORED IN SIMULATOR ---");
        return;
    }
    
    XCTAssertFalse([USRVSensorInfo isAccelerometerActive], @"Accelerometer shouldn't be active");
    
    [USRVSensorInfo startAccelerometerUpdates:0.01];
    
    XCTestExpectation *delayExpectation  = [self expectationWithDescription:@"delayEndExpectation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        XCTAssertTrue([USRVSensorInfo isAccelerometerActive], @"Accelerometer should be active");
        [USRVSensorInfo stopAccelerometerUpdates];
        [delayExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError * _Nullable error) {
    }];
    
    XCTAssertFalse([USRVSensorInfo isAccelerometerActive], @"Accelerometer shouldn't be active");
}

- (void)testAccelerometerData {
    if ([USRVDevice isSimulator]) {
        NSLog(@"--- IGNORED IN SIMULATOR ---");
        return;
    }
    [USRVSensorInfo startAccelerometerUpdates:0.01];

    XCTestExpectation *delayExpectation  = [self expectationWithDescription:@"delayEndExpectation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(100 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
        XCTAssertTrue([USRVSensorInfo isAccelerometerActive], @"Accelerometer should be active");
        
        NSDictionary *data = [USRVSensorInfo getAccelerometerData];
        XCTAssertNotNil(data, @"Accelerometer data shouldn't be nil");
        XCTAssertNotNil([data objectForKey:@"x"], @"X value shouldn't be nil");
        XCTAssertNotNil([data objectForKey:@"y"], @"Y value shouldn't be nil");
        XCTAssertNotNil([data objectForKey:@"z"], @"Z value shouldn't be nil");
        
        [delayExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:1 handler:^(NSError * _Nullable error) {
    }];
    
    
}

@end
