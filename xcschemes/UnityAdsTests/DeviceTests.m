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
    NSString *osVersion = [USRVDevice getOsVersion];
    XCTAssertNotNil(osVersion, "OS Version should not be NULL");
    XCTAssertTrue([osVersion length] > 0, "OS version shouldn't be empty");
    
}

- (void)testGetModel {
    NSString *model = [USRVDevice getModel];
    XCTAssertNotNil(model, "Model should not be NULL");
    XCTAssertTrue([model length] > 0, "Model shouldn't be empty");
}

- (void)testGetScreenLayout {
    NSInteger layout = [USRVDevice getScreenLayout];
    XCTAssertTrue(layout != UIDeviceOrientationUnknown);
}

- (void)testGetAdvertisingTrackingId {
    XCTAssertNotNil([USRVDevice getAdvertisingTrackingId], "Advertising id shouldn't be nil");    
}

- (void)testGetNetworkType {
    XCTAssertTrue([USRVDevice getNetworkType] >= 0, "Network type should be larger than 0");
}

- (void)testGetScreenScale {
    XCTAssertTrue([USRVDevice getScreenScale] > 0.0, "Screenscale should be larger than 0");
}

- (void)testGetScreenWidth {
    XCTAssertTrue([[USRVDevice getScreenWidth] intValue] > 0, "Screen width should be larger than 0");
}

- (void)testGetScreenHeight {
    XCTAssertTrue([[USRVDevice getScreenHeight] intValue] > 0, "Screen height should be larger than 0");
}

- (void)testIsActiveNetworkConnected {
    XCTAssertTrue([USRVDevice isActiveNetworkConnected], "Active network should be connected");
}

- (void)testGetUniqueEventId {
    NSString *uuid = [USRVDevice getUniqueEventId];
    XCTAssertTrue(uuid != NULL, "UUID should no be NULL");
    XCTAssertTrue([uuid length] > 0, "UUID length should be more than 0");
}

- (void)testIsWiredHeadsetOn {
    XCTAssertFalse([USRVDevice isWiredHeadsetOn], "Wireless headset should not be connected");
}

- (void)testGetPreferredLocalization {
    NSString *localization = [USRVDevice getPreferredLocalization];
    XCTAssertNotNil(localization, "Preferred localization should not be NULL");
}

- (void)testGetTimeZone {
    NSString *timeZone = [USRVDevice getTimeZone:false];
    XCTAssertNotNil(timeZone, "Timezone should not be NULL");
}

- (void)testGetTimeZoneWithDaylightSavingTime {
    NSString *timeZone = [USRVDevice getTimeZone:true];
    XCTAssertNotNil(timeZone, "Timezone should not be NULL");
}

- (void)testOuputVolume {
    float volume = [USRVDevice getOutputVolume];
    XCTAssertTrue(volume >= 0.0, "Outputvolume should be 0 or larger");
    XCTAssertTrue(volume <= 1.0, "Outputvolume should be 1 or less");
}

- (void)testGetScreenBrightness {
    float brightness = [USRVDevice getScreenBrightness];
    XCTAssertTrue(brightness >= 0.0, "Brightness should be 0 or larger");
    XCTAssertTrue(brightness <= 1.0, "Brightness should be 1 or less");
}

- (void)testGetFreeSpace {
    NSNumber *freeSpace = [USRVDevice getFreeSpaceInKilobytes];
    XCTAssertTrue([freeSpace longLongValue] > 0, "Free space should be larger than 0");
}

- (void)testGetTotalSpace {
    NSNumber *totalSpace = [USRVDevice getTotalSpaceInKilobytes];
    XCTAssertTrue([totalSpace longLongValue] > 0, "Total space should be larger than 0");
}

- (void)testGetBatteryLevel {
    float batteryLevel = [USRVDevice getBatteryLevel];
    NSLog(@"BatteryLevel: %f", batteryLevel);
    XCTAssertTrue((batteryLevel >= 0.0 && batteryLevel <= 1.0) || batteryLevel == -1.0, "Battery level value not within threshold");
}

- (void)testGetBatteryStatus {
    if (![USRVDevice isSimulator]) {
        UIDeviceBatteryState batteryStatus = [USRVDevice getBatteryStatus];
        XCTAssertNotEqual(batteryStatus, UIDeviceBatteryStateUnknown, @"Batter status should not be unknown");
    }
}

- (void)testGetTotalMemory {
    NSNumber *totalMemory = [USRVDevice getTotalMemoryInKilobytes];
    XCTAssertTrue([totalMemory longLongValue] > 0, "Total memory should be more than 0");
}

- (void)testGetFreeMemory {
    NSNumber *freeMemory = [USRVDevice getFreeMemoryInKilobytes];
    XCTAssertTrue([freeMemory longLongValue] > 0, "Free memory should be more than 0");
}

- (void)testGetProcessInfo {
    XCTAssertTrue([[[USRVDevice getProcessInfo] objectForKey:@"stat"] floatValue] >= 0, "stat should not be negative");
}

- (void)testIsRooted {
    bool isRooted = [USRVDevice isRooted];
    XCTAssertFalse(isRooted, "Device shouldn't be rooted");
}

- (void)testGetUserInterfaceIdiom {
    UIUserInterfaceIdiom userInterfaceIdiom = [USRVDevice getUserInterfaceIdiom];
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
    
    XCTAssertEqual(simulator, [USRVDevice isSimulator], @"Two simulator detection results do not match! (LOCAL: %i SDK: %i)", simulator, [USRVDevice isSimulator]);
}

- (void)testGetCPUCount {
    XCTAssertTrue([USRVDevice getCPUCount] > 0, @"Device CPU count should be greater than 0");
}

@end
