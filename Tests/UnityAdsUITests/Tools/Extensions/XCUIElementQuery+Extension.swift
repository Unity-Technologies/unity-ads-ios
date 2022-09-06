import Foundation
import XCTest

extension XCUIElementQuery {
    func getIfAvailable(_ label: String, timeout: TimeInterval) throws -> XCUIElement {
        let element = self[label]

        guard element.waitForExistence(timeout: timeout) else {
            throw ElementErrors.notFound(label)
        }

        return element
    }

    enum ElementErrors: LocalizedError {
        private var name: String {
            switch self {
            case .notFound(let name):
                return name
            }
        }
        var errorDescription: String? {
            return "Couldn't find element for \(name)"
        }

        case notFound(String)
    }

}
