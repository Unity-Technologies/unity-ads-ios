import XCTest

class WebRequestQueueTest: XCTestCase {
    override func setUp() {
        super.setUp()
        UADSWebRequestQueue.start()
    }
    
    func testBasicGetRequest () {
        let url = "http://www.google.fi"
        let expectation = self.expectationWithDescription("requestEndExpectation")

        UADSWebRequestQueue.requestUrl(url, type: "GET", headers: nil, body: nil, completeBlock: {
            completeBlock in
            XCTAssertEqual(completeBlock.0, url, "Returned url and requested url should be the same")
            expectation.fulfill()
            }, connectTimeout: 30000);

        self.waitForExpectationsWithTimeout(30) {
            error in
            XCTAssertTrue(true, "Didn't timeout")
        }
    }
    
    func testMultipleGetRequests () {
        let url = "http://www.google.fi"
        
        let expectation = self.expectationWithDescription("requestEndExpectation")
        var completions = [Int]()
        
        UADSWebRequestQueue.requestUrl(url, type: "GET", headers: nil, body: nil, completeBlock: {
            completeBlock in
            completions.append(1)
            XCTAssertEqual(completeBlock.0, url, "Returned url and requested url should be the same")
            }, connectTimeout: 30000);
        
        UADSWebRequestQueue.requestUrl(url, type: "GET", headers: nil, body: nil, completeBlock: {
            completeBlock in
            completions.append(2)
            XCTAssertEqual(completeBlock.0, url, "Returned url and requested url should be the same")
        }, connectTimeout: 30000)

        UADSWebRequestQueue.requestUrl(url, type: "GET", headers: nil, body: nil, completeBlock: {
            completeBlock in
            completions.append(3)
            XCTAssertEqual(completeBlock.0, url, "Returned url and requested url should be the same")
        }, connectTimeout: 30000)

        UADSWebRequestQueue.requestUrl(url, type: "GET", headers: nil, body: nil, completeBlock: {
            completeBlock in
            completions.append(4)
            XCTAssertEqual(completeBlock.0, url, "Returned url and requested url should be the same")
        }, connectTimeout: 30000)

        UADSWebRequestQueue.requestUrl(url, type: "GET", headers: nil, body: nil, completeBlock: {
            completeBlock in
            completions.append(5)
            XCTAssertEqual(completeBlock.0, url, "Returned url and requested url should be the same")
            expectation.fulfill()
        }, connectTimeout: 30000)
        
        self.waitForExpectationsWithTimeout(30) {
            error in
            XCTAssertTrue(true, "Didn't timeout")
        }
        
        var previousValue = 0
        for value in completions {
            XCTAssertTrue(previousValue < value, "Previous completion value should always be smaller than the next one")
            previousValue = value
        }
    }
}
