import Foundation
@testable import UnityAds

struct MockedResponseObject: Codable, Equatable, DictionaryMappable {
    let name: String
    let id: Int

    init(name: String = "MockedResponseObject",
         id: Int = 10) {
        self.name = name
        self.id = id
    }
}

struct MockedDefaultError: Error {}
