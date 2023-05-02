import Foundation

enum HeaderBiddingTokenType: Int, Codable {
    case native = 0
    case remote = 1
}

struct HeaderBiddingToken: DictionaryConvertible {
    let value: String
    let type: HeaderBiddingTokenType
    let uuidString: String
    let info: [String: Any]
    let customPrefix: String

    enum CodingKeys: CodingKey {
        case value
        case type
        case uuidString
        case info
        case customPrefix
    }

    func convertIntoDictionary() throws -> [String: Any] {
        var dict = [String: Any]()
        dict.set(value, forCoding: CodingKeys.value)
        dict.set(type.rawValue, forCoding: CodingKeys.type)
        dict.set(uuidString, forCoding: CodingKeys.uuidString)
        dict.set(info, forCoding: CodingKeys.info)
        dict.set(customPrefix, forCoding: CodingKeys.customPrefix)
        return dict
    }
}
