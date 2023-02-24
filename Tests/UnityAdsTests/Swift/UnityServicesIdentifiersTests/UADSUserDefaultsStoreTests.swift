import Foundation
import XCTest

@testable import UnityAds

class USIUserDefaultsStoreTests: XCTestCase {

  let userDefaultsTestKey = "unityads-idfi"

  override func tearDown() {
    self.tearDownUserDefaults()
  }

  func setupUserDefaults() {
    UserDefaults.standard.set("UnityAdsUserDefaultsTestInstallationId", forKey: userDefaultsTestKey)
  }

  func tearDownUserDefaults() {
    UserDefaults.standard.removeObject(forKey: userDefaultsTestKey)
  }

  func testUnset() {
    let store = UADSUserDefaultsStore(key: userDefaultsTestKey)
    XCTAssertNil(store.getValue())

    store.commitValue("UnityAdsUserDefaultsTestInstallationId")
    XCTAssertEqual(store.getValue(), "UnityAdsUserDefaultsTestInstallationId")
  }

  func testPreset() {
    self.setupUserDefaults()
    let store = UADSUserDefaultsStore(key: userDefaultsTestKey)
    XCTAssertEqual(store.getValue(), "UnityAdsUserDefaultsTestInstallationId")

    store.commitValue("Second")
    XCTAssertEqual(store.getValue(), "Second")
  }

}
