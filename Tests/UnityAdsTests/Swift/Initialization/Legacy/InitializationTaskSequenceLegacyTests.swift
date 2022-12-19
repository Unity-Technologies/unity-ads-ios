import XCTest
@testable import UnityAds

extension ConfigExperiments: DictionaryMappable {}

private struct ExperimentsReaderMock: ExperimentsReader, SessionTokenReader {
    let expectedExp: [String: Any]
    let sessionToken = ""

    var experiments: ConfigExperiments? { try? .init(dictionary: expectedExp) }
}

final class InitializationTaskSequenceLegacyTests: XCTestCase {

    private func sut(with exp: [String: Any]) -> IndexingIterator<[InitTaskCategory]> {
        let reader = ExperimentsReaderMock(expectedExp: exp)
        let sequence = InitializationSequence(experimentsReader: reader).sequence
        return sequence.makeIterator()
    }
    func test_legacy_sequence() {

        var sut = sut(with: [:])
        XCTAssertEqual(sut.next(), .sync(.loadLocalConfig))
        XCTAssertEqual(sut.next(), .sync(.reset))
        XCTAssertEqual(sut.next(), .sync(.initModules))
        XCTAssertEqual(sut.next(), .sync(.configFetch))
        XCTAssertEqual(sut.next(), .sync(.webViewDownload))
        XCTAssertEqual(sut.next(), .sync(.webViewCreate))
        XCTAssertEqual(sut.next(), .sync(.complete))
        XCTAssertEqual(sut.next(), nil)
    }

    func test_new_flow_sequence() {
        var sut = sut(with: ["s_ntf": true])
        XCTAssertEqual(sut.next(), .sync(.loadLocalConfig))
        XCTAssertEqual(sut.next(), .sync(.reset))
        XCTAssertEqual(sut.next(), .sync(.initModules))
        XCTAssertEqual(sut.next(), .sync(.privacyFetch))
        XCTAssertEqual(sut.next(), .sync(.configFetch))
        XCTAssertEqual(sut.next(), .sync(.webViewDownload))
        XCTAssertEqual(sut.next(), .sync(.webViewCreate))
        XCTAssertEqual(sut.next(), .sync(.complete))
        XCTAssertEqual(sut.next(), nil)
    }

    func test_new_flow_parallel() {
        var sut = sut(with: ["s_pte": true])
        XCTAssertEqual(sut.next(), .sync(.loadLocalConfig))
        XCTAssertEqual(sut.next(), .sync(.reset))
        XCTAssertEqual(sut.next(), .sync(.initModules))
        XCTAssertEqual(sut.next(), .sync(.privacyFetch))
        XCTAssertEqual(sut.next(), .async([.configFetch, .webViewDownload]))
        XCTAssertEqual(sut.next(), .sync(.webViewCreate))
        XCTAssertEqual(sut.next(), .sync(.complete))
        XCTAssertEqual(sut.next(), nil)
    }
}
