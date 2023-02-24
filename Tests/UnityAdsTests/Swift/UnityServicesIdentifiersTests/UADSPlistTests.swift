import Foundation
import XCTest

@testable import UnityAds

// swiftlint:disable force_unwrapping force_cast
class UADSPlistTests: XCTestCase {

  override func setUp() {
    do {
      try self.tearDownPlayerPrefs()
    } catch {
      // Do Nothing
    }
  }

  override func tearDown() {
    do {
      try self.tearDownPlayerPrefs()
    } catch {
      // Do Nothing
    }
  }

  func plistUrl() -> URL {
    let bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
    let filePath = NSString(string: "~/Library/Preferences/\(bundleIdentifier).plist")
      .expandingTildeInPath
    let url = URL(fileURLWithPath: filePath)
    return url
  }

  func tearDownPlayerPrefs() throws {
    let bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
    let filePath = NSString(string: "~/Library/Preferences/\(bundleIdentifier).plist")
      .expandingTildeInPath
    let url = URL(fileURLWithPath: filePath)
    try FileManager.default.removeItem(at: url)
  }

  @available(iOS 11, *)
  func testReadWriteIosEleven() {
    let url = self.plistUrl()
    let firstReadDict = UADSPlist.dictionary(withContentsOfURLIosEleven: url)
    XCTAssertNil(firstReadDict)

    var firstWriteDict: [AnyHashable: Any] = [:]
    firstWriteDict["testKey"] = "testValue"
    UADSPlist.writeIosEleven(firstWriteDict, toFileUrl: url)
    var secondReadDict = UADSPlist.dictionary(withContentsOfURLIosEleven: url)
    XCTAssertNotNil(secondReadDict)
    XCTAssertEqual(secondReadDict?["testKey"] as? String, "testValue")

    secondReadDict?["testKey"] = "updatedTestValue"
    UADSPlist.writeIosEleven(secondReadDict!, toFileUrl: url)
    let thirdReadDict = UADSPlist.dictionary(withContentsOfURLIosEleven: url)
    XCTAssertNotNil(thirdReadDict)
    XCTAssertEqual(thirdReadDict?["testKey"] as? String, "updatedTestValue")
  }

  func testReadWriteIosTen() {
    let url = self.plistUrl()
    let firstReadDict = UADSPlist.dictionary(withContentsOfURLIosTen: url)
    XCTAssertNil(firstReadDict)

    var firstWriteDict: [AnyHashable: Any] = [:]
    firstWriteDict["testKey"] = "testValue"
    UADSPlist.writeIosTen(firstWriteDict, toFileUrl: url)
    var secondReadDict = UADSPlist.dictionary(withContentsOfURLIosTen: url)
    XCTAssertNotNil(secondReadDict)
    XCTAssertEqual(secondReadDict?["testKey"] as? String, "testValue")

    secondReadDict?["testKey"] = "updatedTestValue"
    UADSPlist.writeIosTen(secondReadDict!, toFileUrl: url)
    let thirdReadDict = UADSPlist.dictionary(withContentsOfURLIosTen: url)
    XCTAssertNotNil(thirdReadDict)
    XCTAssertEqual(thirdReadDict?["testKey"] as? String, "updatedTestValue")
  }

  func testReadWrite() {
    let url = self.plistUrl()
    let firstReadDict = UADSPlist.dictionary(withContentsOf: url)
    XCTAssertNil(firstReadDict)

    var firstWriteDict: [AnyHashable: Any] = [:]
    firstWriteDict["testKey"] = "testValue"
    UADSPlist.write(firstWriteDict, toFileUrl: url)
    var secondReadDict = UADSPlist.dictionary(withContentsOf: url)
    XCTAssertNotNil(secondReadDict)
    XCTAssertEqual(secondReadDict?["testKey"] as? String, "testValue")

    secondReadDict?["testKey"] = "updatedTestValue"
    UADSPlist.write(secondReadDict!, toFileUrl: url)
    let thirdReadDict = UADSPlist.dictionary(withContentsOf: url)
    XCTAssertNotNil(thirdReadDict)
    XCTAssertEqual(thirdReadDict?["testKey"] as? String, "updatedTestValue")
  }

  func testWriteFileIosTenThreadSafe() {
    let url = self.plistUrl()
    let startTime = DispatchTime.now()

    for i in 0...100 {
      var firstWriteDict: [AnyHashable: Any] = [:]
      let expectation = self.expectation(description: "\(i) completed!")
      firstWriteDict["testKey"] = "\(i)"
      DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: startTime + 0.2) {
        let success = UADSPlist.writeIosTen(firstWriteDict, toFileUrl: url)
        XCTAssertTrue(success)
        expectation.fulfill()
      }
    }
    self.waitForExpectations(timeout: 1, handler: nil)
  }

  @available(iOS 11, *)
  func testWriteFileIosElevenThreadSafe() {
    let url = self.plistUrl()
    let startTime = DispatchTime.now()

    for i in 0...100 {
      var firstWriteDict: [AnyHashable: Any] = [:]
      let expectation = self.expectation(description: "\(i) completed!")
      firstWriteDict["testKey"] = "\(i)"
      DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: startTime + 0.2) {
        let success = UADSPlist.writeIosEleven(firstWriteDict, toFileUrl: url)
        XCTAssertTrue(success)
        expectation.fulfill()
      }
    }
    self.waitForExpectations(timeout: 1, handler: nil)
  }

  func testReadFileIosTenThreadSafe() {
    let url = self.plistUrl()
    let startTime = DispatchTime.now()
    var firstWriteDict: [AnyHashable: Any] = [:]
    firstWriteDict["testKey"] = "testValue"
    UADSPlist.writeIosTen(firstWriteDict, toFileUrl: url)

    for i in 0...100 {
      var firstWriteDict: [AnyHashable: Any] = [:]
      let expectation = self.expectation(description: "\(i) completed!")
      firstWriteDict["testKey"] = "\(i)"
      DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: startTime + 0.2) {
        let dict: [String: String] =
          UADSPlist.dictionary(withContentsOfURLIosTen: url) as! [String: String]
        XCTAssertEqual(dict["testKey"], "testValue")
        expectation.fulfill()
      }
    }
    self.waitForExpectations(timeout: 1, handler: nil)
  }

  @available(iOS 11, *)
  func testReadFileIosElevenThreadSafe() {
    let url = self.plistUrl()
    var firstWriteDict: [AnyHashable: Any] = [:]
    firstWriteDict["testKey"] = "testValue"
    UADSPlist.writeIosEleven(firstWriteDict, toFileUrl: url)
    let startTime = DispatchTime.now()

    for i in 0...100 {
      var firstWriteDict: [AnyHashable: Any] = [:]
      let expectation = self.expectation(description: "\(i) completed!")
      firstWriteDict["testKey"] = "\(i)"
      DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: startTime + 0.2) {
        let dict: [String: String] =
          UADSPlist.dictionary(withContentsOfURLIosEleven: url) as! [String: String]
        XCTAssertEqual(dict["testKey"], "testValue")
        expectation.fulfill()
      }
    }
    self.waitForExpectations(timeout: 1, handler: nil)
  }
}
