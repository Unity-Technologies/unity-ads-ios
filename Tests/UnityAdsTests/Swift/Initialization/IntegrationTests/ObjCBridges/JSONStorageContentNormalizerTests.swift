import XCTest
@testable import UnityAds

final class JSONStorageContentNormalizerTests: XCTestCase {

    var storageMock = KeyValueStorageMock()

    func test_normalizes_dictionary_nothing_excludes_keys() {
        let content = contentFromSutUsing(rootLevelKeysInclude: [],
                                          excludeKeys: [],
                                          skipReduceKeys: [])
        XCTAssertEqual(content, expectedFlattenDataSet)

    }

    func test_flat_nested_dictionary_nothing_excludes_keys() {
        let content = contentFromSutUsing(rootLevelKeysInclude: [],
                                          excludeKeys: ["ts"],
                                          skipReduceKeys: [])
        XCTAssertEqual(content, expectedFlattenDataSetExcludeTS)
    }

    func test_flat_nested_dictionary_nothing_excludes_keys_and_reduce_and_filters() {
        let content = contentFromSutUsing(rootLevelKeysInclude: ["mediation"],
                                          excludeKeys: ["ts"],
                                          skipReduceKeys: ["value"])
        XCTAssertEqual(content, expectedFlattenDataSetReduced)
    }

    private func contentFromSutUsing(rootLevelKeysInclude: [String],
                                     excludeKeys: [String],
                                     skipReduceKeys: [String]) -> [String: String] {
        let sut = sutWith(rootLevelKeysInclude: rootLevelKeysInclude,
                          excludeKeys: excludeKeys,
                          skipReduceKeys: skipReduceKeys)
        return sut.allContent.mapValues { "\($0)" }
    }

    private func sutWith(rootLevelKeysInclude: [String],
                         excludeKeys: [String],
                         skipReduceKeys: [String]) -> JSONStorageContentNormalizer {
        storageMock.storage = testDataSet
        return .init(config: .init(original: storageMock,
                                   rootLevelKeysInclude: rootLevelKeysInclude,
                                   excludeKeys: excludeKeys,
                                   reduceKeys: skipReduceKeys))
    }

}

extension JSONStorageContentNormalizerTests {
    var expectedFlattenDataSetExcludeTS: [String: String] {
        [
            "mediation.adapterVersion.value": "adapter_version",
            "mediation.name.value": "Mediation name",
            "mediation.version.value": "version",

            "framework.name.value": "name",
            "framework.version.value": "version"
        ].mapValues({ "\($0)" })
    }

    var expectedFlattenDataSetReduced: [String: String] {
        [
            "mediation.adapterVersion": "adapter_version",
            "mediation.name": "Mediation name",
            "mediation.version": "version"
        ].mapValues({ "\($0)" })
    }

    var expectedFlattenDataSet: [String: String] {
        [
            "mediation.adapterVersion.value": "adapter_version",
            "mediation.name.value": "Mediation name",
            "mediation.version.value": "version",

            "mediation.adapterVersion.ts": 1_642_615_489_109,
            "mediation.name.ts": 1_642_615_489_109,
            "mediation.version.ts": 1_642_615_489_109,

            "framework.name.ts": 1_642_615_489_109,
            "framework.name.value": "name",
            "framework.version.ts": 1_642_615_489_109,
            "framework.version.value": "version"
        ].mapValues({ "\($0)" })
    }

    var testDataSet: AnyDictionary {
        [
            "mediation": [
                "adapterVersion": [
                    "ts": 1_642_615_489_109,
                    "value": "adapter_version"
                ],

                "name": [
                    "ts": 1_642_615_489_109,
                    "value": "Mediation name"
                ],
                "version": [
                    "ts": 1_642_615_489_109,
                    "value": "version"
                ]
            ],
            "framework": [
                "name": [
                    "ts": 1_642_615_489_109,
                    "value": "name"
                ],
                "version": [
                    "ts": 1_642_615_489_109,
                    "value": "version"
                ]
            ]
        ]
    }

}
