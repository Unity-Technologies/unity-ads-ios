import Foundation

final class JSONStorageBridge: KeyValueStorage, StorageContentReader {

    var jsonStorageReaderClosure: ClosureWithReturn<String, Any?>?

    var jsonStorageSaverClosure: Closure<(String, Any)>?

    var jsonStorageDeleteClosure: Closure<(String)>?

    var jsonStorageReaderContentClosure: VoidClosureWithReturn<[String: Any]>?

    func getValue<T>(for key: String) -> T? {
        jsonStorageReaderClosure?(key) as? T
    }

    func saveValue<T>(value: T, forKey key: String) {
        jsonStorageSaverClosure?((key, value))
    }

    func delete(forKey key: String) {
        jsonStorageDeleteClosure?(key)
    }

    var allContent: [String: Any] {
        jsonStorageReaderContentClosure?() ?? [:]
    }
 }
