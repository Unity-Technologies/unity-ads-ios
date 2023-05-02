import Foundation
@testable import UnityAds

final class KeyValueStorageMock: KeyValueStorage, StorageContentReader {
    var allContent: [String: Any] {
        storage
    }

    var storage: [String: Any] = [:]
    private(set) var saveCount = 0
    private(set) var getCount = 0
    private(set) var deleteCount = 0

    func saveValue<T>(value: T, forKey key: String) {
        saveCount += 1
        storage[key] = value
    }

    func getValue<T>(for key: String) -> T? {
        getCount += 1
        return storage[key] as? T
    }

    func delete(forKey key: String) {
        deleteCount += 1
        storage[key] = nil
    }

}
