import XCTest

class WebRequestTest: XCTestCase {
    override func setUp() {
        super.setUp()
    }
    
    func testBasicGetRequest () {
        let url = "https://www.google.fi/"
        let request:UADSWebRequest = UADSWebRequest.init(url: url, requestType: "GET", headers: nil, connectTimeout: 30000)
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        var data:NSData = NSData.init()
        let expectation = self.expectationWithDescription("requestEndExpectation")
        
        dispatch_async(queue) {
            data = request.makeRequest()
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(30) {
            error in
            XCTAssertTrue(true, "Did complete")
        }

        XCTAssertNil(request.error, "Error should be null")
        XCTAssertEqual(request.url, url, "URL's should still be the same")
        XCTAssertNotNil(data, "Data should not be null")
    }
    
    func testBasicPostRequest () {
        let url = "https://www.google.fi/"
        let request:UADSWebRequest = UADSWebRequest.init(url: url, requestType: "POST", headers: nil, connectTimeout: 30000)
        request.body = "hello=world"
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        var data:NSData = NSData.init()
        let expectation = self.expectationWithDescription("requestEndExpectation")
        
        dispatch_async(queue) {
            data = request.makeRequest()
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(30) {
            error in
            XCTAssertTrue(true, "Did complete")
        }
        
        XCTAssertNil(request.error, "Error should be null")
        XCTAssertEqual(request.url, url, "URL's should still be the same")
        XCTAssertNotNil(data, "Data should not be null")
    }
}
