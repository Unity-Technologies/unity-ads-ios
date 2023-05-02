import Foundation

final class JSONStorageContentNormalizer: StorageContentReader {
    private let config: Config
    init(config: Config) {
        self.config = config
    }

    var allContent: [String: Any] {
        var mergedDictionary = [String: Any]()

        config.original.allContent.forEach { pair in
            processRootPair(&mergedDictionary, pair: pair)
        }
        return mergedDictionary
    }

    func processRootPair(_ output: inout [String: Any], pair: (key: String, value: Any)) {
        guard shouldIncludeRoot(key: pair.key) else { return }
        guard let value = pair.value as? [String: Any] else {
            output[pair.key] = pair.value
            return
        }
        normalize(dictionary: value, output: &output, withParentKey: pair.key)
    }

    func normalize(dictionary: [String: Any],
                   output: inout [String: Any],
                   withParentKey parentKey: String = "") {
        dictionary.forEach { pair in
            processPair(&output, parentKey: parentKey, pair: pair)
        }
    }

    private func shouldIncludeRoot(key: String) -> Bool {
        guard !config.excludeKeys.contains(key) else { return false }
        guard !config.rootLevelKeysInclude.isEmpty else { return true }
        return config.rootLevelKeysInclude.contains(key)
    }

    private func processPair(_ output: inout [String: Any],
                             parentKey: String = "",
                             pair: (key: String, value: Any)) {
        guard !config.excludeKeys.contains(pair.key) else { return }
        let newKey = newKey(for: pair.key, parentKey: parentKey)
        guard let dictionary = pair.value as? [String: Any] else {
            output[newKey] = pair.value
            return
        }
        normalize(dictionary: dictionary, output: &output, withParentKey: newKey)
    }

    private func newKey(for key: String, parentKey: String) -> String {
        guard !parentKey.isEmpty else { return key }
        return config.reduceKeys.contains(key) ? parentKey : "\(parentKey)\(config.separator)\(key)"
    }
}

extension JSONStorageContentNormalizer {
    struct Config {
        var separator = "."
        let original: StorageContentReader
        let rootLevelKeysInclude: [String]
        let excludeKeys: [String]
        let reduceKeys: [String]
    }
}

extension JSONStorageContentNormalizer {
     static func minStorageContentReader(with storage: StorageContentReader) -> StorageContentReader {
        JSONStorageContentNormalizer(config: .init(original: storage,
                                                   rootLevelKeysInclude:
                                                    [
                                                        JSONStorageKeys.Privacy,
                                                        JSONStorageKeys.GDPR,
                                                        JSONStorageKeys.Unity,
                                                        JSONStorageKeys.PIPL
                                                    ],
                                                   excludeKeys: [ "ts" ],
                                                   reduceKeys: [ "value" ]))
    }

    static func  extendedStorageContentReader(with storage: StorageContentReader) -> StorageContentReader {
        JSONStorageContentNormalizer(config: .init(original: storage,
                                                   rootLevelKeysInclude:
                                                    [
                                                        JSONStorageKeys.Mediation,
                                                        JSONStorageKeys.Framework,
                                                        JSONStorageKeys.Adapter,
                                                        JSONStorageKeys.Configuration,
                                                        JSONStorageKeys.User,
                                                        JSONStorageKeys.UnifiedConfig
                                                    ],
                                                   excludeKeys: [ "ts",
                                                                  JSONStorageKeys.Exclude,
                                                                  JSONStorageKeys.PII,
                                                                  "nonBehavioral",
                                                                  "nonbehavioral"
                                                                ],
                                                   reduceKeys: [ "value" ]))
    }

}
