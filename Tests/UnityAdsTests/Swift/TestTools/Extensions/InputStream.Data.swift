import Foundation
@testable import UnityAds

extension InputStream {

    func decodableObject<T: Decodable>() throws -> T? {
        try T(from: try data())
    }

    private func data() throws -> Data {
        self.open()
        let dictionary = try JSONSerialization.jsonObject(with: self, options: [])
        self.close()
        return try JSONSerialization.data(withJSONObject: dictionary, options: .fragmentsAllowed)
    }
}
