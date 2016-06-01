import XCTest

class ClientPropertiesTests: XCTestCase {
    func testClientProps() {
        XCTAssertEqual(UADSClientProperties.getAppName(), "com.unity3d.ads.example")
        XCTAssertEqual(UADSClientProperties.getAppVersion(), "1.0")
        XCTAssertEqual(UADSClientProperties.isAppDebuggable(), true)
    }
}
    