import XCTest
import UIKit

class DeviceTest: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testGetOsVersion() {
        let osVersion:String! = UADSDevice.getOsVersion()
        NSLog(osVersion)
        XCTAssert(osVersion != nil && !osVersion.isEmpty, "OS version shouldn't be empty")
    }
    
    func testGetModel() {
        let model:String! = UADSDevice.getModel()
        NSLog(model)
        XCTAssert(model != nil && !model.isEmpty, "Model shouldn't be empty")
    }

    func testGetScreenLayout() {
        let layout:Int = UADSDevice.getScreenLayout()
        NSLog("layout : \(layout)")

        XCTAssertTrue(layout != UIDeviceOrientation.Unknown.rawValue)
        
    }
    
    func testGetNetworkType() {
        XCTAssertTrue(UADSDevice.getNetworkType() >= 0)
    }

        // Have to be tested on real device
//    func testGetNetworkOperatorName() {
//        let operatorName:String! = UADSDevice.getNetworkOperatorName()
//        NSLog("operatorName: \(operatorName)")
//        XCTAssert(operatorName != nil && !operatorName.isEmpty, "Network operator name shouldn't be empty")
//    }
//    
//    func testGetNetworkOperator() {
//        let nOperator:String! = UADSDevice.getNetworkOperator()
//        NSLog("network operator: \(nOperator)")
//        XCTAssert(nOperator != nil && !nOperator.isEmpty, "Network operator shouldn't be empty")
//    }
    
    func testGetScreenScale() {
        NSLog("scale: \(UADSDevice.getScreenScale())")
        XCTAssertTrue(UADSDevice.getScreenScale() > 0.0)
    }
    
    func testGetScreenWidth() {
        NSLog("width: \(UADSDevice.getScreenWidth().intValue)")
        XCTAssertTrue(UADSDevice.getScreenWidth().intValue > 0)
    }
    
    func testGetScreenHeight() {
        NSLog("height: \(UADSDevice.getScreenHeight().intValue)")
        XCTAssertTrue(UADSDevice.getScreenHeight().intValue > 0)
    }
    
    func testIsActiveNetworkConnected() {
        XCTAssertTrue(UADSDevice.isActiveNetworkConnected())
    }
    
    func testGetUniqueEventId() {
        let uuid:String! = UADSDevice.getUniqueEventId()
        XCTAssertTrue(uuid != nil && !uuid.isEmpty)
    }
    
    func testIsWiredHeadsetOn() {
        XCTAssertFalse(UADSDevice.isWiredHeadsetOn())
    }
    
    func testGetPreferredLocalization() {
        let localization:String! = UADSDevice.getPreferredLocalization();
        NSLog("localization: " + localization)
        XCTAssertNotNil(localization);
    }
    
    func testGetTimeZone() {
        let timeZone:String! = UADSDevice.getTimeZone(false);
        NSLog("timeZone: " + timeZone)
        XCTAssertNotNil(timeZone);

    }
    
    func testOuputVolume() {
        let volume:Float = UADSDevice.getOutputVolume()
        NSLog("volume: \(volume)")
        XCTAssertTrue(volume >= 0.0 && volume <= 1.0)
    }
    
    func testGetScreenBrightness() {
        let brightness:Float = UADSDevice.getScreenBrightness()
        NSLog("brightness: \(brightness)")
        XCTAssertTrue(brightness >= 0.0 && brightness <= 1.0)
    }
    
    func testGetFreeSpace() {
        let freeSpace:NSNumber! = UADSDevice.getFreeSpaceInKilobytes()
        NSLog("freeSpace: \(freeSpace.longLongValue)")

        XCTAssertTrue(freeSpace.longLongValue > 0)
    }
    
    func testGetTotalSpace() {
        let totalSpace:NSNumber! = UADSDevice.getTotalSpaceInKilobytes()
        NSLog("totalSpace: \(totalSpace.longLongValue)")
        
        XCTAssertTrue(totalSpace.longLongValue > 0)
    }
    
    func testGetBatteryLevel() {
        let batteryLevel:Float = UADSDevice.getBatteryLevel()
        NSLog("batteryLevel: \(batteryLevel)")
        // -1.0 == unknown
        XCTAssertTrue((batteryLevel >= 0.0 && batteryLevel <= 1.0) || batteryLevel == -1.0)
    }

    func getBatteryStatus() {
        let batteryStatus:Int = UADSDevice.getBatteryStatus()
        NSLog("batteryStatus: \(batteryStatus)")
        XCTAssertTrue(batteryStatus != UIDeviceBatteryState.Unknown.rawValue)
    }
    
    
    func testGetTotalMemory() {
        let totalMemory:NSNumber! = UADSDevice.getTotalMemoryInKilobytes()
        NSLog("totalMemory: \(totalMemory.longLongValue)")
        
        XCTAssertTrue(totalMemory.longLongValue > 0)
    }
    
    func testGetFreeMemory() {
        let freeMemory:NSNumber! = UADSDevice.getFreeMemoryInKilobytes()
        NSLog("freeMemory: \(freeMemory.longLongValue)")
        
        XCTAssertTrue(freeMemory.longLongValue > 0)
    }
    
    func testIsRooted() {
        let isRooted:Bool = UADSDevice.isRooted()
        NSLog("isRooted: \(isRooted)")
        
        XCTAssertFalse(isRooted, "Device shouldn't be rooted")
    }
    
    func testGetUserInterfaceIdiom() {
        let userInterfaceIdiom:NSInteger! = UADSDevice.getUserInterfaceIdiom();
        NSLog("userInterfaceIdiom: \(userInterfaceIdiom)")
        XCTAssertNotNil(userInterfaceIdiom);
    }
    
    func testIsSimulator () {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        var simulator = false;
        
        switch identifier {
        case "x86_64":
            simulator = true;
            break;
        case "i386":
            simulator = true;
            break;
        default:
            simulator = false;
        }
        
        XCTAssertEqual(simulator, UADSDevice.isSimulator(), "Two simulator detection results do not match! (LOCAL: " + simulator.description + "SDK: " + UADSDevice.isSimulator().description);
    }
    
    func testIsAppleWatchPaired() {
        XCTAssertFalse(UADSDevice.isAppleWatchPaired(), "Apple watch shouldn't be paired")
    }
}
