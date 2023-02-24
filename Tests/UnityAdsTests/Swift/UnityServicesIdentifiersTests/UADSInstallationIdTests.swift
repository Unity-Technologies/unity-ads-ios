import Foundation
import XCTest

@testable import UnityAds

class UADSInstallationIdTests: XCTestCase {

  override func setUp() {
    self.tearDownUserDefaults()
    do {
      try self.tearDownPlayerPrefs()
    } catch {
      // Do Nothing
    }
  }

  override func tearDown() {
    self.tearDownUserDefaults()
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

  func setupAnalyticsId() {
    let analyticsPrefsStore = UADSUnityPlayerPrefsStore(key: "unity.cloud_userid")
    analyticsPrefsStore.commitValue("AnalyticsPlayerPrefsTestInstallationId")
  }

  func setupUnityAdsId() {
    let unityAdsStore = UADSUserDefaultsStore(key: "unityads-idfi")
    unityAdsStore.commitValue("UnityAdsUserDefaultsTestInstallationId")
  }

  func tearDownPlayerPrefs() throws {
    let bundleIdentifier = Bundle.main.bundleIdentifier ?? ""
    let filePath = NSString(string: "~/Library/Preferences/\(bundleIdentifier).plist")
      .expandingTildeInPath
    let url = URL(fileURLWithPath: filePath)
    try FileManager.default.removeItem(at: url)
  }

  func tearDownUserDefaults() {
    UserDefaults.standard.removeObject(forKey: "unityads-idfi")
  }

  func testShared() {
    let shared = UADSInstallationId.shared()

    XCTAssertNotNil(shared)
  }

  func testPlayerPrefsIntegration() {
    self.setupPlayerPrefs()
    let installationId = UADSInstallationId()

    let id = installationId.installationId()
    XCTAssertEqual(id, "PlayerPrefsTestInstallationId")
    XCTAssertEqual(installationId.installationId(), id)
  }

  func testAnalyticsPlayerPrefsIntegration() {
    self.setupAnalyticsId()
    let installationId = UADSInstallationId()

    let id = installationId.installationId()
    XCTAssertEqual(id, "AnalyticsPlayerPrefsTestInstallationId")
    XCTAssertEqual(installationId.installationId(), id)
  }

  func testUnityAdsUserDefaultsIntegration() {
    self.setupUnityAdsId()
    let installationId = UADSInstallationId()

    let id = installationId.installationId()
    XCTAssertEqual(id, "UnityAdsUserDefaultsTestInstallationId")
    XCTAssertEqual(installationId.installationId(), id)
  }

  func testNoId() {
    let installationIdStore = MockIdStore(value: nil)
    let analyticsIdStore = MockIdStore(value: nil)
    let unityAdsIdStore = MockIdStore(value: nil)
    let installationId = UADSInstallationId(
      installationIdStore: installationIdStore,
      analyticsIdStore: analyticsIdStore,
      unityAdsIdStore: unityAdsIdStore)

    let id = installationId.installationId()
    XCTAssertNotNil(id)
    let secondId = installationId.installationId()
    XCTAssertEqual(secondId, id)

    XCTAssertEqual(installationIdStore.getValueCallHistory.count, 1)
    XCTAssertEqual(analyticsIdStore.getValueCallHistory.count, 1)
    XCTAssertEqual(unityAdsIdStore.getValueCallHistory.count, 1)
    XCTAssertEqual(installationIdStore.commitValueCallHistory.count, 1)
    XCTAssertEqual(analyticsIdStore.commitValueCallHistory.count, 1)
    XCTAssertEqual(unityAdsIdStore.commitValueCallHistory.count, 1)
  }

  func testUnityAdsId() {
    let installationIdStore = MockIdStore(value: nil)
    let analyticsIdStore = MockIdStore(value: nil)
    let unityAdsIdStore = MockIdStore(value: "unityAdsTestId")
    let installationId = UADSInstallationId(
      installationIdStore: installationIdStore,
      analyticsIdStore: analyticsIdStore,
      unityAdsIdStore: unityAdsIdStore)

    let id = installationId.installationId()
    XCTAssertEqual(id, "unityAdsTestId")
    let secondId = installationId.installationId()
    XCTAssertEqual(secondId, "unityAdsTestId")

    XCTAssertEqual(installationIdStore.getValueCallHistory.count, 1)
    XCTAssertEqual(analyticsIdStore.getValueCallHistory.count, 1)
    XCTAssertEqual(unityAdsIdStore.getValueCallHistory.count, 1)
    XCTAssertEqual(installationIdStore.commitValueCallHistory.count, 1)
    XCTAssertEqual(analyticsIdStore.commitValueCallHistory.count, 1)
    XCTAssertEqual(unityAdsIdStore.commitValueCallHistory.count, 1)
  }

  func testAnalyticsId() {
    let installationIdStore = MockIdStore(value: nil)
    let analyticsIdStore = MockIdStore(value: "analyticsTestId")
    let unityAdsIdStore = MockIdStore(value: "unityAdsTestId")
    let installationId = UADSInstallationId(
      installationIdStore: installationIdStore,
      analyticsIdStore: analyticsIdStore,
      unityAdsIdStore: unityAdsIdStore)

    let id = installationId.installationId()
    XCTAssertEqual(id, "analyticsTestId")
    let secondId = installationId.installationId()
    XCTAssertEqual(secondId, "analyticsTestId")

    XCTAssertEqual(installationIdStore.getValueCallHistory.count, 1)
    XCTAssertEqual(analyticsIdStore.getValueCallHistory.count, 1)
    XCTAssertEqual(unityAdsIdStore.getValueCallHistory.count, 0)
    XCTAssertEqual(installationIdStore.commitValueCallHistory.count, 1)
    XCTAssertEqual(analyticsIdStore.commitValueCallHistory.count, 1)
    XCTAssertEqual(unityAdsIdStore.commitValueCallHistory.count, 1)
  }

  func testInstallationId() {
    let installationIdStore = MockIdStore(value: "installationTestId")
    let analyticsIdStore = MockIdStore(value: "analyticsTestId")
    let unityAdsIdStore = MockIdStore(value: "unityAdsTestId")
    let installationId = UADSInstallationId(
      installationIdStore: installationIdStore,
      analyticsIdStore: analyticsIdStore,
      unityAdsIdStore: unityAdsIdStore)

    let id = installationId.installationId()
    XCTAssertEqual(id, "installationTestId")
    let secondId = installationId.installationId()
    XCTAssertEqual(secondId, "installationTestId")

    XCTAssertEqual(installationIdStore.getValueCallHistory.count, 1)
    XCTAssertEqual(analyticsIdStore.getValueCallHistory.count, 0)
    XCTAssertEqual(unityAdsIdStore.getValueCallHistory.count, 0)
    XCTAssertEqual(installationIdStore.commitValueCallHistory.count, 1)
    XCTAssertEqual(analyticsIdStore.commitValueCallHistory.count, 1)
    XCTAssertEqual(unityAdsIdStore.commitValueCallHistory.count, 1)
  }

  func testMultithreading() {
    var installationIds = [String]()
    var expectations = [XCTestExpectation]()
    for i in 0..<1_000 {
      let expectation = self.expectation(description: "\(i) attempt")
      expectations.append(expectation)
      DispatchQueue.global(qos: .utility).async {
        let installationId = UADSInstallationId.shared().installationId()
        DispatchQueue.main.async {
          installationIds.append(installationId)
          expectation.fulfill()
        }
      }
    }

    self.waitForExpectations(timeout: 5, handler: nil)

    XCTAssertEqual(installationIds.count, 1_000)
    XCTAssertTrue(installationIds.allSatisfy({ $0 == installationIds.first }))
  }

}
