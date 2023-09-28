import XCTest
@testable import UnityAds

class HeaderBiddingTokenReaderTestsCase: XCTestCase {

    var deviceInfoBodyReaderMock = DeviceInfoReaderMock()
    var uniqueGeneratorMock = UniqueGeneratorMock()
    var experimentsDict: [String: String] = [:]

    var sut: HeaderBiddingTokenReader {
        let experimentsMock = ExperimentsReaderMock(expectedExp: experimentsDict)
        return HeaderBiddingTokenReaderBase(
            .init(deviceInfoReader: deviceInfoBodyReaderMock,
                  compressor: Base64GzipCompressor(dataCompressor: GZipCompressor()),
                  customPrefix: "1:",
                  uniqueIdGenerator: uniqueGeneratorMock,
                  experiments: experimentsMock)
        )
    }

    func test_returns_token_with_tid() throws {
        deviceInfoBodyReaderMock.expected = [:]
        uniqueGeneratorMock.uniqueID = "1"
        try runTestWithExpectedToken("1:H4sIAAAAAAAAE6tWKslMUbJSMlSqBQCgUV/nCwAAAA==")
    }

    func runTestWithExpectedToken(_ expected: String) throws {
        let exp = defaultExpectation
        try sut.getToken { token in
            XCTAssertEqual(token.value, expected)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }

}

final class UniqueGeneratorMock: UniqueGenerator {
    var uniqueID: String = ""
}
