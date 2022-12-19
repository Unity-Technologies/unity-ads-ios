import Foundation

extension URLRequest {
    func decodableObject<T>() throws -> T? where T: Decodable {
        try httpBodyStream?.decodableObject()
    }

}
