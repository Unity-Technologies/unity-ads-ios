import Foundation
@testable import UnityAds

struct ExperimentsReaderMock: ExperimentsReader, SessionTokenReader {
    let expectedExp: [String: Any]
    let sessionToken = ""

    var experiments: ConfigExperiments? {
        try? .init(dictionary: expectedExp)

    }
}
