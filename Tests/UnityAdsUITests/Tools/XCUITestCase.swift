import Foundation
import XCTest

class XCUITestCase: XCTestCase {

    func tapOnButtonIfAvailable(_ label: String,
                                app: XCUIApplication,
                                timeout: TimeInterval,
                                sleepBeforeTap: UInt32 = 0) throws {
        let element = try app.buttons.getIfAvailable(label, timeout: timeout)
        waitForElement(element, timeout: timeout)
        sleep(sleepBeforeTap)
        element.tap()
    }

    func waitForElement(_ element: XCUIElement, timeout: TimeInterval) {
        let exists = NSPredicate(format: "enabled == true")
        let exp = expectation(for: exists, evaluatedWith: element)
        wait(for: [exp], timeout: timeout)
    }

    func waitForButton(name: String, app: XCUIApplication, timeout: TimeInterval) throws {
        _ = try app.buttons.getIfAvailable(name, timeout: timeout)
    }
}
