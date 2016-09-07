#import <XCTest/XCTest.h>
#import "UnityAdsTests-Bridging-Header.h"
#import <sys/utsname.h>

@interface DeviceTests : XCTestCase
@end

@implementation DeviceTests

- (void)setUp {
    [super setUp];

}

- (void)tearDown {
    [super tearDown];
}

- (void)testGetOsVersion {
    NSString *osVersion = [UADSDevice getOsVersion];
    XCTAssertNotNil(osVersion, "OS Version should not be NULL");
    XCTAssertTrue([osVersion length] > 0, "OS version shouldn't be empty");
    
}

- (void)testGetModel {
    NSString *model = [UADSDevice getModel];
    XCTAssertNotNil(model, "Model should not be NULL");
    XCTAssertTrue([model length] > 0, "Model shouldn't be empty");
}

- (void)testGetScreenLayout {
    NSInteger layout = [UADSDevice getScreenLayout];
    XCTAssertTrue(layout != UIDeviceOrientationUnknown);
}

- (void)testGetAdvertisingTrackingId {
    XCTAssertNotNil([UADSDevice getAdvertisingTrackingId], "Advertising id shouldn't be nil");    
}

- (void)testGetNetworkType {
    XCTAssertTrue([UADSDevice getNetworkType] >= 0, "Network type should be larger than 0");
}

- (void)testGetScreenScale {
    XCTAssertTrue([UADSDevice getScreenScale] > 0.0, "Screenscale should be larger than 0");
}

- (void)testGetScreenWidth {
    XCTAssertTrue([[UADSDevice getScreenWidth] intValue] > 0, "Screen width should be larger than 0");
}

- (void)testGetScreenHeight {
    XCTAssertTrue([[UADSDevice getScreenHeight] intValue] > 0, "Screen height should be larger than 0");
}

- (void)testIsActiveNetworkConnected {
    XCTAssertTrue([UADSDevice isActiveNetworkConnected], "Active network should be connected");
}

- (void)testGetUniqueEventId {
    NSString *uuid = [UADSDevice getUniqueEventId];
    XCTAssertTrue(uuid != NULL, "UUID should no be NULL");
    XCTAssertTrue([uuid length] > 0, "UUID length should be more than 0");
}

- (void)testIsWiredHeadsetOn {
    XCTAssertFalse([UADSDevice isWiredHeadsetOn], "Wireless headset should not be connected");
}

- (void)testGetPreferredLocalization {
    NSString *localization = [UADSDevice getPreferredLocalization];
    XCTAssertNotNil(localization, "Preferred localization should not be NULL");
}

- (void)testGetTimeZone {
    NSString *timeZone = [UADSDevice getTimeZone:false];
    XCTAssertNotNil(timeZone, "Timezone should not be NULL");
}

- (void)testGetTimeZoneWithDaylightSavingTime {
    NSString *timeZone = [UADSDevice getTimeZone:true];
    XCTAssertNotNil(timeZone, "Timezone should not be NULL");
}

- (void)testOuputVolume {
    float volume = [UADSDevice getOutputVolume];
    XCTAssertTrue(volume >= 0.0, "Outputvolume should be 0 or larger");
    XCTAssertTrue(volume <= 1.0, "Outputvolume should be 1 or less");
}

- (void)testGetScreenBrightness {
    float brightness = [UADSDevice getScreenBrightness];
    XCTAssertTrue(brightness >= 0.0, "Brightness should be 0 or larger");
    XCTAssertTrue(brightness <= 1.0, "Brightness should be 1 or less");
}

- (void)testGetFreeSpace {
    NSNumber *freeSpace = [UADSDevice getFreeSpaceInKilobytes];
    XCTAssertTrue([freeSpace longLongValue] > 0, "Free space should be larger than 0");
}

- (void)testGetTotalSpace {
    NSNumber *totalSpace = [UADSDevice getTotalSpaceInKilobytes];
    XCTAssertTrue([totalSpace longLongValue] > 0, "Total space should be larger than 0");
}

- (void)testGetBatteryLevel {
    float batteryLevel = [UADSDevice getBatteryLevel];
    NSLog(@"BatteryLevel: %f", batteryLevel);
    XCTAssertTrue((batteryLevel >= 0.0 && batteryLevel <= 1.0) || batteryLevel == -1.0, "Battery level value not within threshold");
}

- (void)testGetBatteryStatus {
    if (![UADSDevice isSimulator]) {
        UIDeviceBatteryState batteryStatus = [UADSDevice getBatteryStatus];
        XCTAssertNotEqual(batteryStatus, UIDeviceBatteryStateUnknown, @"Batter status should not be unknown");
    }
}

- (void)testGetTotalMemory {
    NSNumber *totalMemory = [UADSDevice getTotalMemoryInKilobytes];
    XCTAssertTrue([totalMemory longLongValue] > 0, "Total memory should be more than 0");
}

- (void)testGetFreeMemory {
    NSNumber *freeMemory = [UADSDevice getFreeMemoryInKilobytes];
    XCTAssertTrue([freeMemory longLongValue] > 0, "Free memory should be more than 0");
}

- (void)testIsRooted {
    bool isRooted = [UADSDevice isRooted];
    XCTAssertFalse(isRooted, "Device shouldn't be rooted");
}

- (void)testGetUserInterfaceIdiom {
    UIUserInterfaceIdiom userInterfaceIdiom = [UADSDevice getUserInterfaceIdiom];
    XCTAssertNotEqual(userInterfaceIdiom, UIUserInterfaceIdiomUnspecified, "UserInterfaceIdiom should not be unspecified");
}

- (void)testIsSimulator {
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *identifier = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    bool simulator = false;
    
    if ([identifier isEqualToString:@"x86_64"]) {
        simulator = true;
    }
    else if ([identifier isEqualToString:@"i386"]) {
        simulator = true;
    }
    else {
        simulator = false;
    }
    
    XCTAssertEqual(simulator, [UADSDevice isSimulator], @"Two simulator detection results do not match! (LOCAL: %i SDK: %i)", simulator, [UADSDevice isSimulator]);
}

@end