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
    
    func testEmptyGetUrl () {
        let url = ""
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
        
        XCTAssertNotNil(request.error, "Error should not be null")
        let message:String = request.error.userInfo["message"] as! String;
        XCTAssertTrue(message.containsString("unsupported URL"), "Error message should contain 'unsupported URL'");
        XCTAssertTrue(data.length == 0, "Data length should be zero");
    }
    
    func testEmptyPostUrl () {
        let url = ""
        let request:UADSWebRequest = UADSWebRequest.init(url: url, requestType: "POST", headers: nil, connectTimeout: 30000)
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
        
        XCTAssertNotNil(request.error, "Error should not be null")
        let message:String = request.error.userInfo["message"] as! String;
        XCTAssertTrue(message.containsString("unsupported URL"), "Error message should contain 'unsupported URL'");
        XCTAssertTrue(data.length == 0, "Data length should be zero");
    }
    
    func testNullGetUrl () {
        let request:UADSWebRequest = UADSWebRequest.init(url: nil, requestType: "GET", headers: nil, connectTimeout: 30000)
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
        
        XCTAssertNotNil(request.error, "Error should not be null")
        let message:String = request.error.userInfo["message"] as! String;
        XCTAssertTrue(message.containsString("unsupported URL"), "Error message should contain 'unsupported URL'");
        XCTAssertTrue(data.length == 0, "Data length should be zero");
    }
    
    func testNullPostUrl () {
        let request:UADSWebRequest = UADSWebRequest.init(url: nil, requestType: "POST", headers: nil, connectTimeout: 30000)
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
        
        XCTAssertNotNil(request.error, "Error should not be null")
        let message:String = request.error.userInfo["message"] as! String;
        XCTAssertTrue(message.containsString("unsupported URL"), "Error message should contain 'unsupported URL'");
        XCTAssertTrue(data.length == 0, "Data length should be zero");
    }
    
    func testInvalidGetUrl () {
        let url = "https://gougle.fi/";
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
        
        XCTAssertNotNil(request.error, "Error should not be null")
        let message:String = request.error.userInfo["message"] as! String;
        XCTAssertTrue(message.containsString("A server with the specified hostname could not be found."), "Error message should contain 'A server with the specified hostname could not be found.'");
        XCTAssertTrue(data.length == 0, "Data length should be zero");
    }
    
    func testInvalidPostUrl () {
        let url = "https://gougle.fi/";
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
        
        XCTAssertNotNil(request.error, "Error should not be null")
        let message:String = request.error.userInfo["message"] as! String;
        XCTAssertTrue(message.containsString("A server with the specified hostname could not be found."), "Error message should contain 'A server with the specified hostname could not be found.'");
        XCTAssertTrue(data.length == 0, "Data length should be zero");
    }
    
    func testResolveHost () {
        let resolve:UADSResolve = UADSResolve.init(hostName: "google-public-dns-a.google.com");
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        let expectation = self.expectationWithDescription("requestEndExpectation")
        
        dispatch_async(queue) {
            resolve.resolve();
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(30) {
            error in
            XCTAssertTrue(true, "Did complete")
        }
        
        XCTAssertNil(resolve.error, "Error should be null");
        XCTAssertEqual("google-public-dns-a.google.com", resolve.hostName, "Hosname should still be the same");
        XCTAssertEqual("8.8.8.8", resolve.address, "Address should've resolved to 8.8.8.8");
    }
}
