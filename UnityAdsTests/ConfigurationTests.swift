import XCTest

class ConfigurationTests: XCTestCase {
    func testSetWebAppApiClassList () {
        let confClass:UADSConfiguration = UADSConfiguration()
        let classes:[String] = ["hello", "world"]
        
        confClass.webAppApiClassList = classes
        
        XCTAssertTrue(confClass.webAppApiClassList.elementsEqual(["hello", "world"]), "Contents of webAppApiClassList not what was expected")
    }
    
    func testSetWebViewUrl () {
        let confClass:UADSConfiguration = UADSConfiguration()
        let url = "hello world"
        
        confClass.webViewUrl = url
        XCTAssertTrue(confClass.webViewUrl == "hello world", "Contents of webViewUrl not what was expected")
    }
    
    func testSetWebViewHash () {
        let confClass:UADSConfiguration = UADSConfiguration()
        let url = "hello world"
        
        confClass.webViewHash = url
        XCTAssertTrue(confClass.webViewHash == "hello world", "Contents of webViewHash not what was expected")
    }

    func testSetWebViewData () {
        let confClass:UADSConfiguration = UADSConfiguration()
        let url = "hello world"
        
        confClass.webViewData = url
        XCTAssertTrue(confClass.webViewData == "hello world", "Contents of webViewData not what was expected")
    }

    func testSetConfigUrl () {
        let confClass:UADSConfiguration = UADSConfiguration()
        let url = "hello world"
        
        confClass.configUrl = url
        XCTAssertTrue(confClass.configUrl == "hello world", "Contents of configUrl not what was expected")
    }
}