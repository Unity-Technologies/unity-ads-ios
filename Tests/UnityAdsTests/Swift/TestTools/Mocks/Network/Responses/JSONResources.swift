import Foundation

struct JSONResources {
    private static let resourceReader = BundleResourceReader()

    static var configResponse: [String: Any] {
        do {
            return try resourceReader.getJSONResource(named: "ConfigResponseMock")
        } catch {
            fatalError()
        }

    }
}

final class BundleResourceReader {
    var bundle: Bundle {
        .init(for: BundleResourceReader.self)
    }

    func getJSONResource(named: String) throws -> [String: Any] {
        guard let url = bundle.url(forResource: named, withExtension: "json") else {
            fatalError()
        }
        let data = try Data(contentsOf: url)
        do {
            return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
