import Foundation

@testable import UnityAds

class MockIdStore: UADSIdStore {
  var getValueCallHistory: [[Any]] = []
  var commitValueCallHistory: [[Any]] = []
  let value: String?

  init(value: String?) {
    self.value = value
  }

  func getValue() -> String? {
    getValueCallHistory.append([])
    return value
  }

  func commitValue(_ value: String) {
    commitValueCallHistory.append([value])
  }

}
