import XCTest
@testable import UnityAds
final class SDKObjCBridgesTests: SDKInitializerLegacyIntegrationTestsBase {

    private var jsonStorageAggregator: USRVJsonStorage {
        storageManagerType.getStorage(.private)
    }

    private var storageManager: USRVStorageManager = USRVStorageManager.sharedInstance()
    private var storageManagerType: USRVStorageManager.Type {
        type(of: storageManager)
    }
    let key = "RandomKey"
    let testValue = "testValue"
    override func setUpWithError() throws {
        try super.setUpWithError()
        resetStorage()
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        resetStorage()
    }
    func test_no_value_written() {
        let received: String = tester.serviceProvider.jsonStorageObjCBridge.getValue(for: key) ?? ""
        XCTAssertEqual("", received)
    }

    func test_json_storage_set_in_obj_read_in_swift() {
        jsonStorageAggregator.set(key, value: testValue)
        let received: String = tester.serviceProvider.jsonStorageObjCBridge.getValue(for: key) ?? ""
        XCTAssertEqual(testValue, received)
    }

    func test_json_storage_set_in_swift_read_in_objc() {
        tester.serviceProvider.jsonStorageObjCBridge.saveValue(value: testValue, forKey: key)
        let received: String = jsonStorageAggregator.getValueForKey(key) as? String ?? ""
        XCTAssertEqual(testValue, received)
    }

    private func resetStorage() {
        let paths = [storageManagerType.getStorage(.public),
                     storageManagerType.getStorage(.private)]
        paths.lazy
             .compactMap({ $0 })
             .forEach({
                 $0.clear()
                 $0.initStorage()
        })
    }
}
