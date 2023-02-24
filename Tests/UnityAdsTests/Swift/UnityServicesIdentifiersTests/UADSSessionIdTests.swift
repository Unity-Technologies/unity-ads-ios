import Foundation
import XCTest

@testable import UnityAds

class UADSSessionIdTests: XCTestCase {

  func testShared() {
    let shared = UADSSessionId.shared()
    let shared2 = UADSSessionId.shared()

    XCTAssertNotNil(shared)
    XCTAssertEqual(shared, shared2)
  }

  func testSessionId() {
    let shared = UADSSessionId.shared()
    let shared2 = UADSSessionId.shared()

    XCTAssertNotNil(shared.sessionId())
    XCTAssertEqual(shared.sessionId(), shared.sessionId())
    XCTAssertEqual(shared.sessionId(), shared2.sessionId())
  }

  // sessionId should get generated uniquely per instance of UADSSessionId
  func testDifferentInstancesOfSession() {
    let instance1 = UADSSessionId()
    let instance2 = UADSSessionId()

    XCTAssertNotEqual(instance1.sessionId(), instance2.sessionId())
  }

  func testMultithreading() {
    var sessionIds = [String]()
    var expectations = [XCTestExpectation]()
    for i in 0..<1_000 {
      let expectation = self.expectation(description: "\(i) attempt")
      expectations.append(expectation)
      DispatchQueue.global(qos: .utility).async {
        let sessionId = UADSSessionId.shared().sessionId()
        DispatchQueue.main.async {
          sessionIds.append(sessionId)
          expectation.fulfill()
        }
      }
    }

    self.waitForExpectations(timeout: 5, handler: nil)

    XCTAssertEqual(sessionIds.count, 1_000)
    XCTAssertTrue(sessionIds.allSatisfy({ $0 == sessionIds.first }))
  }

}
