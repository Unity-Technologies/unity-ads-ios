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
    
    func testMakeRequest () {
        let configuration = UADSConfiguration.init(configUrl: UADSSdkProperties.getConfigUrl());
        
        let expectation = self.expectationWithDescription("configRequestExpectation")
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue) {
            configuration.makeRequest()
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(30) {
            error in
            XCTAssertTrue(true, "Did complete")
        }
        
        XCTAssertNotNil(configuration.webViewUrl, "Web view url shouldn't be nil")
        XCTAssertNil(configuration.error, "Error should be nil")
    }
    
    func testMakeRequestNotValidUrl () {
    
        let configuration = UADSConfiguration.init(configUrl: "https://cdn.unityadsssss.unity3d.com/webview/master/release/config.json");
        
        let expectation = self.expectationWithDescription("configRequestExpectation")
        
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_async(queue) {
            configuration.makeRequest()
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(30) {
            error in
            XCTAssertTrue(true, "Did complete")
        }
        
        XCTAssertNotNil(configuration.error, "Error shouldn't be nil")
        XCTAssertTrue("ERROR_REQUESTING_CONFIG" == configuration.error, "Error message should be equal to 'ERROR_REQUESTING_CONFIG'")
        
    }
}