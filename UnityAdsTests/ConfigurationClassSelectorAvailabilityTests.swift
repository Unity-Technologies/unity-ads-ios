import XCTest

class ConfigurationClassSelectorAvailabilityTests: XCTestCase {
    func testMakeRequest() {
        let confClass:UADSConfiguration = UADSConfiguration()
        XCTAssertTrue(confClass.respondsToSelector(#selector(confClass.makeRequest)), "UADSConfiguration does not respond to makeRequest")
    }
}