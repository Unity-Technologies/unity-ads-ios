import XCTest

class NSStringHashTests: XCTestCase {
    func testSha256() {
        XCTAssertEqual("hello".sha256(), "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824")
        XCTAssertEqual("".sha256(), "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855")
    }
}