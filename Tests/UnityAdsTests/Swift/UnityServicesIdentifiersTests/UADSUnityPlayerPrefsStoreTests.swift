import Foundation
import XCTest

@testable import UnityAds
// swiftlint:disable compiler_protocol_init
class UADSUnityPlayerPrefsStoreTests: XCTestCase {

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

  func setupPlayerPrefs() {
    let playerPrefsStore = UADSUnityPlayerPrefsStore(key: "UnityInstallationId")
    playerPrefsStore.commitValue("PlayerPrefsTestInstallationId")
  }

  func setupEmptyPlayerPrefs() throws {
    let plistDictionary = NSDictionary()
    try self.writePlist(plistDictionary: plistDictionary)
  }

  func setupIntegerPlayerPrefs() throws {
    let plistDictionary = NSMutableDictionary()
    plistDictionary.setObject(
      NSNumber(integerLiteral: 2), forKey: NSString(string: "UnityInstallationId"))
    try self.writePlist(plistDictionary: plistDictionary)
  }

  func writePlist(plistDictionary: NSDictionary) throws {
    let bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
    let filePath = NSString(string: "~/Library/Preferences/\(bundleIdentifier).plist")
      .expandingTildeInPath
    let url = URL(fileURLWithPath: filePath)
    if #available(iOS 11.0, *) {
      try plistDictionary.write(to: url)
    } else {
      // Fallback on earlier versions
      plistDictionary.write(to: url, atomically: true)
    }
  }

  func tearDownPlayerPrefs() throws {
    let bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
    let filePath = NSString(string: "~/Library/Preferences/\(bundleIdentifier).plist")
      .expandingTildeInPath
    let url = URL(fileURLWithPath: filePath)
    try FileManager.default.removeItem(at: url)
  }

  func testNoPlist() {
    let playerPrefsStore = UADSUnityPlayerPrefsStore(key: "UnityInstallationId")
    XCTAssertEqual(playerPrefsStore.getValue(), nil)
    playerPrefsStore.commitValue("noPlistInstallationId")
    XCTAssertEqual(playerPrefsStore.getValue(), "noPlistInstallationId")
  }

  func testEmptyPlist() throws {
    try self.setupEmptyPlayerPrefs()
    let playerPrefsStore = UADSUnityPlayerPrefsStore(key: "UnityInstallationId")
    XCTAssertEqual(playerPrefsStore.getValue(), nil)
    playerPrefsStore.commitValue("emptyPlistInstallationId")
    XCTAssertEqual(playerPrefsStore.getValue(), "emptyPlistInstallationId")
  }

  func testIntegerPlist() throws {
    try self.setupIntegerPlayerPrefs()
    let playerPrefsStore = UADSUnityPlayerPrefsStore(key: "UnityInstallationId")
    XCTAssertEqual(playerPrefsStore.getValue(), nil)
    playerPrefsStore.commitValue("integerPlistInstallationId")
    XCTAssertEqual(playerPrefsStore.getValue(), "integerPlistInstallationId")
  }

}
